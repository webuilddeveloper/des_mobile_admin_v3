import 'dart:async';
import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/mock_data.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:ui' as ui show ImageFilter;

import '../member_edit.dart';

// ignore: must_be_immutable
class MemberDetailsPage extends StatefulWidget {
  MemberDetailsPage({super.key, required this.model});
  late _MemberDetailsPageState homeCentralPageState;
  dynamic model;

  @override
  State<MemberDetailsPage> createState() => _MemberDetailsPageState();

  getState() => homeCentralPageState;
}

class _MemberDetailsPageState extends State<MemberDetailsPage>
    with SingleTickerProviderStateMixin {
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
  dynamic get model => widget.model;
  int tabSelector = 0;
  final _selectedColor = Color(0xFF7209B7);
  final _unselectedColor = Colors.black.withOpacity(0.31);
  late TabController _tabController;

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    setState(() {
      txtFirstName.text = "";
    });
    _callReadUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _callRead() async {
    // Dio dio = Dio();
    // var response = await dio.post(
    //     '$serverUrl/dcc-api/m/register/read/admin',
    //     data: {'code': _profileData['code']});
    // return Future.value(response.data['objectData']);
  }

  _callReadUser() async {
    var res = await ManageStorage.read('profileData') ?? '';
    var result = json.decode(res);
    setState(() {
      _futureProfile = Future.value(result);
    });
  }

  void onRefresh() async {
    _callReadUser();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
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
            'ข้อมูลสมาชิก',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          children: [
            _buildUser(),
            const SizedBox(
              height: 10,
            ),
            _buildUserDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildUser() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<dynamic>(
          future: _futureProfile,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: CachedImageWidget(
                                  imageUrl: model['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                                // CachedImageWidget(
                                //   imageUrl: model['imageUrl'],
                                // ),
                              ),
                            ),
                            // Positioned(
                            //   bottom: 2,
                            //   right: 5,
                            //   child: Container(
                            //     height: 20,
                            //     width: 20,
                            //     decoration: BoxDecoration(
                            //       shape: BoxShape.circle,
                            //       border: Border.all(
                            //         width: 1,
                            //         color: const Color(0xFF7209B7),
                            //       ),
                            //       color: Colors.white,
                            //     ),
                            //     child: Padding(
                            //         padding: const EdgeInsets.all(4),
                            //         child: Image.asset(
                            //           "assets/images/camera.png",
                            //           // height: 50,
                            //           // width: 50,
                            //         )),
                            //   ),
                            // )
                          ],
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${model['firstName']} ${model['lastName']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${model['memberType'] ?? '-'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              // textAlign: TextAlign.center,
                              // maxLines: 2,
                              // overflow: TextOverflow.ellipsis,
                            ),
                            // Text(
                            //   'รหัสสมาชิก : M12345678',
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w400,
                            //     color: Colors.black.withOpacity(0.5),
                            //   ),
                            //   // textAlign: TextAlign.center,
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                          ],
                        ))
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget _buildUserDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ข้อมูลส่วนตัว',
                      style: TextStyle(
                          // color: Colors.black.withOpacity(0.31),
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tabSelector == 0
                            ? Color(0xFF7209B7)
                            : Color(0xFFfdf9ff),
                      ),
                    )
                  ],
                ),
              ),
              // Tab(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Text(
              //         'ประวัติการใช้งาน',
              //         style: TextStyle(
              //             // color: Colors.black.withOpacity(0.31),
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400),
              //       ),
              //       Container(
              //         width: 5,
              //         height: 5,
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           color: tabSelector == 1
              //               ? Color(0xFF7209B7)
              //               : Color(0xFFfdf9ff),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              // Tab(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Text(
              //         'อื่นๆ',
              //         style: TextStyle(
              //             // color: Colors.black.withOpacity(0.31),
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400),
              //       ),
              //       Container(
              //         width: 5,
              //         height: 5,
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           color: tabSelector == 2
              //               ? Color(0xFF7209B7)
              //               : Color(0xFFfdf9ff),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
            ],
            indicatorWeight: 0,
            isScrollable: true,
            overlayColor:
                MaterialStateColor.resolveWith((states) => Color(0xFFfdf9ff)),
            unselectedLabelColor: _unselectedColor,
            dividerColor: Color(0xFFfdf9ff),
            labelColor: _selectedColor,
            labelPadding: EdgeInsets.only(right: 30),
            dragStartBehavior: DragStartBehavior.start,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(0.0),
              // color: _selectedColor.withOpacity(0.2),
            ),
            onTap: (value) {
              setState(() {
                tabSelector = value;
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          _buildTabChange(),
        ],
      ),
    );
  }

  _buildTabChange() {
    switch (tabSelector) {
      case 0:
        {
          return _buildInformations();
        }
      case 1:
        {
          return _buildHistory();
        }
      case 2:
        {
          return _buildMore();
        }
    }
  }

  Widget _buildInformations() {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
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
            const EdgeInsets.only(top: 32, bottom: 32, left: 23, right: 25),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     const Text(
                  //       'ประเภทสมาชิก',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w700,
                  //         color: Color(0xFFA06CD5),
                  //       ),
                  //     ),
                  //     Text(
                  //       '${model["memberType"] ?? '-'}',
                  //       style: const TextStyle(
                  //           fontSize: 14, fontWeight: FontWeight.w400),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ชื่อ-นามสกุล',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA06CD5),
                        ),
                      ),
                      Text(
                        '${model['firstName']} ${model['lastName']}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เลขประจำตัวประชาชน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA06CD5),
                        ),
                      ),
                      Text(
                        '${model["idcard"]}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ช่วงอายุ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA06CD5),
                        ),
                      ),
                      Text(
                        '${model["ageRange"] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'E-mail',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA06CD5),
                        ),
                      ),
                      Text(
                        '${model["email"]}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'หมายเลขโทรศัพท์',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA06CD5),
                        ),
                      ),
                      Text(
                        '${model["phone"]}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberEditPage(model: widget.model),
                  ),
                );
              },
              child: Container(
                height: 30,
                width: 30,
                color: Colors.white,
                child: Image.asset(
                  "assets/images/edit.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return SizedBox();
  }

  Widget _buildMore() {
    return SizedBox();
  }

  labelTextFormField(
    String label,
    TextEditingController txtController,
  ) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        // height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SizedBox(
          child: TextFormField(
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            controller: txtController,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              floatingLabelStyle:
                  TextStyle(color: Colors.black.withOpacity(0.24)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
