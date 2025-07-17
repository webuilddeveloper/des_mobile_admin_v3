import 'dart:convert';
import 'dart:typed_data';

import 'package:des_mobile_admin_v3/config.dart';
import 'package:des_mobile_admin_v3/main.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/loading_image_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:flutter_face_api/flutter_face_api.dart' as regula;

import 'reservation_edit.dart';
import 'face_authenticate.dart';
import 'success_face.dart';

class ReservationTodayPage extends StatefulWidget {
  const ReservationTodayPage({super.key, required this.title});
  final String title;

  @override
  State<ReservationTodayPage> createState() => _ReservationTodayPageState();
}

class _ReservationTodayPageState extends State<ReservationTodayPage> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  String now = DateFormat('dd - MM - yyyy').format(DateTime.now());
  Future<dynamic>? _futureModel;
  bool _loading = false;
  int rangeCount = 0;
  List<dynamic> listData = [];
  late int _curPage;
  late int _perPage;

  final List<dynamic> _categoryList = [
    {'code': '', 'title': 'ทั้งหมด'},
    {'code': '1', 'title': 'จอง'},
    {'code': '2', 'title': 'เช็คอิน'},
    {'code': '4', 'title': 'เช็คอินโดยผู้ใช้'},
    {'code': '0', 'title': 'ยกเลิกการจอง'},
  ];

  String _selectedCategory = '';

  @override
  void initState() {
    _curPage = 1;
    _perPage = 9000;
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final DateTime _fromDate = DateTime.now().subtract(Duration(days: 3));
  final DateTime _toDate = DateTime.now().add(Duration(days: 3));

  _callRead() async {
    try {
      setState(() => _loading = true);
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';

      var dateStr =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

      // print(
      //     "$ondeURL/api/Booking/GetAllBooking?CurrentPage=$_curPage&RecordPerPage=$_perPage&CenterId=${profileMe['centerId']}&Status=$_selectedCategory");
      // logWTF(response.data);
      // print(_selectedCategory);

      if (_selectedCategory != '') {
        Dio dio = Dio();
        var response = await dio.get(
          '$ondeURL/api/Booking/GetAllBooking?CurrentPage=$_curPage&RecordPerPage=$_perPage&CenterId=${profileMe['centerId']}&key=bookingno&direction=descending&bookingdate=$dateStr&Status=$_selectedCategory',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );

        setState(() {
          listData = response.data['data'];
          listData =
              listData
                ..sort((a, b) => b['bookingno'].compareTo(a['bookingno']));
          _futureModel = Future.value(listData);
          _loading = false;
        });
        // } else {
        //   Dio dio = Dio();
        //   print('--------dateStr------>>> ${dateStr}');
        //   var response = await dio.get(
        //     '$ondeURL/api/Booking/GetAllBooking?CurrentPage=$_curPage&RecordPerPage=$_perPage&CenterId=${profileMe['centerId']}&key=bookingno&direction=descending&bookingdate',
        //     options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        //   );
        //   setState(() {
        //     listData = response.data['data'];
        //     listData =
        //         listData
        //           ..sort((a, b) => b['bookingno'].compareTo(a['bookingno']));
        //     _futureModel = Future.value(listData);
        //     _loading = false;
        //   });
        // }
      } else {
        Dio dio = Dio();
        var response = await dio.get(
          '$ondeURL/api/Booking/GetAllBooking?CurrentPage=$_curPage&RecordPerPage=$_perPage&CenterId=${profileMe['centerId']}&key=bookingno&direction=descending',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );

        List<dynamic> allData = response.data['data'];

        // ฟิลเตอร์เฉพาะวันที่อยู่ในช่วง -3ถึง +3 วัน
        List<dynamic> filteredData =
            allData.where((item) {
              DateTime bookingDate = DateTime.parse(item['bookingdate']);
              return bookingDate.isAfter(
                    _fromDate.subtract(const Duration(days: 1)),
                  ) &&
                  bookingDate.isBefore(_toDate.add(const Duration(days: 1)));
            }).toList();

        // เรียงลำดับตาม bookingno
        // filteredData.sort((a, b) => b['bookingno'].compareTo(a['bookingno']));
        filteredData.sort(
          (a, b) => DateTime.parse(
            b['bookingdate'],
          ).compareTo(DateTime.parse(a['bookingdate'])),
        );

        setState(() {
          listData = filteredData;
          _futureModel = Future.value(listData);
          _loading = false;
        });
      }
    } catch (e) {
      // logE(e);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFCF9FF),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0XFFFCF9FF),
        flexibleSpace: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 10,
            right: 10,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              _category(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      _selectedCategory == ''
                          ? Text(
                            'ข้อมูลวันที่ ${DateFormat("d ", "th").format(_fromDate)}-${DateFormat("d MMM yyyy", "th").format(_toDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFFB325F8).withOpacity(.4),
                            ),
                          )
                          : _selectedCategory == '1'
                          ? Text(
                            'ข้อมูลการจองวันนี้',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFFB325F8).withOpacity(.4),
                            ),
                          )
                          : SizedBox(),
                ),
              ),

              Expanded(
                child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: const ClassicFooter(
                    loadingText: ' ',
                    canLoadingText: ' ',
                    idleText: ' ',
                    idleIcon: Icon(
                      Icons.arrow_upward,
                      color: Colors.transparent,
                    ),
                  ),
                  controller: _refreshController,
                  onLoading: _onLoading,
                  child: _buildBooking(),
                ),
              ),
            ],
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBooking() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              // physics: const ClampingScrollPhysics(),
              physics: const BouncingScrollPhysics(),
              addAutomaticKeepAlives: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: snapshot.data.length,
              // separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder:
                  (_, __) => _buildItemBooking(snapshot.data.toList()[__]),
            );
          }
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildItemBooking(dynamic model) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => NewsForm(
        //       code: model['code'],
        //       model: model,
        //     ),
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(11)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFF9E9FF),
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          width: double.infinity,
          // height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(50),
                  //   child: loadingImageNetwork(
                  //     model['imageUrl'],
                  //     height: 50,
                  //     width: 50,
                  //   ),
                  // ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รหัสการจอง: ${model['bookingno']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${model['firstnameTh']} ${model['lastnameTh']} ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),

                          // Text(
                          //   'ทรัพยากรที่จอง',
                          //   style: TextStyle(
                          //       fontSize: 8,
                          //       fontFamily: 'Kanit',
                          //       fontWeight: FontWeight.w400,
                          //       color: Colors.black.withOpacity(0.35)),
                          // ),
                          // Row(
                          //   children: [
                          //     Container(
                          //       width: 8,
                          //       height: 8,
                          //       alignment: Alignment.center,
                          //       decoration: BoxDecoration(
                          //         color: const Color(0xFF7209B7),
                          //         borderRadius: BorderRadius.circular(100),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       '${model['title']}',
                          //       style: const TextStyle(
                          //         fontSize: 14,
                          //         fontFamily: 'Kanit',
                          //         fontWeight: FontWeight.w400,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                model['status'] == '0'
                                    ? Color(0xFFDDDDDD)
                                    : model['status'] == '1'
                                    ? Color(0xFF2539ED)
                                    : model['status'] == '4'
                                    ? Color(0xFFE70101)
                                    : model['status'] == '2'
                                    ? Color(0xFFE70101)
                                    : Color(0xFFDDDDDD),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          model['status'] == '0'
                              ? 'ยกเลิกการจอง'
                              : model['status'] == '1'
                              ? 'จอง'
                              : model['status'] == '4'
                              ? 'เช็คอินโดยผู้ใช้'
                              : model['status'] == '2'
                              ? 'เช็คอิน'
                              : 'ยกเลิกการจอง',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color:
                                model['status'] == '0'
                                    ? Colors.red
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: Color(0XFF7209B7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _convertDate(model['bookingdate']),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Color(0XFF7209B7),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${model['starttime']} - ${model['endtime']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (model['status'] == '1')
                        InkWell(
                          onTap: () {
                            model['status'] == "1"
                                ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ReservationEditPage(
                                          title: 'การจองใช้งานวันนี้',
                                          model: model,
                                        ),
                                  ),
                                ).then((value) => _callRead())
                                : _dialogEdit();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 17,
                            ),
                            // color: const Color(0xFFF1F1F1),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F1F1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Text(
                              'แก้ไข',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 1, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 7),
                      if (model['status'] == '1')
                        InkWell(
                          onTap: () {
                            _checkIn(model);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 12,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7209B7),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Text(
                              'เช็คอิน',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _convertDate(String date) {
  //   return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  // }
  _convertDate(String date) {
    DateTime parsedDate = DateTime.parse(date); // แปลง String เป็น DateTime
    var thaiYear = parsedDate.year + 543; // แปลงปีเป็น พ.ศ.

    // กำหนด locale เป็นภาษาไทยและแปลงวันที่เป็นเดือนภาษาไทย
    var formattedDate = DateFormat('dd MMMM', 'th_TH').format(parsedDate);

    // ส่งวันที่ที่แปลงเป็น 07 ตุลาคม 2567
    return '$formattedDate $thaiYear';
  }

  void _setData() {
    _futureModel = Future.value([
      {
        'title': 'คอมพิวเตอร์ A1',
        'timeStart': '08:00',
        'timeEnd': '10:00',
        'imageUrl':
            'https://raot.we-builds.com/raot-document/images/flutter/flutter_224558086.jpg',
        'firstName': 'aaa',
        'lastName': 'AAA',
        'isActive': true,
      },
      {
        'title': 'คอมพิวเตอร์ A2',
        'timeStart': '10:00',
        'timeEnd': '12:00',
        'imageUrl':
            'https://lh3.googleusercontent.com/a/AGNmyxYq9g6RPNA79yJNtV8QifBrXXef1c_QUf36jxhc=s96-c',
        'firstName': 'bbb',
        'lastName': 'BBB',
        'isActive': true,
      },
      {
        'title': 'คอมพิวเตอร์ A3',
        'timeStart': '12:00',
        'timeEnd': '14:00',
        'imageUrl':
            'https://profile.line-scdn.net/0hslJH-Px-LENnMT4jintSPBdhLylEQHVRGFdqIwAwcHJfCG4TGwAzdgcwendYA2oSTwRjLQYxJyBrIlsleWfQd2ABcnRdAGwdTlBqrA',
        'firstName': 'ccc',
        'lastName': 'CCC',
        'isActive': true,
      },
      {
        'title': 'คอมพิวเตอร์ A4',
        'timeStart': '14:30',
        'timeEnd': '15:00',
        'imageUrl':
            'https://profile.line-scdn.net/0h35FKsrA-bBprMniVq8YSZRtib3BIQzUIElUkdQs3Zn8GACtLE1AqfAswNn5TACpNQAYhKFg7NC1nIRt8dWSQLmwCMi1RAyxEQlMq9Q',
        'firstName': 'ddd',
        'lastName': 'DDD',
        'isActive': true,
      },
      {
        'title': 'คอมพิวเตอร์ A5',
        'timeStart': '15:00',
        'timeEnd': '16:00',
        'imageUrl':
            'https://profile.line-scdn.net/0hyJaQlS_HJmVMKDO3aMpYGjx4JQ9vWX93ZU5oA3F4L1B2GzFmNx1uBC4qfVciHTZhaEdhU3gpeQJAO1EDUn7aUUsYeFJ2GWY7ZUlgig',
        'firstName': 'eee',
        'lastName': 'EEE',
        'isActive': true,
      },
      {
        'title': 'คอมพิวเตอร์ A6',
        'timeStart': '16:00',
        'timeEnd': '17:30',
        'imageUrl':
            'https://profile.line-scdn.net/0hqvspX5EFLlleCTvu1y9QJi5ZLTN9eHdLdGYxPzgMcG9iamoNIDpkamsPJ240P2tbJW1oOmMKIjxSGlk_QF_SbVk5cG5kOG4Hd2hotg',
        'firstName': 'fff',
        'lastName': 'FFF',
        'isActive': true,
      },
    ]);
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      _perPage += 9000;
    });
    await _callRead();
    // await Future.delayed(const Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  _dialogEdit() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext context) => WillPopScope(
            onWillPop: () => Future.value(false),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SizedBox(
                  height: 127,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'ไม่สามารถแก้ไขได้เนื่องจากยังไม่ได้ทำการจอง',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => {Navigator.pop(context, false)},
                        child: Container(
                          height: 40,
                          width: 95,
                          decoration: BoxDecoration(
                            color: Color(0xFF7A4CB1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  _category() {
    return Container(
      color: const Color(0XFFFCF9FF),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: SizedBox(
        height: 25,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, __) => _itemCategory(_categoryList[__]),
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemCount: _categoryList.length,
        ),
      ),
    );
    // SizedBox(height: 15),
    // Container(
    //   color: Colors.white,
    //   child: _list(),
    // ),
  }

  Widget _itemCategory(model) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = model['code'].toString();
          _curPage = 1;
          _perPage = 9000;
        });
        _callRead();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color:
              _selectedCategory == model['code']
                  ? const Color(0xFFB325F8)
                  : const Color(0xFFB325F8).withOpacity(.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 1,
            style: BorderStyle.solid,
            color:
                _selectedCategory == model['code']
                    ? const Color(0xFFB325F8)
                    : const Color(0xFFB325F8).withOpacity(.1),
          ),
        ),
        child: Text(
          '${model['title']}',
          style: TextStyle(
            color:
                _selectedCategory == model['code']
                    ? Colors.white
                    : const Color(0xFFB325F8).withOpacity(.4),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  _checkIn(dynamic param) async {
    try {
      print('_checkIn');
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';

      var data = {"bookingNo": param['bookingno'], "status": "4"};
      final String baseUrl = '$ondeURL';

      print(data.toString());
      print('${baseUrl}/api/Booking/UserCheckin');

      Response response = await Dio().put(
        '${baseUrl}/api/Booking/UserCheckin',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      _callRead();
      _dialogCheckin();
    } on DioError catch (e) {
      Fluttertoast.showToast(msg: e.response!.data['message']);
    }
  }

  _dialogCheckin() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext context) => WillPopScope(
            onWillPop: () => Future.value(false),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 127,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'เช็คอิน',
                        style: TextStyle(
                          color: Color(0xFF7A4CB1),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'ทำการเช็คอินเรียบร้อย',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        // Navigator.of(context).pushAndRemoveUntil(
                        //   MaterialPageRoute(
                        //     builder: (context) => const Menu(),
                        //   ),
                        //   (Route<dynamic> route) => false,
                        // ),
                        child: Container(
                          height: 40,
                          width: 95,
                          decoration: BoxDecoration(
                            color: Color(0xFF7A4CB1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ตกลง',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;

  Image img1 = Image.asset('logo.png');
  Image img2 = Image.asset('logo.png');

  String _liveness = "nil";

  void _faceRecognition() async {
    try {
      final result = await regula.FaceSDK.instance.startFaceCapture();

      final capture = result.image;
      if (capture == null || capture.image.isEmpty) return;

      _setImage(true, capture.image, capture.imageType);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FaceAuthenticatePage(image: capture.image),
        ),
      );
    } catch (e) {
      print("Face recognition error: $e");
    }
  }

  void _setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImage = regula.MatchFacesImage(imageFile, type);
    setState(() {
      if (first) {
        image1 = faceImage;
        img1 = Image.memory(imageFile);
        _liveness = "nil";
        _loading = true;
      } else {
        image2 = faceImage;
        img2 = Image.memory(imageFile);
      }
    });
  }
}
