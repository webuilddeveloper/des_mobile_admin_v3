import 'dart:async';
import 'dart:convert';

import 'package:des_mobile_admin_v3/member_details.dart';
import 'package:des_mobile_admin_v3/register_member_menu.dart';
import 'package:des_mobile_admin_v3/search_result_member.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'config.dart';

// ignore: must_be_immutable
class RegisterMenuPage extends StatefulWidget {
  RegisterMenuPage({super.key, this.changePage});
  late _RegisterMenuPageState homeCentralPageState;
  Function? changePage;

  @override
  State<RegisterMenuPage> createState() => _RegisterMenuPageState();

  getState() => homeCentralPageState;
}

class _RegisterMenuPageState extends State<RegisterMenuPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  int _toDayUser = 0;
  int _totalUser = 0;

  TextEditingController txtSearchController = TextEditingController();
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

  Future<dynamic> newUsers = Future.value([]);
  late dynamic _profileData;

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
            'ทะเบียนสมาชิก',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            _buildDashBoard(),
            const SizedBox(
              height: 20,
            ),
            _buildBoxSearch(),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ลงทะเบียนใหม่วันนี้',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(child: _newUsers()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ศูนย์ดิจิทัลชุมชน',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7209B7)),
          ),
          Text(
            '${_profileData?['province'] ?? ''} ${_profileData?['centerName'] ?? ''}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000)),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: const BoxDecoration(
                    // color: Color(0xFF7209B7),
                    gradient: LinearGradient(
                        colors: [
                          Color(0xFF760CB7),
                          Color(0xFFBB36AE),
                        ],
                        stops: [
                          0,
                          1
                        ],
                        begin: FractionalOffset.topLeft,
                        end: FractionalOffset.bottomRight,
                        tileMode: TileMode.repeated),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDAB8E9),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Image.asset(
                                "assets/images/users_register_menu.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Text(
                              'สมาชิกทั้งหมด',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF)),
                            ),
                            Text(
                              _totalUser.toString(),
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFFFFF)),
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
                              color: Colors.white.withOpacity(0.10)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 249, 233, 255),
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                              color: const Color(0xFFDAB8E9),
                              borderRadius: BorderRadius.circular(5)),
                          child: Image.asset(
                            "assets/images/user_register_menu.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Text(
                          'สมาชิกวันนี้',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8414B5)),
                        ),
                        Text(
                          _toDayUser.toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8414B5)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (contex) => SearchResultMemberPage(
                      txtSearch: txtSearchController.text),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 30,
                  child: Container(
                    // height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 249, 233, 255),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 5, right: 5, top: 10),
                      width: double.infinity,
                      height: 41,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFCEA8F3)),
                        controller: txtSearchController,
                        decoration: CusInpuDecoration.base(
                          context,
                          hintText: 'ค้นหาชื่อสกุลหรือเลขบัตรประชาชน',
                        ),
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
          ),
        ],
      ),
    );
  }

  Widget _newUsers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<dynamic>(
        future: newUsers,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                child: Text('ไม่พบข้อมูล'),
              );
            } else {
              print('value >>>>>>>> ${snapshot.data}');

              return ListView.builder(
                shrinkWrap: true,
                // physics: const ClampingScrollPhysics(),
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 20,
                //   vertical: 10,
                // ),
                itemCount: snapshot.data.length,
                // separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (_, index) =>
                    // _buildProblemResult(snapshot.data.toList()[__]),

                    InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (contex) => MemberDetailsPage(
                          model: snapshot.data[index],
                        ),
                      ),
                    ).then((value) => _callRead());
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
                      padding: const EdgeInsets.only(
                          top: 12, bottom: 12, left: 16, right: 25),
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
                                imageUrl: '${snapshot.data[index]["imageUrl"]}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
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
                                  '${snapshot.data[index]['firstName']} ${snapshot.data[index]['lastName']}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17, vertical: 3),
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      color: Color(0xFFD9D9D9)),
                                  child: Text(
                                    '${snapshot.data[index]["email"] ?? '-'}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400),
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
                          //     const SizedBox(
                          //       width: 5,
                          //     ),
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
        // ),
      ),

      // for (var i = 0; i < newUsers.length; i++)

      // SizedBox(
      //   height: MediaQuery.of(context).size.height,
      //   child: ListView.separated(
      //     scrollDirection: Axis.vertical,
      //     separatorBuilder: (context, index) => const SizedBox(height: 20),
      //     itemCount: newsUser.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return
      //       Container(
      //         decoration: const BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.all(Radius.circular(11)),
      //           boxShadow: [
      //             BoxShadow(
      //               color: Color(0xFFF9E9FF),
      //               blurRadius: 10,
      //               offset: Offset(0, 5),
      //             )
      //           ],
      //         ),
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(
      //               horizontal: 20, vertical: 15),
      //           width: double.infinity,
      //           // height: 60,
      //           decoration: const BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.all(Radius.circular(11)),
      //           ),
      //           child: InkWell(
      //             onTap: () {},
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 Expanded(
      //                     flex: 7,
      //                     child: Row(
      //                       children: [
      //                         Flexible(
      //                           child: Container(
      //                             // padding: const EdgeInsets.all(7),
      //                             width: 80,
      //                             // height: 40,
      //                             decoration: const BoxDecoration(
      //                                 shape: BoxShape.circle),
      //                             child: Image.asset(
      //                               "assets/images/user_mock.png",
      //                               fit: BoxFit.contain,
      //                             ),
      //                           ),
      //                         ),
      //                         SizedBox(width: 10,),
      //                         Expanded(
      //                           child: Column(
      //                             crossAxisAlignment: CrossAxisAlignment.start,
      //                             children: [
      //                               Text(
      //                                 newsUser[index]["fullName"],
      //                                 style: const TextStyle(
      //                                   fontSize: 14,
      //                                   fontWeight: FontWeight.w400
      //                                 ),
      //                               ),
      //                               Container(
      //                                 padding: const EdgeInsets.symmetric(horizontal: 17,vertical: 5),
      //                                 decoration: const BoxDecoration(
      //                                   borderRadius: BorderRadius.all(Radius.circular(30)),
      //                                   color: Color(0xFFD9D9D9)
      //                                 ),
      //                                 child: const Text(
      //                                   "สมาชิกทั่วไป"
      //                                 ),
      //                               )
      //                             ],
      //                           )
      //                         )
      //                       ],
      //                     )),
      //                 Expanded(
      //                     flex: 3,
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.end,
      //                       children: const [
      //                         Icon(
      //                           Icons.arrow_forward_ios,
      //                           size: 20,
      //                         )
      //                       ],
      //                     ))
      //               ],
      //             ),
      //           ),
      //         ),
      //       );

      //     },
      //   ),
      // ),
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    _profileData = {};
    _getProfile();
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProfile() async {
    var proflieMe = await ManageStorage.readDynamic('profileMe') ?? '';
    var staffProfileData =
        await ManageStorage.readDynamic('staffProfileData') ?? '';

    // data from DCC
    proflieMe['roleName'] = staffProfileData?['roleName'] ?? '';
    proflieMe['centerName'] = staffProfileData?['centerName'] ?? '';

    setState(() {
      _profileData = proflieMe;
    });
  }

  _callRead() async {
    // Dio dio = Dio();
    try {
      var response = await Dio()
          .post('$serverUrl/dcc-api/m/register/read/today/user', data: {});
      setState(() {
        newUsers = Future.value(response.data['objectData']);
      });
    } catch (e) {}

    try {
      var responseCount = await Dio()
          .post('$serverUrl/dcc-api/m/register/read/user/count', data: {});
      setState(() {
        _totalUser = responseCount.data['objectData']['total'];
        _toDayUser = responseCount.data['objectData']['today'];
      });
    } catch (e) {}
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }
}
