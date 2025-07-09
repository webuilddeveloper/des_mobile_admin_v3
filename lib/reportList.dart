import 'dart:async';
import 'dart:convert';

import 'package:des_mobile_admin_v3/report_details.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'config.dart';

// ignore: must_be_immutable
class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();

  // getState() => homeCentralPageState;
}

class _ReportListPageState extends State<ReportListPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProblemModel;
  Future<dynamic>? _futureModelTicketSummary;

  TextEditingController txtSearch = TextEditingController();

  int selectedMenuIndex = 0;
  String selectProvince = "1";
  String selectDistrict = "1";
  String selectSubDistrict = "1";
  bool _loading = false;
  dynamic listData;
  String _selectedDashboard = '0';

  dynamic reportModel = {
    "ticketCount": 0,
    "ticketContinue": 0,
    "ticketDone": 0,
    "ticketInProgress": 0,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFfdf9ff),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Color(0xFFfdf9ff)),
          ),

          leading: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => {goBack()},
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // backgroundColor: Color(0xFF9A1120),
          centerTitle: true,
          title: const Text(
            'รายการปัญหาการใช้งาน',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDashBoard(),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'รายการปัญหา',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildProblemList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemList() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20),
          right: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: FutureBuilder<dynamic>(
        future: _futureProblemModel,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(child: Text('ไม่พบข้อมูล'));
            } else {
              return Stack(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    // physics: const ClampingScrollPhysics(),
                    // padding: const EdgeInsets.symmetric(
                    //   horizontal: 20,
                    //   vertical: 10,
                    // ),
                    itemCount: snapshot.data.length,
                    // separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder:
                        (_, __) =>
                            _buildProblemResult(snapshot.data.toList()[__]),
                  ),
                  if (_loading)
                    const Center(
                      heightFactor: 15,
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return const Center(
              heightFactor: 15,
              child: CircularProgressIndicator(),
            );
          }
        },
        // ),
      ),

      // )
    );
  }

  Widget _buildProblemResult(dynamic model) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (contex) => ReportDetailsPage(model: model, mode: 2),
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(11)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF3D2FF).withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 12,
            left: 16,
            right: 25,
          ),
          width: double.infinity,
          // height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7209B7),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'TICKET NO. ${model['ticketNo'] ?? "-"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  '${model['ticketName']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  // '${model['statusCodeText']} -  ${model['ticketOwner']}',
                  '${model['statusCodeText']} ${model['ticketOwner'] != null && model['ticketOwner'].isNotEmpty ? ' - ${model['ticketOwner']}' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Image.asset(
                      "assets/images/calendar.png",
                      fit: BoxFit.contain,
                      width: 16,
                      height: 16,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _convertDate(model['ticketDate']),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashBoard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
      height: 150.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 130.0,
            color: const Color(0xFFfdf9ff),
            child: InkWell(
              onTap:
                  () => setState(() {
                    _selectedDashboard = "0";
                    _callRead();
                  }),
              child: Container(
                width: double.infinity,
                decoration:
                    _selectedDashboard == "0"
                        ? const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF760CB7), Color(0xFFBB36AE)],
                            stops: [0, 1],
                            begin: FractionalOffset.topLeft,
                            end: FractionalOffset.bottomRight,
                            tileMode: TileMode.repeated,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                        : const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 249, 233, 255),
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAB8E9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Image.asset(
                              "assets/images/รายการปัญหา.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            'รายการปัญหา',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color:
                                  _selectedDashboard == "0"
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF8414B5),
                            ),
                          ),
                          Text(
                            '${reportModel['ticketCount'] ?? '0'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color:
                                  _selectedDashboard == "0"
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF8414B5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -25,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 130.0,
            color: const Color(0xFFfdf9ff),
            child: InkWell(
              onTap:
                  () => setState(() {
                    _selectedDashboard = "1";
                    _callRead();
                  }),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration:
                    _selectedDashboard == "1"
                        ? const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF760CB7), Color(0xFFBB36AE)],
                            stops: [0, 1],
                            begin: FractionalOffset.topLeft,
                            end: FractionalOffset.bottomRight,
                            tileMode: TileMode.repeated,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                        : const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 249, 233, 255),
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAB8E9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Image.asset(
                              "assets/images/progress.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            'รอการแแก้ไข',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color:
                                  _selectedDashboard == "1"
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF8414B5),
                            ),
                          ),
                          Text(
                            '${reportModel['ticketInProgress'] ?? '0'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color:
                                  _selectedDashboard == "1"
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF8414B5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -25,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 130.0,
            color: const Color(0xFFfdf9ff),
            child: InkWell(
              onTap:
                  () => setState(() {
                    _selectedDashboard = "2";
                    _callRead();
                  }),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 249, 233, 255),
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  width: double.infinity,
                  height: 120,
                  decoration:
                      _selectedDashboard == "2"
                          ? const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF760CB7), Color(0xFFBB36AE)],
                              stops: [0, 1],
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.bottomRight,
                              tileMode: TileMode.repeated,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                          : const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 249, 233, 255),
                                blurRadius: 5,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDAB8E9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Image.asset(
                          "assets/images/progress.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        "กำลังดำเนินการ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color:
                              _selectedDashboard == "2"
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF8414B5),
                        ),
                      ),
                      Text(
                        '${reportModel['ticketContinue'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color:
                              _selectedDashboard == "2"
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF8414B5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 130.0,
            color: const Color(0xFFfdf9ff),
            child: InkWell(
              onTap:
                  () => setState(() {
                    _selectedDashboard = "3";
                    _callRead();
                  }),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 249, 233, 255),
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  width: double.infinity,
                  height: 120,
                  decoration:
                      _selectedDashboard == "3"
                          ? const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF760CB7), Color(0xFFBB36AE)],
                              stops: [0, 1],
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.bottomRight,
                              tileMode: TileMode.repeated,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                          : const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 249, 233, 255),
                                blurRadius: 5,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAFC4E2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Image.asset(
                          "assets/images/complete_problem.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        'ดำเนินการเสร็จ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color:
                              _selectedDashboard == "3"
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF8414B5),
                        ),
                      ),
                      Text(
                        '${reportModel['ticketDone'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color:
                              _selectedDashboard == "3"
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF8414B5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _convertDate(String date) {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    _callReadSummary();
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callReadSummary() async {
    setState(() => _loading = true);
    DateTime now = new DateTime.now();
    var currentYear = now.year;
    var dateStart = '${currentYear}-01-01';
    var dateEnd = '${currentYear}-12-31';
    String token = await ManageStorage.read('accessToken_122') ?? '';

    Dio dio = Dio();
    var response = await dio.get(
      'https://dcc.onde.go.th/dcc-api/api/ticket/getTicketSummary/$dateStart/$dateEnd',
      options: Options(
        validateStatus: (_) => true,
        contentType: 'application/x-www-form-urlencoded',
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    setState(() {
      reportModel = response.data['data'];
      logWTF(response.data['data']);
      _futureModelTicketSummary = Future.value(listData);
    });

    setState(() => _loading = false);
  }

  _callRead() async {
    setState(() => _loading = true);
    DateTime now = new DateTime.now();
    var currentYear = now.year;
    var dateStart = '${currentYear}-01-01';
    var dateEnd = '${currentYear}-12-31';

    setState(() => _loading = true);
    Dio dio = Dio();
    var response = await dio.get(
      '$ondeURL/api/ticket/getTickets/$dateStart/$dateEnd',
    );

    // logWTF(response.data['data']);
    setState(() {
      if (_selectedDashboard == '0') {
        listData = response.data['data'];
        _futureProblemModel = Future.value(listData);
      } else if (_selectedDashboard == '1') {
        listData =
            response.data['data'].where((i) => i['statusCode'] == 511).toList();
        _futureProblemModel = Future.value(listData);
      } else if (_selectedDashboard == '2') {
        listData =
            response.data['data'].where((i) => i['statusCode'] == 512).toList();
        _futureProblemModel = Future.value(listData);
      } else if (_selectedDashboard == '3') {
        listData =
            response.data['data'].where((i) => i['statusCode'] == 513).toList();
        _futureProblemModel = Future.value(listData);
      }
    });
    setState(() => _loading = false);
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
