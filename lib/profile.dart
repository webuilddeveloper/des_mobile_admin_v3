import 'dart:async';
import 'dart:convert';
import 'package:des_mobile_admin_v3/login.dart';
import 'package:des_mobile_admin_v3/operational_data.dart';
import 'package:des_mobile_admin_v3/profile_form.dart';
import 'package:des_mobile_admin_v3/profile_verify.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/facebook_firebase.dart';
import 'package:des_mobile_admin_v3/shared/google_firebase.dart';
import 'package:des_mobile_admin_v3/shared/line.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'change_password.dart';
import 'config.dart';
import 'notification_booking.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  ProfilePage({super.key, this.changePage});
  late _ProfilePageState homeCentralPageState;
  Function? changePage;

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  getState() => homeCentralPageState;
}

class _ProfilePageState extends State<ProfilePage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  // late Future<dynamic> _futureProfile;
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProfile;
  String _imageProfile = '';
  int totalAnnualLeave = 6;
  int totalPersonalLeave = 7;
  int totalStickLeave = 30;
  String email = '';
  late int month = 0;
  late int year = 0;
  dynamic leave;
  bool isLoading = true;
  bool isChecked = false;
  TextEditingController detailsController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  TextEditingController _dateStartController = TextEditingController();
  final List<bool> _selectedTimeStart = <bool>[false, false];
  late int resultStart;

  TextEditingController _dateEndController = TextEditingController();
  final List<bool> _selectedTimeEnd = <bool>[false, false];
  late int resultEnd;

  List<Widget> Time = <Widget>[const Text('เช้า'), const Text('บ่าย')];

  bool vertical = false;

  FilePickerResult? selectedFile;
  set uploadFilePath(String uploadFilePath) {}

  Future<void> uploadFile(StateSetter mSetState) async {
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg'],
      withData: true, // Ensures file bytes are loaded
    );

    if (file != null) {
      mSetState(() {
        selectedFile = file;
      });
      // print('File selected: ${selectedFile!.files.first.name}');
    } else {
      // print('User canceled file selection');
    }
  }

  Future<void> _save(String leaveCode) async {
    final url = 'https://dcc.onde.go.th/dcc-api/api/Leave/AddLeave';
    String token = await ManageStorage.read('accessToken_122') ?? '';

    // Format dates
    var formatter = DateFormat('E, d MMM yyyy HH:mm:ss', 'en');
    var startDateFormatted = '${formatter.format(startDate)} GMT';
    var endDateFormatted =
        isChecked == false
            ? '${formatter.format(endDate)} GMT'
            : startDateFormatted;

    MultipartFile? multipartFile;
    String uploadFilePath = '- ไม่มีไฟล์ -';

    // Check if a file is selected
    if (selectedFile != null && selectedFile!.files.first.bytes != null) {
      final fileBytes = selectedFile!.files.first.bytes!;
      final fileName = selectedFile!.files.first.name;
      List<String> contentType = lookupMimeType(
        selectedFile!.files.first.path.toString(),
      ).toString().split('/');

      multipartFile = MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
        contentType: MediaType(contentType[0], contentType[1]),
      );

      uploadFilePath = selectedFile!.files.first.path ?? fileName;
    }

    final formData = FormData.fromMap({
      if (multipartFile != null) 'file': multipartFile,
      'StartDate': startDateFormatted,
      'EndDate': endDateFormatted,
      'StartHalf': resultStart,
      'EndHalf': isChecked == false ? resultEnd : resultStart,
      'LeaveCode': leaveCode,
      'Status': 1.0,
      'Remark': detailsController.text.isNotEmpty ? detailsController.text : '',
      'Device': 'admin',
      'UploadFilePath': uploadFilePath,
      'UpdateBy': 'admin',
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("กำลังบันทึกข้อมูล..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      Dio dio = Dio();
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      };

      var response = await dio.post(url, data: formData);

      // Close the loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        _showDialog(context, 'สำเร็จ', 'บันทึกข้อมูลสำเร็จ');
        logWTF(response.data);
      }
    } on DioError catch (e) {
      // Close the loading dialog
      Navigator.of(context).pop();

      if (e.response != null && e.response!.statusCode == 400) {
        _showDialog(context, 'บันทึกไม่สำเร็จ', '${e.response!.data}');
      } else {
        _showDialog(context, 'บันทึกไม่สำเร็จ', '${e.message}');
      }
    }
  }

  // Function to show a dialog
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  selectedFile = null;
                  detailsController.clear();
                  startDate = DateTime.now();
                  endDate = startDate;
                  isChecked = false;
                  uploadFilePath = '- ไม่มีไฟล์ -';
                  resultStart = 0;
                  resultEnd = 0;
                });
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading // เช็คสถานะการโหลด
        ? const Center(
          child: CircularProgressIndicator(),
        ) // แสดง loading indicator เมื่อกำลังโหลด
        : Scaffold(
          backgroundColor: const Color(0xFFfdf9ff),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Color(0xFFfdf9ff)),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationBookingPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/bell.png',
                    width: 20,
                    height: 28,
                  ),
                ),
              ),
            ],
            centerTitle: true,
            title: const Text(
              'โปรไฟล์',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            footer: const ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onRefresh: onRefresh,
            child: ListView(
              children: [
                _buildUser(),
                const SizedBox(height: 10),
                _leaveWork(),
                _buttonBottom(),
                SizedBox(height: 50 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
  }

  Widget _buildUser() {
    return FutureBuilder<dynamic>(
      future: _futureProfile,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 249, 233, 255),
                  blurRadius: 3,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7209B7),
                    blurRadius: 0,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (contex) =>
                                  ProfileFormPage(title: 'แก้ไขข้อมูลโปรไฟล์'),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 90,
                          width: 90,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.memory(
                              base64Decode(_imageProfile),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${snapshot.data?['firstnameTh'] ?? ''} ${snapshot.data?['lastnameTh'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        // ต.${snapshot.data['tambon']} อ.${snapshot.data['amphoe']}
                        Text(
                          '${snapshot.data?['roleName'] ?? ''}\n ${snapshot.data?['centerName'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              children: [
                                const Text(
                                  'ปฏิบัติงาน',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${leave['countExpYearWork'] != 0 ? '${leave['countExpYearWork']} ปี ' : ''}${leave['countExpMonthWork'] != 0 ? '${leave['countExpMonthWork']} เดือน ' : ''} ',
                                  style: const TextStyle(
                                    color: Color(0xFF7209B7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                        child: VerticalDivider(
                          width: 20,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                          color: Color(0xFFFBE8FF),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: InkWell(
                          onTap: () => _dialogleave(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'ลาปีนี้   ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${leave['countTotalLeave']} วัน',
                                    style: const TextStyle(
                                      color: Color(0xFF7209B7),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _leaveWork() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 249, 233, 255),
                    blurRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                width: 100,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ลากิจ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${totalPersonalLeave - leave['countPersonalLeave']} วัน',
                      style: const TextStyle(
                        color: Color(0xFF7209B7),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            Container(
              width: 100,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 249, 233, 255),
                    blurRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                // height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ลาป่วย',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${totalStickLeave - leave['countStickLeave']} วัน',
                      style: const TextStyle(
                        color: Color(0xFF7209B7),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            Container(
              width: 100,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 249, 233, 255),
                    blurRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                // height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ลาพักร้อน',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${totalAnnualLeave - leave['countAnnualLeave']} วัน',
                      style: const TextStyle(
                        color: Color(0xFF7209B7),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            //     Container(
            //       width: 80,
            //       height: 80,
            //       decoration: const BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.all(Radius.circular(15)),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Color.fromARGB(255, 249, 233, 255),
            //             blurRadius: 3,
            //             offset: Offset(0, 5),
            //           )
            //         ],
            //       ),
            //       child: Container(
            //         // height: 100,
            //         decoration: const BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.all(Radius.circular(15)),
            //         ),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: const [
            //             Text(
            //               'ขาดงาน',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.w400,
            //               ),
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //             Text(
            //               '0 วัน',
            //               style: TextStyle(
            //                 color: Color(0xFF7209B7),
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.w700,
            //               ),
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //           ],
            //         ),
            //       ),
            //     )
            //  .
          ],
        ),
      ),
    );

    // Container(
    //   // height: 53,
    //   padding: const EdgeInsets.symmetric(horizontal: 20),
    //   child: FutureBuilder<dynamic>(
    //       future: _futureProfile,
    //       builder: (_, snapshot) {
    //         if (snapshot.hasData) {
    //           return

    //         } else {
    //           return const Center(child: CircularProgressIndicator());
    //         }
    //       }),
    // );
  }

  Widget _buttonBottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 249, 233, 255),
                  blurRadius: 3,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: double.infinity,
              // height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (contex) =>
                                  ProfileFormPage(title: 'แก้ไขข้อมูลโปรไฟล์'),
                        ),
                      ).then((value) => onRefresh());
                    },
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'แก้ไขข้อมูล',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: const Color(0xFFE2E2E2).withOpacity(0.47),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const CloseForMaintenance(),
                      //   ),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (contex) => OperationalDataPage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Text(
                              'ข้อมูลการปฏิบัติงาน',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: const Color(0xFFE2E2E2).withOpacity(0.47),
                  ),
                  InkWell(
                    onTap: () => _dialogleaveFrom(),
                    child: Container(
                      color: Colors.white,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'แบบฟอร์มการลา',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: const Color(0xFFE2E2E2).withOpacity(0.47),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => const ProfileVerifyPage(),
                        ),
                      ).then((value) => _callReadUser());
                    },
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'ยืนยันตัวตน',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: const Color(0xFFE2E2E2).withOpacity(0.47),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Text(
                              'เปลี่ยนรหัสผ่าน',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 249, 233, 255),
                  blurRadius: 3,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: InkWell(
                onTap: () => logout(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ออกจากระบบ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFD10000),
                      ),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ),
                    Image.asset(
                      "assets/images/logout.png",
                      fit: BoxFit.contain,
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('version $version', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  _dialogleaveFrom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.white.withOpacity(0.2),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter mSetState /*You can rename this!*/,
          ) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'การลางาน',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 165,
                        height: 210,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF7209B7)),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF7209B7),
                              blurRadius: 0,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.sick_outlined,
                                // Icons.pending_actions,
                                color: Color(0xFF7209B7),
                                size: 50,
                              ),
                            ),
                            const Text(
                              'ลาป่วย',
                              // '${title} ${subtitle}',
                              style: TextStyle(
                                color: Color(0xFF7209B7),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'คงเหลือ : ${totalStickLeave - leave['countStickLeave']} วัน',
                                style: const TextStyle(
                                  color: Color(0xFF7209B7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              'หมายเหตุ : ต้องทำหารลาล่วงหน้า 1 วัน ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7209B7),
                                    border: Border.all(
                                      color: const Color(0xFF7209B7),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _dialogleaveFromDetail(
                                        title: "ลาป่วย",
                                        LeaveCode: "201",
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Text(
                                        ' ยื่นคำขอ ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 165,
                        height: 210,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF7209B7)),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF7209B7),
                              blurRadius: 0,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.work_history_outlined,
                                color: Color(0xFF7209B7),
                                size: 50,
                              ),
                            ),
                            const Text(
                              'ลากิจ',
                              style: TextStyle(
                                color: Color(0xFF7209B7),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'คงเหลือ : ${totalPersonalLeave - leave['countPersonalLeave']} วัน',
                                style: const TextStyle(
                                  color: Color(0xFF7209B7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              'หมายเหตุ : ต้องทำหารลาล่วงหน้า 1 วัน ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7209B7),
                                    border: Border.all(
                                      color: const Color(0xFF7209B7),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _dialogleaveFromDetail(
                                        title: "ลากิจ",
                                        LeaveCode: "202",
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Text(
                                        ' ยื่นคำขอ ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 165,
                        height: 210,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF7209B7)),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF7209B7),
                              blurRadius: 0,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.light_mode_outlined,
                                color: Color(0xFF7209B7),
                                size: 50,
                              ),
                            ),
                            const Text(
                              'ลาพักร้อน',
                              // '${title} ${subtitle}',
                              style: TextStyle(
                                color: Color(0xFF7209B7),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'คงเหลือ : ${totalAnnualLeave - leave['countAnnualLeave']} วัน',
                                style: const TextStyle(
                                  color: Color(0xFF7209B7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              'หมายเหตุ : ต้องทำหารลาล่วงหน้า 1 วัน ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7209B7),
                                    border: Border.all(
                                      color: const Color(0xFF7209B7),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _dialogleaveFromDetail(
                                        title: "ลาพักร้อน",
                                        LeaveCode: "203",
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Text(
                                        ' ยื่นคำขอ ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
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
                            child: const Text(
                              'ปิด',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  dialogOpenPickerDate({
    required TextEditingController controllerDatetime,
    required Function(DateTime) onConfirm,
  }) {
    picker.DatePicker.showDatePicker(
      context,
      theme: picker.DatePickerTheme(
        containerHeight: 210.0,
        itemStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF53327A),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        doneStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF53327A),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
        cancelStyle: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF53327A),
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2100, 12, 31),
      onConfirm: (date) {
        setState(() {
          if (date != null) {
            String formattedDate = DateFormat('dd/MM/yyyy').format(date);
            controllerDatetime.text = formattedDate;
            onConfirm(date);
          }
        });
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.th,
    );
  }

  _dialogleaveFromDetail({required String title, required String LeaveCode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.white.withOpacity(0.2),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter mSetState /*You can rename this!*/,
          ) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Kanit',
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('รายละเอียด'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: detailsController,
                        decoration: InputDecoration(
                          // labelText: 'รายละเอียด',
                          hintText: 'โปรดระบุรายละเอียดหรือเหตุผลการลา',
                          hintStyle: const TextStyle(
                            // color: Color(0xFFD9D9D9),
                            color: Color(0xFFD9D9D9),
                            fontSize: 16,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('วันที่ลา'),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 50,
                                  child: TextField(
                                    controller: _dateStartController,
                                    decoration: InputDecoration(
                                      labelText: "เลือกวันที่",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFD9D9D9),
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.calendar_month_outlined,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onPressed: () {
                                          dialogOpenPickerDate(
                                            controllerDatetime:
                                                _dateStartController,
                                            onConfirm: (e) {
                                              setState(() {
                                                startDate = e;
                                                print(
                                                  '===================>startDate : ${startDate}',
                                                );
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    onChanged: (value) {
                                      print('======= $value');
                                    },
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _selectedTimeStart.every(
                                      (element) => element == false,
                                    )
                                    ? const Text(
                                      'โปรดเลื่อกช่วงเวลาที่ต้องการลา',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                    )
                                    : const Text(''),
                                const SizedBox(height: 12),
                                ToggleButtons(
                                  direction:
                                      vertical
                                          ? Axis.vertical
                                          : Axis.horizontal,
                                  onPressed: (int index) {
                                    mSetState(() {
                                      _selectedTimeStart[index] =
                                          !_selectedTimeStart[index];

                                      // ตรวจสอบค่า _selectedTimeStart และกำหนดค่า result

                                      if (_selectedTimeStart[0] == true &&
                                          _selectedTimeStart[1] == false) {
                                        resultStart = 1;
                                      } else if (_selectedTimeStart[0] ==
                                              false &&
                                          _selectedTimeStart[1] == true) {
                                        resultStart = 2;
                                      } else if (_selectedTimeStart[0] ==
                                              true &&
                                          _selectedTimeStart[1] == true) {
                                        resultStart = 3;
                                      } else {
                                        resultStart =
                                            0; // กรณีที่ไม่มีการเลือกอะไรเลย
                                      }

                                      print(
                                        "===========_selectedTimeStart==========> ${_selectedTimeStart}",
                                      );
                                      print(
                                        "========_selectedTimeStart index ========> ${index}",
                                      );
                                      print(
                                        "====== resultStart value is: $resultStart",
                                      );
                                    });
                                  },
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  selectedBorderColor:
                                      Colors.purple, // เส้นขอบเมื่อถูกเลือก
                                  disabledBorderColor:
                                      Colors.grey, // เส้นขอบเมื่อไม่ถูกเลือก
                                  selectedColor:
                                      Colors.purple, // ข้อความเมื่อถูกเลือก
                                  color: Colors.grey, // ข้อความเมื่อไม่ถูกเลือก
                                  fillColor: Colors.purple.withOpacity(
                                    0.2,
                                  ), // สีพื้นหลังเมื่อถูกเลือก
                                  constraints: const BoxConstraints(
                                    minHeight: 40.0,
                                    minWidth: 80.0,
                                  ),
                                  isSelected: _selectedTimeStart,
                                  children: Time,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      isChecked == true
                          ? Container()
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('จนถึง'),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 50,
                                      child: TextField(
                                        controller: _dateEndController,
                                        decoration: InputDecoration(
                                          labelText: "เลือกวันที่",
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD9D9D9),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                              ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              Icons.calendar_month_outlined,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            onPressed: () {
                                              dialogOpenPickerDate(
                                                controllerDatetime:
                                                    _dateEndController,
                                                onConfirm: (e) {
                                                  setState(() {
                                                    endDate = e;
                                                    print(
                                                      '===================>endDate : ${endDate}',
                                                    );
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        readOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _selectedTimeEnd.every(
                                          (element) => element == false,
                                        )
                                        ? const Text(
                                          'โปรดเลื่อกช่วงเวลาที่ต้องการลา',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                          softWrap: true,
                                          maxLines: 2,
                                        )
                                        : const Text(''),
                                    const SizedBox(height: 12),
                                    ToggleButtons(
                                      direction:
                                          vertical
                                              ? Axis.vertical
                                              : Axis.horizontal,
                                      onPressed: (int index) {
                                        mSetState(() {
                                          _selectedTimeEnd[index] =
                                              !_selectedTimeEnd[index];

                                          // ตรวจสอบค่า _selectedTimeStart และกำหนดค่า result

                                          if (_selectedTimeEnd[0] == true &&
                                              _selectedTimeEnd[1] == false) {
                                            resultEnd = 1;
                                          } else if (_selectedTimeEnd[0] ==
                                                  false &&
                                              _selectedTimeEnd[1] == true) {
                                            resultEnd = 2;
                                          } else if (_selectedTimeEnd[0] ==
                                                  true &&
                                              _selectedTimeEnd[1] == true) {
                                            resultEnd = 3;
                                          } else {
                                            resultEnd =
                                                0; // กรณีที่ไม่มีการเลือกอะไรเลย
                                          }

                                          print(
                                            "===========_selectedTimeEnd==========> ${_selectedTimeEnd}",
                                          );
                                          print(
                                            "========_selectedTimeEnd index ========> ${index}",
                                          );
                                          print(
                                            "====== resultEnd value is: $resultEnd",
                                          );
                                        });
                                      },
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      selectedBorderColor:
                                          Colors.purple, // เส้นขอบเมื่อถูกเลือก
                                      disabledBorderColor:
                                          Colors
                                              .grey, // เส้นขอบเมื่อไม่ถูกเลือก
                                      selectedColor:
                                          Colors.purple, // ข้อความเมื่อถูกเลือก
                                      color:
                                          Colors
                                              .grey, // ข้อความเมื่อไม่ถูกเลือก
                                      fillColor: Colors.purple.withOpacity(
                                        0.2,
                                      ), // สีพื้นหลังเมื่อถูกเลือก
                                      constraints: const BoxConstraints(
                                        minHeight: 40.0,
                                        minWidth: 80.0,
                                      ),
                                      isSelected: _selectedTimeEnd,
                                      children: Time,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                // สีเมื่อถูกเลือก
                                return Theme.of(context).primaryColor;
                              }
                              // สีเมื่อไม่ถูกเลือก
                              return Color(0xFFB3B3B3);
                            }),
                            value: isChecked,
                            onChanged: (bool? value) {
                              mSetState(() {
                                isChecked = value!;
                                print(
                                  '===================> isChecked = ${isChecked} ',
                                );
                              });
                            },
                          ),
                          const Text('ลาวันเดียว'),
                        ],
                      ),
                      const Text('เอกสารประกอบ'),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          uploadFile(mSetState);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade100,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedFile != null
                                      ? Icons.insert_drive_file
                                      : Icons.cloud_upload,
                                  size: 30,
                                  color:
                                      selectedFile != null
                                          ? Colors.green.shade600
                                          : Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 10),
                                selectedFile != null
                                    ? Column(
                                      children: [
                                        Text(
                                          selectedFile!.files.first.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '${(selectedFile!.files.first.size / 1024).toStringAsFixed(2)} KB',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      'Tap to upload file',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                const SizedBox(height: 8),
                                Text(
                                  '.pdf, .png, .jpeg, .jpg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.shade100,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Center(
                                    child: Text(
                                      'ยกเลิก',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _save(LeaveCode);
                                Navigator.pop(context);
                                // Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: GestureDetector(
                                  child: const Center(
                                    child: Text(
                                      'บันทึก',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
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
      },
    );
  }

  _dialogleave() {
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
              height: MediaQuery.of(context).size.height * 0.45,
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
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'รายละเอียดการลางานปีนี้',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _detailLeave(
                        title: 0,
                        subtitle: 'คำขอ',
                        iconData: Icons.pending_actions_outlined,
                        detail: 'คำขอรอการอนุมัติ',
                      ),
                      _detailLeave(
                        title: leave['countStickLeave'],
                        subtitle: 'วัน',
                        detail: 'วันลาป่วยที่ใช้',
                        iconData: Icons.sick,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _detailLeave(
                        title: leave['countPersonalLeave'],
                        subtitle: 'วัน',
                        iconData: Icons.work_history_outlined,
                        detail: 'วันลากิจที่ใช้',
                      ),
                      _detailLeave(
                        title: leave['countAnnualLeave'],
                        subtitle: 'วัน',
                        detail: 'วันลาพักร้อนที่ใช้',
                        iconData: Icons.light_mode_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
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
                            child: const Text(
                              'ปิด',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _detailLeave({
    required int title,
    required String subtitle,
    required IconData iconData,
    required String detail,
  }) {
    return Container(
      width: 170,
      height: 90,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF7209B7)),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF7209B7),
            blurRadius: 0,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${title} ${subtitle}',
            style: const TextStyle(
              color: Color(0xFF7209B7),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(iconData, color: const Color(0xFF7209B7), size: 28),
              ),
              Text(
                detail,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _getImageProfile();
    _callReadUser();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _callReadUser() async {
    setState(() {
      isLoading = true; // ตั้งสถานะเป็นกำลังโหลดเมื่อเริ่มดึงข้อมูล
    });

    try {
      var result = await ManageStorage.readDynamic('profileMe');
      var staffProfileData = await ManageStorage.readDynamic(
        'staffProfileData',
      );

      if (result != null && staffProfileData != null) {
        if (staffProfileData.containsKey('roleName') &&
            staffProfileData.containsKey('centerName')) {
          result['roleName'] = staffProfileData['roleName'];
          result['centerName'] = staffProfileData['centerName'];
        }

        if (result.containsKey('email')) {
          email = result['email'];
        } else {
          logE('Error: email key missing in result.');
          return;
        }

        DateTime now = DateTime.now();
        month = now.month;
        year = now.year;

        await _getLeaveday();

        // logWTF(result);

        setState(() {
          _futureProfile = Future.value(result);
        });
      } else {
        logE('Error: Profile data is missing.');
      }
    } catch (e) {
      logE('Exception: $e');
    } finally {
      setState(() {
        isLoading = false; // ปิดสถานะการโหลดเมื่อดึงข้อมูลเสร็จสิ้น
      });
    }
  }

  _getLeaveday() async {
    try {
      // อ่าน accessToken จาก local storage
      String token = await ManageStorage.read('accessToken_122') ?? '';

      // ตรวจสอบว่ามี email และ token ก่อนทำการ request
      if (email.isNotEmpty && token.isNotEmpty) {
        Response response = await Dio().get(
          '$ondeURL/api/user/staff/$email/$month/$year',
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

        // ตรวจสอบผลลัพธ์จาก API
        if (response.statusCode == 200) {
          // ตรวจสอบว่า response.data ไม่เป็น null
          if (response.data != null) {
            setState(() {
              leave = response.data;
              logWTF(leave);
            });
          } else {
            logE('Error: No data received from API.');
          }
        } else {
          logE('Error: ${response.statusCode} - ${response.data}');
        }
      } else {
        logE('Error: Missing email or token.');
      }
    } catch (e) {
      logE('Exception: $e');
    }
  }

  _getImageProfile() async {
    try {
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

  void onRefresh() async {
    _getImageProfile();
    _callReadUser();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  dateStringToDateSlashBuddhistShort(String date) {
    if (date.isEmpty) return '';
    var year = date.substring(0, 4);
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    var yearBuddhist = int.parse(year) + 543;
    var yearBuddhistString = yearBuddhist.toString();
    var yearBuddhistStringShort = yearBuddhistString.substring(2, 4);
    return '$day/$month/$yearBuddhistStringShort';
  }

  void logout() async {
    try {
      logoutFacebook();
    } catch (e) {}
    try {
      logoutGoogle();
    } catch (e) {}
    try {
      logoutLine();
    } catch (e) {}
    // switch (profileCategory) {
    //   case 'facebook':
    //     break;
    //   case 'google':
    //     break;
    //   case 'line':
    //     break;
    //   default:
    // }
    await ManageStorage.deleteStorageAll();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  //
}
