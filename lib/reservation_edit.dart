import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'shared/secure_storage.dart';

class ReservationEditPage extends StatefulWidget {
  const ReservationEditPage({super.key, required this.title, this.model});
  final String title;
  final dynamic model;

  @override
  State<ReservationEditPage> createState() => _ReservationEditPageState();
}

final RefreshController _refreshController =
    RefreshController(initialRefresh: false);

String now = DateFormat('dd - MM - yyyy').format(DateTime.now());

class _ReservationEditPageState extends State<ReservationEditPage> {
  late String startTime = widget.model['starttime'] ?? '00';
  late String endTime = widget.model['endtime'] ?? '00';

  Future<dynamic>? get _futureModel => Future.value(widget.model);

  late String timeNew;
  bool _loadingSubmit = false;

  // late TimeOfDay startTime;
  // late TimeOfDay endTime;

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    super.initState();
  }

  _selectTime(String time) async {
    dynamic timeSplit = time.split(':');
    var a = TimeOfDay(
        hour: int.parse(timeSplit[0]), minute: int.parse(timeSplit[1]));
    TimeOfDay? newTime = await showTimePicker(context: context, initialTime: a);
    if (newTime == null) return null;
    final hours = newTime.hour.toString().padLeft(2, '0');
    final min = newTime.minute.toString().padLeft(2, "0");
    return '$hours:$min';
  }

  _postpone() async {
    try {
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';
      var subDate = DateFormat('dd-MM-yyyy')
          .format(DateTime.now())
          .replaceAll(' ', '')
          .split('-');
      String tempDate = '${subDate[2]}-${subDate[1]}-${subDate[0]}T00:00:00';

      int sth = int.parse(startTime.split(':')[0]);
      int edh = int.parse(endTime.split(':')[0]);

      int stm = int.parse(startTime.split(':')[1]);
      int edm = int.parse(endTime.split(':')[1]);
      // check hours
      if (sth > edh) {
        return Fluttertoast.showToast(
            msg: 'เวลาเริ่มต้นและเวลาสิ้นสุด ไม่ถูกต้อง');
      }

      // check minutes
      if (sth == edh && stm >= edm) {
        return Fluttertoast.showToast(
            msg: 'เวลาเริ่มต้นและเวลาสิ้นสุด ไม่ถูกต้อง');
      }
      var data = {
        "bookingDate": tempDate,
        "bookingno": widget.model['bookingno'],
        "centerId": widget.model['centerId'],
        "startTime": startTime,
        "endTime": endTime,
        "phone": widget.model['phone'] ?? '',
        "desc": "",
        "remark": ""
      };

      setState(() => _loadingSubmit = true);
      Response response = await Dio().put(
        '$ondeURL/api/Booking/PostponeBooking',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      logWTF('data');

      logWTF(response);

      _dialogPostpone();
      setState(() => _loadingSubmit = false);
    } on DioError catch (e) {
      logWTF(e);
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: e.response!.data['message']);
    }
  }

  _dialogPostpone() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
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
                  const Text(
                    'เลื่อนจองสำเร็จ',
                    style: TextStyle(
                      color: Color(0xFF7A4CB1),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'ทำการเลื่อนการจองใช้บริการเรียบร้อย',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
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
                        color: const Color(0xFF7A4CB1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
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
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                    ),
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
                // Center(
                //   child: Text(
                //     now,
                //     style: const TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: _buildBooking(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_loadingSubmit)
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
      ),
    );
  }

  _cancelBooking() async {
    try {
      setState(() => _loadingSubmit = true);
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';
      Response response = await Dio().put(
        '$ondeURL/api/Booking/Cancel?bookingNo=${widget.model['bookingno']}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      setState(() => _loadingSubmit = false);

      if (response.data['success']) {
        _dialogCancelSuccess();
      } else {
        Fluttertoast.showToast(msg: response.data['errorMessage']);
      }
    } on DioError catch (e) {
      setState(() => _loadingSubmit = false);
      var err = e.toString();
      if (e.response!.statusCode != 200) {
        err = e.response!.data['message'];
      }
      Fluttertoast.showToast(msg: err);
    }
  }

  _dialogCancelBooking() {
    var bookingDate = DateFormat('dd/MM/yyyy')
        .format(DateTime.parse(widget.model['bookingdate']));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                children: [
                  const Text(
                    'ยกเลิกการจอง',
                    style: TextStyle(
                      color: Color(0xFF7A4CB1),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'ท่านยืนยันที่จะทำการยกเลิกการจองใช้บริการในวันที่ $bookingDate ใช่หรือไม่',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7A4CB1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'ย้อนกลับ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _cancelBooking();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF707070),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'ยืนยัน',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _dialogCancelSuccess() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
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
                  const Text(
                    'ยกเลิกจองสำเร็จ',
                    style: TextStyle(
                      color: Color(0xFF7A4CB1),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'ทำการยกเลิกการจองใช้บริการเรียบร้อย',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
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
                        color: const Color(0xFF7A4CB1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBooking() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return const Center(
              child: Text('ไม่พบข้อมูล'),
            );
          } else {
            return _buildItemBooking(snapshot.data);
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
    );
  }

  Widget _buildItemBooking(dynamic model) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 20),
      // margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(11)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF9E9FF),
            blurRadius: 5,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Container(
        padding:
            const EdgeInsets.only(top: 22, bottom: 20, left: 16, right: 16),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   '${model['title']}',
            //   style: const TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.w700,
            //   ),
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            // ),
            const SizedBox(
              height: 19,
            ),
            const Text(
              'ข้อมูลการจอง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                    // borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                  'assets/images/user_register_menu.png',
                  width: 16,
                )),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    '${model['firstnameTh']} ${model['lastnameTh']} ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 13,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                          // borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                        'assets/images/calendar.png',
                        width: 16,
                      )),
                      const SizedBox(width: 10),
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
                ),
                Expanded(
                  child: Row(
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
                )
              ],
            ),
            const SizedBox(
              height: 27,
            ),
            const Text(
              'แก้ไขการจอง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 11,
            ),
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: InkWell(
                    onTap: () {
                      // setState(() {
                      // });
                      setState(() {
                        _selectTime(model['starttime']).then(
                          (value) => {
                            setState(() {
                              startTime = value;
                              print(
                                  '---------startTime--------------${startTime}');
                            }),
                          },
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 10),
                      decoration: const BoxDecoration(
                          color: Color(0xFFFBE8FF),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Icon(
                              Icons.access_time,
                              size: 35,
                              color: Color(0XFF7209B7),
                            ),
                          ),
                          Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  Text(
                                    'เวลาเริ่มต้น',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black.withOpacity(0.60)),
                                  ),
                                  Text(
                                    startTime,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 40,
                ),
                Expanded(
                    flex: 8,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectTime(model['endtime']).then(
                            (value) => {
                              setState(() {
                                endTime = value;
                                print(
                                    '---------endTime--------------${endTime}');
                              }),
                            },
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 10),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFBE8FF),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Icon(
                                Icons.access_time,
                                size: 35,
                                color: Color(0XFF7209B7),
                              ),
                            ),
                            Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Text(
                                      'เวลาสิ้นสุด',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Colors.black.withOpacity(0.60)),
                                    ),
                                    Text(
                                      endTime,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    )),
              ],
            ),

            const SizedBox(
              height: 28,
            ),
            InkWell(
              onTap: (startTime != widget.model['starttime'] ||
                      endTime != widget.model['endtime'])
                  ? () {
                      _postpone();
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                width: double.infinity,
                // height: 60,
                decoration: BoxDecoration(
                  color: (startTime != widget.model['starttime'] ||
                          endTime != widget.model['endtime'])
                      ? const Color(0xFF7209B7)
                      : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const SizedBox(
                  // height: 60,
                  child: Text(
                    'เลื่อนการจอง',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                // _buildDialogCancel();
                _dialogCancelBooking();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Theme.of(context).primaryColor),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x40F3D2FF),
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  'ยกเลิกการจอง',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
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

  @override
  void dispose() {
    super.dispose();
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _buildDialogCancel() {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(11.0))),
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'ยกเลิกการจอง',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF7209B7),
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                        child: Text(
                          'คุณยืนยันที่จะยกเลิกการจองนี้\nใช่หรือไม่?',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          // height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7209B7),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const SizedBox(
                            // height: 60,
                            child: Text(
                              'ยืนยัน',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 35,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
