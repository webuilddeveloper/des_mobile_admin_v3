import 'dart:async';
import 'package:des_mobile_admin_v3/report_follow.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/no_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'config.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureModelTicketSummary;
  Future<dynamic>? _futureProblemModel;
  Future<dynamic>? _futureFollowModel;

  TextEditingController txtSearch = TextEditingController();

  int selectedMenuIndex = 0;
  String selectProvince = "1";
  String selectDistrict = "1";
  String selectSubDistrict = "1";
  bool _loading = false;
  dynamic listData;
  dynamic listDataTrack;
  dynamic modellistDataTrack;

  dynamic reportModel = {
    "ticketCount": 0,
    "ticketContinue": 0,
    "ticketDone": 0,
    "ticketInProgress": 0,
  };
  String _selectedDashboard = '510';

  // Future<dynamic> _futureProblemModel = Future.value([
  //   {
  //     "id": 0,
  //     "code": "A0",
  //     "title": "แจ้งปัญหาคอมพิวเตอร์ A3",
  //     "description":
  //         "แจ้งปัญหาคอมพิวเตอร์ A3 ศูนย์ดิจิทัลสายไหม มีปัญหา ไม่สามารถใช้งานได้ ",
  //     "memberId": "0012345",
  //     "startDate": "09-07-2566",
  //     "finishDate": "09-07-2566",
  //     "image": <dynamic>[
  //       {"imageUrl": "assets/images/problem.png"},
  //       {"imageUrl": "assets/images/problem_2.png"},
  //       {"imageUrl": "assets/images/problem_3.png"},
  //       {"imageUrl": "assets/images/problem.png"},
  //       {"imageUrl": "assets/images/problem_2.png"},
  //       {"imageUrl": "assets/images/problem_3.png"},
  //     ]
  //   },
  //   {
  //     "id": 1,
  //     "code": "A1",
  //     "title": "แจ้งปัญหาคอมพิวเตอร์ A3",
  //     "description":
  //         "แจ้งปัญหาคอมพิวเตอร์ A3 ศูนย์ดิจิทัลสายไหม มีปัญหา ไม่สามารถใช้งานได้ ",
  //     "memberId": "0012345",
  //     "startDate": "09-07-2566",
  //     "finishDate": "09-07-2566",
  //     "image": <dynamic>[
  //       {"imageUrl": "assets/images/problem.png"},
  //       {"imageUrl": "assets/images/problem_2.png"},
  //       {"imageUrl": "assets/images/problem_3.png"},
  //       {"imageUrl": "assets/images/problem.png"},
  //     ]
  //   },
  // ]);

  // Future<dynamic> _futureFollowModel = Future.value([
  //   {
  //     "id": 0,
  //     "code": "B0",
  //     "title": "แจ้งปัญหาคอมพิวเตอร์ A3",
  //     "description":
  //         "แจ้งปัญหาคอมพิวเตอร์ A3 ศูนย์ดิจิทัลสายไหม มีปัญหา ไม่สามารถใช้งานได้ ",
  //     "memberId": "0012345",
  //     "startDate": "09-07-2566",
  //     "finishDate": "09-07-2566",
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
  //     "startDate": "09-07-2566",
  //     "finishDate": "09-07-2566",
  //     "status": "1",
  //     "image": <dynamic>[
  //       {"imageUrl": "assets/images/logo.png"},
  //       {"imageUrl": "assets/images/logo.png"},
  //     ]
  //   },
  // ]);

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
            'แจ้งปัญหา',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildDashBoard(),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    // physics: const ClampingScrollPhysics(),
                    children: [
                      // _buildProblemList(),
                      _buildFollowList(),
                    ],
                  ),
                ),
              ],
            ),
            // if (_loading)
            //   Positioned.fill(
            //     child: Container(
            //       alignment: Alignment.center,
            //       decoration: BoxDecoration(
            //         color: Colors.white.withOpacity(0.3),
            //         borderRadius: BorderRadius.circular(25),
            //       ),
            //       child: const SizedBox(
            //         height: 60,
            //         width: 60,
            //         child: CircularProgressIndicator(),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  // Widget _buildProblemList() {
  //   return Container(
  //     // color: Color(0xFFF7F7F7),
  //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text(
  //               'รายการปัญหา',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (contex) => const ReportListPage(),
  //                   ),
  //                 );
  //               },
  //               child: const Text(
  //                 'ดูทั้งหมด',
  //                 style: TextStyle(
  //                     decoration: TextDecoration.underline,
  //                     color: Color(0xFF7209B7),
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w400),
  //               ),
  //             )
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 14,
  //         ),
  //         FutureBuilder<dynamic>(
  //           future: _futureProblemModel,
  //           builder: (_, snapshot) {
  //             if (snapshot.hasData) {
  //               if (snapshot.data.length == 0) {
  //                 return const NoDataWidget();
  //               } else {
  //                 return ListView.builder(
  //                   shrinkWrap: true,
  //                   physics: const ClampingScrollPhysics(),
  //                   // padding: const EdgeInsets.symmetric(
  //                   //   horizontal: 20,
  //                   //   vertical: 10,
  //                   // ),
  //                   itemCount: snapshot.data.length,
  //                   // separatorBuilder: (_, __) => const SizedBox(height: 15),
  //                   itemBuilder: (_, __) =>
  //                       _buildProblemResult(snapshot.data.toList()[__]),
  //                 );
  //               }
  //             } else if (snapshot.hasError) {
  //               return Container();
  //             } else {
  //               return const Center(
  //                 heightFactor: 15,
  //                 child: CircularProgressIndicator(),
  //               );
  //             }
  //           },
  //           // ),
  //         ),
  //         // )
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildProblemResult(dynamic model) {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (contex) => ReportDetailsPage(model: model, mode: 2),
  //         ),
  //       );
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 11),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: const BorderRadius.all(Radius.circular(11)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFFF3D2FF).withOpacity(0.25),
  //             blurRadius: 5,
  //             offset: const Offset(0, 5),
  //           )
  //         ],
  //       ),
  //       child: Container(
  //         padding:
  //             const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 25),
  //         width: double.infinity,
  //         // height: 60,
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.all(Radius.circular(11)),
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 7.0),
  //                   child: Container(
  //                     width: 6,
  //                     height: 6,
  //                     decoration: const BoxDecoration(
  //                         color: Color(0xFF7209B7),
  //                         borderRadius: BorderRadius.all(Radius.circular(15))),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   width: 10,
  //                 ),
  //                 Flexible(
  //                   child: Text(
  //                     'TICKET NO. ${model['ticketNo'] ?? "-"}',
  //                     style: const TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 15),
  //               child: Text(
  //                 '${model['ticketName']}',
  //                 style: const TextStyle(
  //                     fontSize: 13, fontWeight: FontWeight.w400),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 15),
  //               child: Text(
  //                 '${model['statusCodeText']} ${model['ticketOwner'] != null && model['ticketOwner'].isNotEmpty ? ' - ${model['ticketOwner']}' : ''}',
  //                 style: const TextStyle(
  //                     fontSize: 13, fontWeight: FontWeight.w400),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 15),
  //                   child: Row(
  //                     children: [
  //                       Image.asset(
  //                         "assets/images/calendar.png",
  //                         fit: BoxFit.contain,
  //                         width: 16,
  //                         height: 16,
  //                       ),
  //                       SizedBox(width: 12),
  //                       const Text(
  //                         'รับแจ้งปัญหา ',
  //                         // _convertDate(model['ticketDate']),
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(width: 5),
  //                 Text(
  //                   _convertDate(model['ticketDate']),
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 15),
  //                   child: Row(
  //                     children: [
  //                       Image.asset(
  //                         "assets/images/calendar.png",
  //                         fit: BoxFit.contain,
  //                         width: 16,
  //                         height: 16,
  //                       ),
  //                       SizedBox(width: 12),
  //                       const Text(
  //                         'คาดว่าจะเสร็จ  ',
  //                         // _convertDate(model['ticketDate']),
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w400,
  //                         ),
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Text(
  //                   _convertDate(model['estimateDate']),
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w400,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFollowList() {
    return Container(
      // color: Color(0xFFF7F7F7),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'รายการปัญหา/ติดตามปัญหา',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (contex) => ReportFollowPage()),
                  );
                },
                child: const Text(
                  'ดูทั้งหมด',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF7209B7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading) // ✅ ใช้เช็ก _loading
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            FutureBuilder<dynamic>(
              future: _futureFollowModel,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.length == 0) {
                    return const NoDataWidget();
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: 20,
                      //   vertical: 10,
                      // ),
                      itemCount: snapshot.data.length,
                      // separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder:
                          (_, __) => _buildFollowResult(
                            snapshot.data.toList()[__],
                            __,
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

          // )
        ],
      ),
    );
  }

  Widget _buildFollowResult(dynamic model, int __) {
    return InkWell(
      onTap: () {
        setState(() {
          _dialogReportDetails(model, __);
          _callsubTypesTicketk(model);
        });
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
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/calendar.png",
                          fit: BoxFit.contain,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 12),
                        const Text('วันที่รับแจ้งปัญหา'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/calendar.png",
                          fit: BoxFit.contain,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 12),
                        const Text('วันที่คาดว่าจะเสร็จ'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _convertDate(model['estimateDate']),
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
                    _selectedDashboard = "510";
                    _callReadTrack();
                    // _callRead();
                  }),
              child: Container(
                width: double.infinity,
                decoration:
                    _selectedDashboard == "510"
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
                                  _selectedDashboard == "510"
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF8414B5),
                            ),
                          ),
                          Text(
                            '${reportModel['ticketCount'] ?? '0'}',
                            // '${reportModel != null ? reportModel['ticketCount'] ?? '0' : '0'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color:
                                  _selectedDashboard == "510"
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
                    _selectedDashboard = "511";
                    // _callRead();
                    _callReadTrack();
                  }),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration:
                    _selectedDashboard == "511"
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
                                  _selectedDashboard == "511"
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF8414B5),
                            ),
                          ),
                          Text(
                            '${reportModel['ticketInProgress'] ?? '0'}',
                            // '${reportModel != null ? reportModel['ticketInProgress'] ?? '0' : '0'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color:
                                  _selectedDashboard == "511"
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
                    _selectedDashboard = "512";
                    // _callRead();
                    _callReadTrack();
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
                      _selectedDashboard == "512"
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
                              _selectedDashboard == "512"
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF8414B5),
                        ),
                      ),
                      Text(
                        '${reportModel['ticketContinue'] ?? '0'}',
                        // '${reportModel != null ? reportModel['ticketContinue'] ?? '0' : '0'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color:
                              _selectedDashboard == "512"
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
                    _selectedDashboard = "513";
                    // _callRead();
                    _callReadTrack();
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
                      _selectedDashboard == "513"
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
                              _selectedDashboard == "513"
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF8414B5),
                        ),
                      ),
                      Text(
                        '${reportModel['ticketDone'] ?? '0'}',
                        // '${reportModel != null ? reportModel['ticketDone'] ?? '0' : '0'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color:
                              _selectedDashboard == "513"
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

                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Kanit',
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF8414B5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 4, // Size of the dot
                              backgroundColor:
                                  Colors.yellow, // Color of the dot
                            ),
                            const SizedBox(width: 8),
                            Text(
                              model['statusCodeText'],
                              style: const TextStyle(color: Color(0xFF8414B5)),
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
                                future: _callsubTypesTicketk(model),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
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
                modellistDataTrack[index][subTitle] ?? '',
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
                  modellistDataTrack[index][subTitle1] ?? '',
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

  String _convertDate(dynamic dateInput) {
    if (dateInput == null) return '-- -- ----';

    try {
      final date = DateTime.parse(dateInput);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return '-- -- ----';
    }
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    // _futureProblemModel = Future.value([]);
    // _futureFollowModel = Future.value([]);
    _callReadSummary();
    // _callRead();
    _callReadTrack();

    // _callReadUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _callReadSummary() async {
    setState(() => _loading = true);

    try {
      // DateTime now = DateTime.now();
      // var currentYear = now.year;
      // var dateStart = '$currentYear-01-01';
      // var dateEnd = '$currentYear-12-31';

      // String token = await ManageStorage.read('accessToken_122') ?? '';
      DateTime dateEnd = DateTime.now();
      DateTime dateStart = DateTime(
        dateEnd.year,
        dateEnd.month - 3,
        dateEnd.day,
      );

      String dateEndStr = dateEnd.toIso8601String().substring(0, 10);
      String dateStartStr = dateStart.toIso8601String().substring(0, 10);
      print('----------------------------');
      print(dateStart);
      print(dateEnd);
      print(dateEndStr);
      print(dateStartStr);
      print(
        'https://dcc.onde.go.th/dcc-api/api/ticket/getTicketSummary/$dateStartStr/$dateEndStr',
      );
      print('----------------------------');

      String token = await ManageStorage.read('accessToken_122') ?? '';
      print('----->> $token');

      final dio = Dio();
      final response = await dio.get(
        'https://dcc.onde.go.th/dcc-api/api/ticket/getTicketSummary/$dateStartStr/$dateEndStr',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          reportModel = response.data['data'] ?? {};
        });
      } else {
        print('Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  _callReadTrack() async {
    setState(() => _loading = true);
    DateTime dateEnd = DateTime.now();
    DateTime dateStart = DateTime(dateEnd.year, dateEnd.month - 3, dateEnd.day);

    String dateEndStr = dateEnd.toIso8601String().substring(0, 10);
    String dateStartStr = dateStart.toIso8601String().substring(0, 10);

    String token = await ManageStorage.read('accessToken_122') ?? '';

    try {
      final dio = Dio();
      final response = await dio.get(
        '$ondeURL/api/ticket/getTrackTicket/$dateStartStr/$dateEndStr/$_selectedDashboard/NNOTFILTER/0',
        queryParameters: {'CurrentPage': 1, 'RecordPerPage': 10},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          modellistDataTrack = response.data['data'];
          _futureFollowModel = Future.value(modellistDataTrack);
        });
      } else {
        print('Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    setState(() => _loading = false);
  }

  dynamic subTypesTicketk;
  dynamic ticketTypeCode;

  _callsubTypesTicketk(model) async {
    String token = await ManageStorage.read('accessToken_122') ?? '';
    ticketTypeCode = model['ticketTypeCode'];

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
    _refreshController.refreshCompleted();
  }
}
