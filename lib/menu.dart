import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:des_mobile_admin_v3/home.dart';
import 'package:des_mobile_admin_v3/profile_verify_face.dart';
import 'package:des_mobile_admin_v3/profile_verify_thai_id.dart';
import 'package:des_mobile_admin_v3/reservation_calendar.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/notification_service.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlng/latlng.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show Random, asin, cos, sqrt;
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:flutter_face_api/flutter_face_api.dart' as regula;
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'face_authenticate.dart';
import 'face_authenticate_web.dart';
import 'login.dart';
import 'message_list.dart';
import 'policy.dart';
import 'profile.dart';

class Menupage extends StatefulWidget {
  const Menupage({Key? key}) : super(key: key);

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  DateTime? currentBackPressTime;
  bool loading = false;
  bool loadingcheckIn = false;
  int _currentPage = 0;
  List<Widget> pages = <Widget>[];
  String _profileCode = '';
  String _imageUrl = '';
  dynamic _profileData;

  dynamic _userData;
  var homePage;
  var profilePage;
  var messageListPage;
  String imageFace = '';
  List<dynamic> listImage = [];

  // Uint8List? imageScanT;
  Uint8List? imageLoadT;

  Uint8List _8List = new Uint8List(0);
  // dynamic _profileDataFaceMatch;
  String _msgCheckin = 'ลงเวลาเข้างาน';
  bool _loadingFacematch = false;
  String _imageProfile = '';

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      // key: scaffoldKey,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: WillPopScope(
              onWillPop: confirmExit,
              child: IndexedStack(index: _currentPage, children: pages),
            ),
          ),
          if (_loadingFacematch)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: Colors.grey.withOpacity(0.5),
              child: Center(
                child: Container(
                  color: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'รอสักครู่ระบบกำลังตรวจสอบตัวตนของท่าน...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return _loadingFacematch
        ? Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.grey.withOpacity(0.5),
        )
        : Container(
          height: 60 + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD8D8D8).withOpacity(0.29),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(0, -3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTap(
                index: 0,
                title: 'หน้าหลัก',
                image: Image.asset(
                  'assets/images/home.png',
                  height: 25,
                  width: 23.75,
                  color:
                      _currentPage == 0
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF000000),
                ),
              ),
              _buildTap(
                index: 1,
                title: 'ลงเวลา',
                image: Image.asset(
                  'assets/images/user_identity.png',
                  height: 23.44,
                  width: 28.12,
                  color:
                      _currentPage == 1
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF000000),
                ),
              ),
              _buildTap(
                index: 2,
                title: 'เพิ่ม',
                image: Image.asset(
                  'assets/images/plus.png',
                  height: 20,
                  width: 20,
                  color:
                      _currentPage == 2
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF000000),
                ),
              ),
              _buildTap(
                index: 3,
                title: 'ข้อความ',
                image: Image.asset(
                  'assets/images/message.png',
                  height: 25,
                  width: 25,
                  color:
                      _currentPage == 3
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF000000),
                ),
              ),
              _buildTap(
                index: 4,
                title: 'โปรไฟล์',
                image: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    base64Decode(_imageProfile),
                    fit: BoxFit.cover,
                    height: 30,
                    width: 30,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/profile.png',
                            height: 30,
                            width: 30,
                            color:
                                _currentPage == 4
                                    ? Theme.of(context).primaryColor
                                    : const Color(0xFF000000),
                          ),
                        ),
                  ),
                ),
                isNetwork: true,
              ),
            ],
          ),
        );
  }

  Widget _buildTap({
    required int index,
    required String title,
    required Widget image,
    bool isNetwork = false,
    Key? key,
  }) {
    Color color =
        _currentPage == index
            ? Theme.of(context).primaryColor
            : const Color(0xFF000000);
    return Flexible(
      key: key,
      flex: 1,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            radius: 60,
            splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              if (index == 1) {
                if (loadingcheckIn) {
                  return;
                }
                // setState(() => loadingcheckIn = true);
                try {
                  // var value = await ManageStorage.read('profileMe') ?? '';
                  // var result = json.decode(value);
                  // Dio().post(
                  //   '$serverUrl/dcc-api/m/register/examine/checkin/admin/read',
                  //   data: {
                  //     'email': result['email'],
                  //   },
                  // ).then((response) async {
                  //   logWTF('response check in read');
                  //   logWTF(response.data);
                  //   setState(() => loadingcheckIn = false);
                  await _callReadGetStaffCalende();
                  getStaffCalende['checkin'] == null
                      ? _addButtonCheckin('')
                      : _addButtonCheckin('OUT');
                  // if (response.data['status'].toUpperCase() == 'S') {
                  //   _addButtonCheckin(
                  //       response.data?['objectData']?['title'] ?? '');
                  // } else {
                  //   setState(() => loadingcheckIn = false);
                  //   Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
                  // }

                  // }).onError((e, stackTrace) {
                  //   setState(() => loadingcheckIn = false);
                  //   Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
                  // });
                } on DioException catch (e) {
                  // ตรวจสอบประเภทของ DioException
                  String errorMessage;

                  switch (e.type) {
                    case DioExceptionType.connectionTimeout:
                      errorMessage =
                          "Connection Timeout. Please try again later.";
                      break;
                    case DioExceptionType.sendTimeout:
                      errorMessage = "Send Timeout. Please try again later.";
                      break;
                    case DioExceptionType.receiveTimeout:
                      errorMessage = "Receive Timeout. Please try again later.";
                      break;
                    case DioExceptionType.badResponse:
                      // ข้อผิดพลาดจากเซิร์ฟเวอร์
                      errorMessage =
                          "Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}";
                      break;
                    case DioExceptionType.cancel:
                      errorMessage = "Request to server was cancelled.";
                      break;
                    case DioExceptionType.connectionError:
                      // ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้
                      errorMessage =
                          "Unable to connect to the server. Please check your internet connection.";
                      break;
                    case DioExceptionType.badCertificate:
                      errorMessage =
                          "Certificate error. Please try again later.";
                      break;
                    case DioExceptionType.unknown:
                    default:
                      errorMessage =
                          "Something went wrong. Please try again later.";
                      break;
                  }
                  print(errorMessage);

                  // สามารถ return หรือ throw error ต่อได้ตามต้องการ
                  // throw Exception(errorMessage);
                } catch (e) {
                  logE(e);
                  setState(() => loadingcheckIn = false);
                  Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
                }

                // _faceRecognition();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => FaceAuthenticateWebPage(),
                //   ),
                // );
              } else if (index == 2) {
                setState(() => loadingcheckIn = false);
                _addButton();
              } else if (index == 3) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => MessageListPage(),
                //   ),
                // );
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const NotificationBookingPage(),
                //   ),
                // );
                //.then((value) => _notiCount());
                _onItemTapped(index);
              } else {
                setState(() => loadingcheckIn = false);
                _onItemTapped(index);
              }
              _callRead();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(alignment: Alignment.center, child: image),
                        if (loadingcheckIn && index == 1)
                          const Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _addButton() {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.white.withOpacity(0.2),
      builder: (BuildContext bc) {
        return Container(
          // height: 230 + MediaQuery.of(context).padding.bottom,
          height: 170 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0.75, 0),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReservationCalendarPage(),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    // color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x40F3D2FF),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'เพิ่มการจองใหม่',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      // color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  const url = 'https://dcc.onde.go.th/user/register';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const RegisterMemberMenuPage(),
                  //   ),
                  // );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: Theme.of(context).primaryColor,
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x40F3D2FF),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'ลงทะเบียนสมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      // color: Colors.white,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // GestureDetector(
              //   onTap: () async {
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(
              //     //     builder: (_) => const IdCardFormPage(),
              //     //   ),
              //     // );
              //   },
              //   child: Container(
              //     height: 50,
              //     width: double.infinity,
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(
              //       // color: Theme.of(context).primaryColor,
              //       color: const Color(0xFFDDDDDD),
              //       borderRadius: BorderRadius.circular(7),
              //       boxShadow: const [
              //         BoxShadow(
              //           blurRadius: 4,
              //           color: Color(0x40F3D2FF),
              //           offset: Offset(0, 4),
              //         )
              //       ],
              //     ),
              //     child: const Text(
              //       'เข้าใช้งานสมาชิก',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w400,
              //         // color: Colors.white,
              //         color: Color(0xFF707070),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0 && _currentPage == 0) {
        // _buildMainPopUp();
        homePage.getState().onRefresh();
      }
      _currentPage = index;
    });
  }

  _callRead() async {
    try {
      var result = await ManageStorage.readDynamic('profileMe') ?? '';
      setState(() {
        _userData = result;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  _getImageProfile() async {
    try {
      // logWTF('_getImageProfile');
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      var responseCenter = await Dio().get(
        '$ondeURL/api/user/GetImageProfile/${profileMe['userid']}',
      );

      setState(() {
        _imageProfile = responseCenter.data;
      });
    } catch (e) {
      logE('_getImageProfile');
    }
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'กดอีกครั้งเพื่อออก');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    _getImageProfile();
    _logUsed();

    initializeSDK();

    // NotificationService.instance.start(context);
    NotificationService.setupFirebaseMessaging();
    NotificationService.requestPermission();
    NotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    homePage = HomePage(changePage: _changePage);
    profilePage = ProfilePage(changePage: _changePage);
    messageListPage = MessageListPage(changePage: _changePage);

    pages = <Widget>[
      homePage,
      const SizedBox(),
      const SizedBox(),
      messageListPage,
      profilePage,
    ];
    super.initState();
  }

  Future<void> initializeSDK() async {
    await regula.FaceSDK.instance.initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _changePage(index) {
    setState(() {
      _currentPage = index;
    });

    if (index == 0) {
      // _callRead();
    }
  }

  Future<void> _callPolicy() async {
    var storage = const FlutterSecureStorage();
    String isPolicy = await storage.read(key: 'policy') ?? '';

    if (isPolicy == '') {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PolicyPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  _addButtonCheckin(String type) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.white.withOpacity(0.2),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter mSetState /*You can rename this!*/,
          ) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0.75, 0),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _eventCheckIn(mSetState, type.toUpperCase());
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x40F3D2FF),
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            type == ''
                                ? 'การบันทึกเข้า - ออกงาน'
                                : 'การบันทึกเข้า - ออกงาน',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (loadingcheckIn)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.3),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _dialogCheckIn(param, {String name = '', dynamic data}) {
    String date = '';
    try {
      String dateWithT = data['docDate'];
      DateTime dateTime = DateTime.parse(dateWithT);
      date = dateThai(dateTime);
    } catch (e) {}

    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0,
            ),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(11.0)),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 25,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(
                          param,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          date,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          data?['docTime'] ?? '',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
              ],
            ),
          ),
        );
      },
    );
  }

  _dialog({required String text}) {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            title: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            content: const Text(" "),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text(
                  "ตกลง",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Kanit',
                    color: Color(0xFF005C9E),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  _dialogOutDistance({
    required LatLng current,
    required LatLng center,
    required double distance,
  }) {
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 25,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Center(
                        child: Text(
                          'แจ้งเตือน',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF7209B7),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'อยู่นอกระยะไม่สามารถลงเวลาเข้าใข้งานได้',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          String googleMapsLocationUrl =
                              'https://www.google.com/maps/search/?api=1&query=${current.latitude},${current.longitude}';

                          final String encodedURl = Uri.encodeFull(
                            googleMapsLocationUrl,
                          );

                          launchUrl(
                            Uri.parse(encodedURl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          'ตำแหน่งปัจจุบัน : ${current.latitude},${current.longitude}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          String googleMapsLocationUrl =
                              'https://www.google.com/maps/search/?api=1&query=${center.latitude},${center.longitude}';

                          final String encodedURl = Uri.encodeFull(
                            googleMapsLocationUrl,
                          );

                          launchUrl(
                            Uri.parse(encodedURl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          'ตำแหน่งศูนย์ : ${center.latitude},${center.longitude}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ระยะห่างจากศูนย์ : ${_displayDistance(distance)}',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          // height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7209B7),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const SizedBox(
                            // height: 60,
                            child: Text(
                              'กลับ',
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
                // Positioned(
                //   right: 14,
                //   top: 14,
                //   child: GestureDetector(
                //     onTap: () => Navigator.pop(context),
                //     child: const Icon(
                //       Icons.close,
                //       size: 35,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        );
      },
    );
  }

  _dialogOpensettingPermission() {
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
                children: <Widget>[
                  const Center(
                    child: Text(
                      'แจ้งเตือน',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF7209B7),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'เข้าสู่หน้าตั้งค่าแอปเพื่ออนุญาตสิทธิ์การเข้าถึงกล้องถ่ายรูป',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Center(
                    child: Text(
                      'การอนุญาต --> กล้องถ่ายรูป',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7209B7),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: const SizedBox(
                              // height: 60,
                              child: Text(
                                'ยกเลิก',
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
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            openAppSettings();
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            // height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7209B7),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: const SizedBox(
                              // height: 60,
                              child: Text(
                                'ตั้งค่า',
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _displayDistance(double distance) {
    String unit = 'เมตร';
    String distanceS = distance.toStringAsFixed(0);
    if (distance >= 1000) {
      unit = 'ก.ม';
      distanceS = (distance / 1000).toStringAsFixed(2);
    }

    return '$distanceS $unit';
  }

  Future<bool> _getPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      // Fluttertoast.showToast(
      //   msg: 'เข้าสู่หน้าตั้งค่าแอปเพื่ออนุญาตสิทธิ์การเข้าถึงกล้องถ่ายรูป',
      // );
      return false;
      // We didn't ask for permission yet or the permission has been denied before, but not permanently.
    } else if (status.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.

      _dialogOpensettingPermission();

      // Fluttertoast.showToast(
      //   msg: 'เข้าสู่หน้าตั้งค่าแอปเพื่ออนุญาตสิทธิ์การเข้าถึงกล้องถ่ายรูป',
      // );

      return false;
    }
    return true;
  }

  _checkImage() async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe');
      if (profileMe['idcard'] == null) {
        // ไม่พบข้อมูล ไปยืนยันใบหน้า
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileVerifyThaiIDPage()),
        );
        return '';
      }
      var response = await Dio().post(
        '$serverUrl/dcc-api/m/register/checkImage/read',
        data: {'idcard': profileMe['idcard']},
      );

      logWTF(response.data);

      if (response.data['message'] == 'invalid_idcard') {
        // ไม่พบข้อมูล ไปยืนยันใบหน้า
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileVerifyFacePage()),
        );
        return '';
      }
      if (response.data['status'].toUpperCase() == 'E') {
        Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
        return '';
      }
      return response.data?['objectData']?['imageUrl1'] ?? '';
    } catch (e) {
      Fluttertoast.showToast(msg: 'ไม่พบข้อมูลลองใหม่อีกครั้ง');
      logE(e);
      return '';
    }
  }

  double _checkDistance(
    double positionLat,
    double positionLng,
    double locationLat,
    double locationLng,
  ) {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a =
          0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 1000 * 12742 * asin(sqrt(a));
    }

    // double _totalDistance = 0;
    double totalDistance = calculateDistance(
      locationLat,
      locationLng,
      positionLat,
      positionLng,
    );
    // logWTF('_totalDistance :: ');
    // logWTF(_totalDistance.round());
    // setState(() {
    //   _totalDistance = totalDistance;
    // });
    return totalDistance;
  }

  _callDataCheckDistance() async {
    try {
      // LocationSettings locationSettings = const LocationSettings(
      //   accuracy: LocationAccuracy.high,
      //   distanceFilter: 100,
      // );
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      var profileMe = await ManageStorage.readDynamic('profileMe');

      var responseCenter = await Dio().get(
        '$ondeURL/api/OfficeDigital/GetCenterByID/${profileMe['centerId']}',
      );

      // logWTF(responseCenter.data);

      if (responseCenter.data['status'] == 1) {
        // พบข้อมูล
        var distance = _checkDistance(
          position.latitude,
          position.longitude,
          responseCenter.data['data']['latitude'],
          responseCenter.data['data']['longitude'],
        );
        logWTF(distance);
        if (distance.round() < 300) {
          return ResponseStatus.success;
        } else {
          _dialogOutDistance(
            current: LatLng(
              position.latitude as Angle,
              position.longitude as Angle,
            ),
            center: LatLng(
              responseCenter.data['data']['latitude'],
              responseCenter.data['data']['longitude'],
            ),
            distance: distance,
          );
          return ResponseStatus.fail;
        }
      }
      return ResponseStatus.error;
    } catch (e) {
      return ResponseStatus.error;
    }
  }

  _checkCallLocationAPI() async {
    try {
      logWTF('start config');
      Response response = await Dio().post(
        '$serverUrl/dcc-api/configulation/location/checkIn/read',
        data: {},
      );
      logWTF(response.data);
      if (response.data['status'].toUpperCase() == 'S') {
        return response.data['objectData'];
      } else {
        return true;
      }
    } on DioError catch (e) {
      logE(e.toString());
      return true;
    }
  }

  dynamic _getProfileMe() async {
    try {
      // get info
      String token = await ManageStorage.read('accessToken_122') ?? '';
      if (token.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
      // logWTF(token);
      Response response = await Dio().get(
        '$ondeURL/api/user/ProfileMe',
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
          headers: {
            'Content-type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        await ManageStorage.createSecureStorage(
          value: json.encode(response.data?['data']),
          key: 'profileMe',
        );
      }
    } on DioError catch (e) {
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
      return null;
    }
  }

  void _validateCheckin(
    StateSetter mSetState,
    String type,
    bool isScanFace,
  ) async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe');
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/examine/checkin/admin',
        data: {
          'email': profileMe['email'],
          'title': type,
          'idcard': profileMe['idcard'],
          'isHighlight': isScanFace,
        },
      );

      logWTF(response.data);
      if (response.data['status'].toUpperCase() == 'S') {
        mSetState(() => loadingcheckIn = false);
        setState(() => _loadingFacematch = false);

        if (isScanFace) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => FaceAuthenticateWebPage(
                    idCard: profileMe['idcard'],
                    type: type == "" ? "checkIn" : "checkOut",
                  ),
            ),
          ).then((value) {
            Navigator.pop(context);
          });
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          String textStatus = 'ลงเวลาเข้างานสำเร็จ';
          if (response.data['objectData']['title'] == 'OUT') {
            textStatus = 'ลงเวลาออกงานสำเร็จ';
          }
          _dialogCheckIn(
            textStatus,
            name: '${_userData['firstnameTh']} ${_userData['lastnameTh']}',
            data: response.data?['objectData'] ?? {},
          );
        }
      } else {
        mSetState(() => loadingcheckIn = false);
        setState(() => _loadingFacematch = false);
        Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
      }
    } catch (e) {
      logE(e);
      mSetState(() => loadingcheckIn = false);
      setState(() => _loadingFacematch = false);
      _dialogCheckIn(e.toString());
    }
  }

  _eventCheckIn(StateSetter mSetState, String type) async {
    try {
      bool statusPermission = await _getPermission();
      if (!statusPermission) {
        return;
      }

      mSetState(() => loadingcheckIn = true);
      String img = await _checkImage();
      print('---------------img-------------${img}');
      if (img.isNotEmpty) {
        var a = await networkImageToBase64(img);
        mSetState(() {
          imageLoadT = base64Decode(a!);
        });
        bool isCallLocationAPI = await _checkCallLocationAPI();
        ResponseStatus distancePass;

        if (isCallLocationAPI) {
          distancePass = await _callDataCheckDistance();
        } else {
          distancePass = ResponseStatus.success;
        }

        logWTF(distancePass);

        if (distancePass == ResponseStatus.error) {
          // ไม่พบข้อมูลศูนย์
          if (!mounted) return;
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
          mSetState(() => loadingcheckIn = false);
          setState(() => _loadingFacematch = false);
          return;
        }

        if (distancePass == ResponseStatus.fail) {
          // อยู่นอกระยะ
          mSetState(() => loadingcheckIn = false);
          setState(() => _loadingFacematch = false);
          return;
        }

        // สถานะ response match face.
        ResponseStatus responseMatchFace = ResponseStatus.fail;

        // API config แสกนหน้า แบบ liveness หรือ present.
        // isScanFace ? liveness : present
        // liveness แสกน 2 ชั้น พร้อม แสกนบนเว็บ
        // present ข้าม แสกนบนเว็บ
        bool isScanFace = await _getConfigScanface();

        if (isScanFace) {
          // liveness
          responseMatchFace = await _faceRecognitionLiveness();
        } else {
          //present
          responseMatchFace = await _faceRecognitionPresent();
        }
        logWTF('responseMatchFace');
        logWTF(responseMatchFace);
        if (responseMatchFace == ResponseStatus.success) {
          // success สแกนหน้าผ่าน
          _validateCheckin(mSetState, type, isScanFace);
        } else if (responseMatchFace == ResponseStatus.notMatch) {
          // fail สแกนหน้าไม่ผ่าน
          mSetState(() => loadingcheckIn = false);
          setState(() => _loadingFacematch = false);
          _dialog(text: 'ใบหน้าไม่ตรงกันสแกนใหม่อีกครั้ง');
        } else {
          // error
          mSetState(() => loadingcheckIn = false);
          setState(() => _loadingFacematch = false);
          Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
        }
      } else {
        // check image fail.
        mSetState(() => loadingcheckIn = false);
        setState(() => _loadingFacematch = false);
        var profileMe = await ManageStorage.readDynamic('profileMe');
        if (profileMe['idcard'] == null) {
          Fluttertoast.showToast(msg: 'ยืนยันตัวตนเพื่อลงเวลาเข้าใช้งาน');
        } else {
          Fluttertoast.showToast(msg: 'ลองใหม่อีกคร้ง');
        }
      }
    } catch (e) {
      logE(e);
      mSetState(() => loadingcheckIn = false);
      setState(() => _loadingFacematch = false);
      Fluttertoast.showToast(msg: 'ลองใหม่อีกคร้ง');
    }
  }

  Map<String, dynamic> getStaffCalende = {};
  late DateTime _today;

  _callReadGetStaffCalende() async {
    _today = DateTime.now();
    setState(() {
      loadingcheckIn = true;
    });
    String token = await ManageStorage.read('accessToken_122') ?? '';

    int month = DateTime.now().month;
    int year = DateTime.now().year;

    if (token.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }

    Response response = await Dio().get(
      '$ondeURL/api/StaffCalendar/GetStaffCalenderWorkday?month=$month&year=$year&isPagination=false&key=false&direction=true&isGetPrvious_Next_Data=true',
      options: Options(
        validateStatus: (_) => true,
        contentType: 'application/x-www-form-urlencoded',
        responseType: ResponseType.json,
        headers: {
          'Content-type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = response.data['data'];
      logWTF(data);

      var selectedWorkData = data.firstWhere((item) {
        DateTime workdate = DateTime.parse(item['workdate']);
        return isSameDay(workdate, _today);
      }, orElse: () => null);

      if (selectedWorkData != null) {
        setState(() {
          getStaffCalende = selectedWorkData;
          logWTF(getStaffCalende);
        });
      } else {
        setState(() {
          getStaffCalende = {};
        });
      }
      setState(() {
        loadingcheckIn = false;
      });
    }
  }

  // face recognition start
  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;
  Widget img1 = Image.asset('assets/images/logo.png');
  Widget img2 = Image.asset('assets/images/logo.png');

  String livenessStatus = "nil";

  void _setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImg = regula.MatchFacesImage(imageFile, type);

    setState(() {
      if (first) {
        image1 = faceImg;
        img1 = Image.memory(imageFile);
        livenessStatus = "nil";
        loading = true;
      } else {
        image2 = faceImg;
        img2 = Image.memory(imageFile);
      }
    });
  }

  Future<void> liveness() async {
    try {
      var result = await regula.FaceSDK.instance.startLiveness(
        config: regula.LivenessConfig(
          skipStep: [regula.LivenessSkipStep.ONBOARDING_STEP],
        ),
        notificationCompletion: (notification) {
          print(notification.status);
        },
      );

      if (result.image == null) return;

      _setImage(true, result.image!, regula.ImageType.LIVE);

      setState(() {
        livenessStatus = result.liveness.name.toLowerCase();
      });
    } catch (e) {
      print('Liveness error: $e');
      setState(() {
        livenessStatus = "error";
      });
    }
  }

  Future<ResponseStatus> _faceRecognitionPresent() async {
    try {
      var response = await regula.FaceSDK.instance.startFaceCapture();
      if (response.image == null) {
        return ResponseStatus.fail;
      }
      Uint8List imageFile = response.image!.image;
      if (imageFile.isEmpty) {
        return ResponseStatus.fail;
      }
      Fluttertoast.showToast(msg: 'รอสักครู่ระบบกำลังตรวจสอบตัวตนของท่าน.....');
      regula.MatchFacesImage imageMatch = regula.MatchFacesImage(
        imageFile,
        regula.ImageType.PRINTED,
      );
      String matchImg = await _matchFaces(imageMatch);
      if (matchImg == 'success') {
        return ResponseStatus.success;
      } else if (matchImg == 'not_match') {
        return ResponseStatus.notMatch;
      } else {
        return ResponseStatus.fail;
      }
    } catch (e) {
      print('Face recognition error: $e');
      return ResponseStatus.error;
    }
  }

  Future<ResponseStatus> _faceRecognitionLiveness() async {
    try {
      var result = await regula.FaceSDK.instance.startLiveness();

      if (result.image == null) return ResponseStatus.fail;

      Uint8List imageFile = result.image!;

      if (imageFile.isEmpty) {
        return ResponseStatus.fail;
      }

      String livenessResult =
          result.liveness == regula.LivenessStatus.PASSED
              ? "passed"
              : "unknown";

      if (livenessResult == "passed") {
        Fluttertoast.showToast(
          msg: 'รอสักครู่ระบบกำลังตรวจสอบตัวตนของท่าน.....',
        );
        regula.MatchFacesImage imageMatch = regula.MatchFacesImage(
          imageFile,
          regula.ImageType.LIVE,
        );
        String matchImg = await _matchFaces(imageMatch);
        if (matchImg == 'success') {
          return ResponseStatus.success;
        } else if (matchImg == 'not_match') {
          _dialog(text: 'ใบหน้าไม่ตรงกัน');
          return ResponseStatus.fail;
        } else {
          _dialog(text: 'ลองใหม่อีกครั้ง');
          return ResponseStatus.fail;
        }
      }
      return ResponseStatus.fail;
    } catch (e) {
      print('Liveness recognition error: $e');
      return ResponseStatus.fail;
    }
  }

  Future<String> _matchFaces(regula.MatchFacesImage imageScan) async {
    try {
      print('------------------>>>> start matchFaces');
      if (imageLoadT == null) {
        print('Reference image not loaded');
        return 'error';
      }

      var pic1 = regula.MatchFacesImage(imageLoadT!, regula.ImageType.PRINTED);
      var request = regula.MatchFacesRequest([pic1, imageScan]);
      var response = await regula.FaceSDK.instance.matchFaces(request);

      var split = await regula.FaceSDK.instance.splitComparedFaces(
        response.results,
        0.75,
      );
      String similarity =
          split.matchedFaces.isNotEmpty
              ? "${(split.matchedFaces[0].similarity * 100).toStringAsFixed(2)}%"
              : "error";

      print('---------------->>>> Similarity: $similarity');

      if (split.matchedFaces.isNotEmpty) {
        if ((split.matchedFaces[0].similarity * 100) >= 85) {
          print('---------------- >>> Match found with similarity >= 85%');

          return 'success';
        }
        return 'not_match';
      } else {
        return 'error';
      }
    } catch (e) {
      print('Error in matchFaces: $e');
      return 'error';
    }
  }

  Future<String?> networkImageToBase64(String imageUrl) async {
    try {
      http.Response response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      return base64Encode(bytes);
    } catch (e) {
      print('Error converting network image to base64: $e');
      return null;
    }
  }

  _logUsed() async {
    try {
      String os = Platform.operatingSystem;
      String os_device = os == 'ios' ? 'Ios' : 'Android';
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';

      var criteria = {
        'email': profileMe['email'],
        'category': 'admin',
        'platform': os_device,
      };

      Dio().post(
        '$serverUrl/dcc-api/m/register/log/used/create',
        data: criteria,
      );
    } on DioError catch (e) {
      logE(e.toString());
    }
  }

  Future<bool> _getConfigScanface() async {
    try {
      logWTF('start config');
      Response response = await Dio().post(
        '$serverUrl/dcc-api/configulation/scanface/read',
        data: {},
      );
      logWTF(response.data);

      if (response.data['status'].toUpperCase() == 'S') {
        return response.data['objectData'];
      } else {
        return true;
      }
    } on DioError catch (e) {
      logE(e.toString());
      return true;
    }
  }
}
