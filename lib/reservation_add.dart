import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'config.dart';
import 'menu.dart';
import 'shared/mock_data.dart';

class ReservationAddPage extends StatefulWidget {
  const ReservationAddPage({super.key, this.model, this.type});

  final dynamic model;
  final dynamic type;

  @override
  State<ReservationAddPage> createState() => _ReservationAddPageState();
}

class _ReservationAddPageState extends State<ReservationAddPage> {
  late bool _loadingSubmit;
  late bool _loadingData;
  late String _centerName;
  late int _centerId;

  @override
  void initState() {
    _loadingSubmit = false;
    _loadingData = false;
    _centerName = '';
    _centerId = 0;
    _callRead();
    super.initState();
  }

  _callRead() async {
    var user = await ManageStorage.readDynamic('staffProfileData') ?? '';
    var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';

    setState(() {
      _centerName = user?['centerName'] ?? '';
      _centerId = profileMe['centerId'];
    });
  }

  _save() async {
    try {
      setState(() => _loadingSubmit = true);
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';
      var data = {
        "bookingDate": widget.model['bookingDate'],
        "bookingSlotType": widget.model['bookingSlotType'],
        "centerId": _centerId,
        "startTime": widget.model['startTime'],
        "endTime": widget.model['endTime'],
        "userEmail": widget.model['userEmail'],
        "userid": widget.model['userid'],
        "phone": widget.model['phone'],
        "desc": widget.model['desc'],
        "remark": widget.model['remark'],
        'otherCategoryRemark': widget.model['otherCategoryRemark']
      };
      // logWTF(accessToken);
      logWTF(data);

      Response response = await Dio().post(
        '$ondeURL/api/Booking/Booking/mobile',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      setState(() => _loadingSubmit = false);

      print('----- hello ------');

      if (response.statusCode == 200) {
        _dialogBookingSuccess();
      } else {
        Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
      }
    } on DioError catch (e) {
      print('----- catch ------');
      logE(e);
      var err = e.toString();
      setState(() => _loadingSubmit = false);
      if (e.response!.statusCode != 200) {
        err = e.response!.data?['message'] ?? e.toString();
      }
      print('----- catch ------' + e.response.toString());
      Fluttertoast.showToast(msg: err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFFfdf9ff)),
        ),
        centerTitle: true,
        title: const Text(
          'เพิ่มการจองทรัพยากร',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
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
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'โปรดตรวจสอบการจองของท่าน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  color: Color(0x40F3D2FF),
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextItem(
                      title: 'อีเมล',
                      value: widget.model?['userEmail'] ?? '',
                    ),
                    const SizedBox(height: 15),
                    _buildTextItem(
                      title: 'เบอร์โทรศัพท์',
                      value: widget.model?['phone'] ?? '',
                    ),
                    const SizedBox(height: 15),
                    _buildTextItem(
                      title: 'ศูนย์ดิจิทัลชุมชนที่จองใช้บริการ',
                      value: _centerName,
                      // value: _address,
                    ),
                    const SizedBox(height: 15),
                    _buildTextItem(
                      title: 'วันที่จอง',
                      value: dateThai(widget.model['date']),
                    ),
                    const SizedBox(height: 15),
                    _buildTextItem(
                      title: 'เวลาที่จอง',
                      value:
                          '${widget.model['startTime']} - ${widget.model['endTime']} น. (${widget.model['hours']} ชม.)',
                    ),
                    const SizedBox(height: 15),
                    _buildTextItem(
                      title: 'รูปแบบการจอง',
                      value: widget.model['bookingSlotTypeName'],
                    ),
                  ],
                ),
                if (_loadingData)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () async {
              await _save();
            },
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _loadingSubmit
                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(7),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x40F3D2FF),
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  const Text(
                    'ยืนยันการจอง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  if (_loadingSubmit)
                    const Positioned.fill(
                      child: Center(
                        child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
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
                'แก้ไขการจอง',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () async {
              _buildDialogCancel();
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
    );
  }

  _buildTextItem({String title = '', String value = ''}) {
    return RichText(
      text: TextSpan(
        text: '$title \n',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFFA06CD5),
          fontFamily: 'Kanit',
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
              fontFamily: 'Kanit',
            ),
          ),
        ],
      ),
    );
  }

  _dialogBookingSuccess() {
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
                    'จองสำเร็จ',
                    style: TextStyle(
                      color: Color(0xFF7A4CB1),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'ทำการจองใช้บริการเรียบร้อย',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Menupage(),
                        ),
                      );
                    },
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
