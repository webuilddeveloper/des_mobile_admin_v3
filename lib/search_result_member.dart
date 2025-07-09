import 'dart:async';
import 'package:des_mobile_admin_v3/member_details.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'config.dart';

// ignore: must_be_immutable
class SearchResultMemberPage extends StatefulWidget {
  SearchResultMemberPage({super.key, this.txtSearch});
  late _SearchResultMemberPageState homeCentralPageState;
  String? txtSearch;

  @override
  State<SearchResultMemberPage> createState() => _SearchResultMemberPageState();

  getState() => homeCentralPageState;
}

class _SearchResultMemberPageState extends State<SearchResultMemberPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // late Future<dynamic> _futureProfile;
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProfile;

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtIdCard = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtUserName = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  int selectedMenuIndex = 0;

  dynamic myProcessModel = {
    "jobStart": "08-Api-2020",
    "period": "1 ปี 4 เดือน",
    "operatingTime": "00 hr",
    "remainingLeave": "9 วัน",
    "activityAll": <dynamic>[
      {
        "id": 0,
        "code": "businessLeave",
        "title": "ลากิจ",
        "type": "leave",
        "count": 2,
        "activityLatest": "02-may-2020",
        "imageUrl": "assets/images/ลากิจ.png",
      },
      {
        "id": 1,
        "code": "sickLeave",
        "title": "ลาป่วย",
        "type": "leave",
        "count": 2,
        "activityLatest": "02-may-2020",
        "imageUrl": "assets/images/ลาป่วย.png",
      },
      {
        "id": 2,
        "code": "takeAnnualLeave",
        "title": "ลาพักร้อน",
        "type": "leave",
        "count": 2,
        "activityLatest": "02-may-2020",
        "imageUrl": "assets/images/ลาพักร้อน.png",
      },
      {
        "id": 3,
        "code": "absentFromWork",
        "title": "ขาดงาน",
        "type": "absent",
        "count": 1,
        "activityLatest": "02-may-2020",
        "imageUrl": "assets/images/ขาดงาน.png",
      },
      {
        "id": 4,
        "code": "lateToWork",
        "title": "เข้่างานสาย",
        "type": "work",
        "count": 1,
        "activityLatest": "02-may-2020",
        "imageUrl": "assets/images/เข้างานสาย.png",
      },
    ]
  };

  List<dynamic> menu = [
    {"id": 0, "code": "", "title": "ทั้งหมด"},
    {"id": 1, "code": "leave", "title": "การลา"},
    {"id": 2, "code": "work", "title": "การทำงาน"},
  ];

  List<dynamic> userResult = [
    {
      "id": 0,
      "code": "A0",
      "userCode": "M12345678",
      "name": "นางขยัน หมั่นเพียร",
      "memberType": 1,
      "memberTypeTitle": "ประชาชนทั่วไป",
      "idCard": "1101222345667",
      "ageRange": "20-29",
      "email": "testemail@gmail.com",
      "phone": "081-123-4567",
      "imageUrl": "assets/images/user_mock.png"
    },
    {
      "id": 1,
      "code": "A1",
      "userCode": "M12345678",
      "name": "นายสมชาย งอกงาม",
      "memberType": 2,
      "memberTypeTitle": "เกษตรกร",
      "idCard": "1101222345667",
      "ageRange": "30-39",
      "email": "testemail@gmail.com",
      "phone": "081-123-4567",
      "imageUrl": "assets/images/user_mock_2.png"
    },
    {
      "id": 2,
      "code": "A2",
      "userCode": "M12345678",
      "name": "ด.ญ.รื่นรมย์ เรียนดี",
      "memberType": 3,
      "memberTypeTitle": "นักเรียน/นักศึกษา",
      "idCard": "1101222345667",
      "ageRange": "10-19",
      "email": "testemail@gmail.com",
      "phone": "081-123-4567",
      "imageUrl": "assets/images/user_mock_3.png"
    },
    {
      "id": 3,
      "code": "A3",
      "userCode": "M12345678",
      "name": "นางขยัน หมั่นเพียร",
      "memberType": 1,
      "memberTypeTitle": "ประชาชนทั่วไป",
      "idCard": "1101222345667",
      "ageRange": "20-29",
      "email": "testemail@gmail.com",
      "phone": "081-123-4567",
      "imageUrl": "assets/images/user_mock.png"
    },
    {
      "id": 4,
      "code": "A4",
      "userCode": "M12345678",
      "name": "นายสมชาย งอกงาม",
      "memberType": 2,
      "memberTypeTitle": "เกษตรกร",
      "idCard": "1101222345667",
      "ageRange": "30-39",
      "email": "testemail@gmail.com",
      "phone": "081-123-4567",
      "imageUrl": "assets/images/user_mock_2.png"
    },
    {
      "id": 5,
      "code": "A5",
      "userCode": "M12345678",
      "name": "ด.ญ.รื่นรมย์ เรียนดี",
      "memberType": 3,
      "memberTypeTitle": "นักเรียน/นักศึกษา",
      "ageRange": "10-19",
      "email": "testemail@gmail.com",
      "phone": "081-123-4567",
      "imageUrl": "assets/images/user_mock_3.png"
    },
  ];

  late dynamic _model;
  late bool _loading;

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    _model = [];
    _loading = true;
    txtFirstName = TextEditingController(text: '');
    _callRead();

    super.initState();
  }

  @override
  void dispose() {
    txtFirstName.dispose();
    super.dispose();
  }

  _callRead() async {
    try {
      Dio dio = Dio();
      var response = await dio.post('$serverUrl/dcc-api/m/register/member/read',
          data: {'keySearch': widget.txtSearch});

      logWTF(response.data['objectData']);

      // return await Future.value(response.data['objectData']);
      setState(() {
        setState(() => _loading = false);
        _model = response.data['objectData'];
      });
    } catch (e) {
      logE(e);
      setState(() => _loading = false);
      Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
    }
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

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
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 20),
          //     child: InkWell(
          //       onTap: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (contex) => RegisterMemberMenuPage(),
          //           ),
          //         );
          //       },
          //       child: Container(
          //         width: 30,
          //         height: 30,
          //         decoration: const BoxDecoration(
          //             color: Color(0xFF7209B7),
          //             borderRadius: BorderRadius.all(Radius.circular(7))),
          //         child: const Icon(
          //           Icons.add,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   )
          // ],
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
            'ค้นหาสมาชิก',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_model.length == 0 && !_loading) const Text('ไม่พบข้อมูล'),
            Expanded(
              child: ListView.separated(
                itemCount: _model.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (_, __) => _buildBoxResult(_model[__]),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ค้นหาสมาชิก',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                flex: 30,
                child: Container(
                  width: double.infinity,
                  // height: 41,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 19, vertical: 12),
                    width: double.infinity,
                    // height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDEFFF),
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: Text(
                      'ค้นหาชื่อผู้ใช้งาน',
                      style: TextStyle(
                          color: Color(0xFF7209B7).withOpacity(0.38),
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Flexible(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  // height: 40,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xFF7209B7),
                  ),
                  child: Image.asset(
                    "assets/images/search.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxResult(param) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (contex) => MemberDetailsPage(
              model: param,
            ),
          ),
        ).then((value) {
          logWTF('model');
          _callRead();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
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
              const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 25),
          width: double.infinity,
          // height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedImageWidget(
                    imageUrl: '${param["imageUrl"]}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    padding: 10,
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${param['firstName']} ${param['lastName']}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17, vertical: 3),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Color(0xFFD9D9D9)),
                      child: Text(
                        '${param["email"] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Image.asset(
              //       "assets/images/edit.png",
              //       // fit: BoxFit.contain,
              //       width: 20,
              //       height: 20,
              //     ),
              //     // SizedBox(width: 5,),
              //     Image.asset(
              //       "assets/images/trashcan.png",
              //       // fit: BoxFit.contain,
              //       width: 20,
              //       height: 20,
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
