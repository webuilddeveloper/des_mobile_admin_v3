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
class ReportFollowPage extends StatefulWidget {
  ReportFollowPage({super.key});

  @override
  State<ReportFollowPage> createState() => _ReportFollowPageState();

  // getState() => homeCentralPageState;
}

class _ReportFollowPageState extends State<ReportFollowPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureFollowModel;
  TextEditingController txtSearch = TextEditingController();

  int selectedMenuIndex = 0;
  String selectProvince = "1";
  String selectDistrict = "1";
  String selectSubDistrict = "1";
  int tabSelector = 0;
  bool _loading = false;
  dynamic listData;

  dynamic reportModel = {
    "problemListCount": 0,
    "inProgressCount": 0,
    "completeCount": 0,
  };

  // Future<dynamic> _futureProblemModel = Future.value([
  //   {
  //     "id": 0,
  //     "code": "B0",
  //     "title": "แจ้งปัญหาคอมพิวเตอร์ A3",
  //     "description":
  //         "แจ้งปัญหาคอมพิวเตอร์ A3 ศูนย์ดิจิทัลสายไหม มีปัญหา ไม่สามารถใช้งานได้ ",
  //     "memberId": "0012345",
  //     "createDate": "09-07-2566",
  //     "status": "1",
  //     "image": <dynamic>[
  //       {"imageUrl": "assets/images/logo.png"},
  //       {"imageUrl": "assets/images/logo.png"},
  //     ]
  //   },
  //   {
  //     "id": 1,
  //     "code": "B1",
  //     "title": "แจ้งปัญหาคอมพิวเตอร์ A3",
  //     "description":
  //         "แจ้งปัญหาคอมพิวเตอร์ A3 ศูนย์ดิจิทัลสายไหม มีปัญหา ไม่สามารถใช้งานได้ ",
  //     "memberId": "0012345",
  //     "createDate": "09-07-2566",
  //     "status": "1",
  //     "image": <dynamic>[
  //       {"imageUrl": "assets/images/logo.png"},
  //       {"imageUrl": "assets/images/logo.png"},
  //     ]
  //   },
  // ]);

  final Future<dynamic> _futureCategoryModel = Future.value([
    {"id": 0, "title": "ทั้งหมด"},
    {"id": 1, "title": "กำลังรอการแก้ไข"},
    {"id": 2, "title": "กำลังดำเนินการ"},
    {"id": 3, "title": "ดำเนินการเสร็จสิ้น"},
  ]);

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
            'ติดตามปัญหา',
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
            _buildCategory(),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'ติดตามปัญหา',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildFollowList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowList() {
    return Container(
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20),
          right: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: FutureBuilder<dynamic>(
        future: _futureFollowModel,
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
                            _buildFollowResult(snapshot.data.toList()[__], __),
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

  _dialogReportDetails(dynamic model, index) {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0,
            ),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(11.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'ติดตามปัญหา',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Kanit',
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'วันที่รับแจ้ง ${_convertDate(model['ticketDate'] ?? '')}',
                        // modellistDataTrack[index]['ticketName'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Kanit',
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF8414B5),
                          ), // Border color
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 4, // Size of the dot
                              backgroundColor:
                                  Colors.yellow, // Color of the dot
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Spacing between dot and text
                            Text(
                              model['statusCodeText'], // Your text here
                              style: const TextStyle(
                                color: Color(0xFF8414B5), // Text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'หัวข้อปัญหา',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              model['ticketName'] ?? ' - ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                color: Color(0xFF8414B5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'วันที่คาดว่าจะสำเร็จ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _convertDate(model['estimateDate'] ?? ' - '),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  color: Color(0xFF8414B5),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'หมวดหมู่ปัญหา',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              model['ticketType'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                color: Color(0xFF8414B5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "ประเภทปัญหา",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              FutureBuilder(
                                future: _callsubTypesTicketk(
                                  model,
                                ), // ฟังก์ชันที่ดึงข้อมูลจาก API
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                    // return const CircularProgressIndicator();
                                  } else {
                                    return Text(
                                      subTypesTicketk[0]['ticketSubtypeName'] ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                        color: Color(0xFF8414B5),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  _detailTrackTicket(
                    index: index,
                    title: 'ชื่อผู้ใช้าน',
                    subTitle: 'ticketByUserName',
                    title1: "ผู้รับผิดชอบ",
                    subTitle1: '',
                  ),
                  const SizedBox(height: 12),
                  _detailTrackTicket(
                    index: index,
                    title: 'อุปกรณ์ที่มีปัญหา',
                    subTitle: 'assetName',
                    title1: "รายละเอียดปัญหา",
                    subTitle1: 'ticketDesc',
                  ),
                  const SizedBox(height: 12),
                  _detailTrackTicket(
                    index: index,
                    title: 'ข้อมูลการติดต่อ',
                    subTitle: 'remark',
                    title1: "",
                    subTitle1: '',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _detailTrackTicket({
    required int index,
    required String title,
    required String subTitle,
    required String title1,
    required String subTitle1,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                listData[index][subTitle] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Color(0xFF8414B5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title1 ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  listData[index][subTitle1] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Color(0xFF8414B5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowResult(dynamic model, int __) {
    return InkWell(
      onTap: () {
        setState(() {
          _dialogReportDetails(model, __);
          _callsubTypesTicketk(model);
        });

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (contex) => ReportDetailsPage(
        //         model: model,
        //       ),
        //     ));
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
                      'TICKET NO.${model['ticketNo'] ?? "-"}',
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

  Widget _buildCategory() {
    // return SizedBox();
    return SizedBox(
      height: 30.0,
      child: FutureBuilder<dynamic>(
        future: _futureCategoryModel,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(child: Text('ไม่พบข้อมูล'));
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemCount: snapshot.data.length,
                itemBuilder:
                    (_, index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          tabSelector = index;
                          _callRead();
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            snapshot.data?[index]?['title'] ?? '',
                            style: TextStyle(
                              color:
                                  tabSelector == index
                                      ? const Color(0xFF7209B7)
                                      : Colors.black.withOpacity(0.31),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          tabSelector == index
                              ? Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF7209B7),
                                ),
                              )
                              : const SizedBox(width: 5, height: 5),
                        ],
                      ),
                    ),
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
      ),
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _convertDate(String date) {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  }

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callRead() async {
    setState(() => _loading = true);

    DateTime now = new DateTime.now();
    var currentYear = now.year;
    var dateStart = '2023-01-01';
    var dateEnd = '${currentYear}-12-31';

    Dio dio = Dio();
    var response = await dio.get(
      '$ondeURL/api/ticket/getTrackTicket/$dateStart/$dateEnd',
    );
    logWTF(response.data['data']);

    setState(() {
      if (tabSelector == 1) {
        listData =
            response.data['data'].where((i) => i['statusCode'] == 511).toList();
        _futureFollowModel = Future.value(listData);
      } else if (tabSelector == 2) {
        listData =
            response.data['data'].where((i) => i['statusCode'] == 512).toList();
        _futureFollowModel = Future.value(listData);
      } else if (tabSelector == 3) {
        listData =
            response.data['data'].where((i) => i['statusCode'] == 513).toList();
        _futureFollowModel = Future.value(listData);
      } else {
        listData = response.data['data'];
        _futureFollowModel = Future.value(listData);
      }
    });
    setState(() => _loading = false);
  }

  dynamic subTypesTicketk;
  dynamic ticketTypeCode;

  _callsubTypesTicketk(model) async {
    String token = await ManageStorage.read('accessToken_122') ?? '';
    ticketTypeCode = model['ticketTypeCode'];
    // print('-----------ticketTypeCode---------------${ticketTypeCode}');

    Dio dio = Dio();
    try {
      var response = await dio.get(
        '$ondeURL/api/masterdata/ticket/subTypes?ticketTypeCode=$ticketTypeCode',
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data.isNotEmpty) {
        setState(() {
          subTypesTicketk = response.data;
          // logWTF('Sub Types: ${subTypesTicketk}');
        });
      } else {
        logWTF('Error: ${response.statusCode}, Message: ${response.data}');
      }
      setState(() => _loading = false);
    } catch (e) {
      logWTF('Exception: $e');
    }
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
