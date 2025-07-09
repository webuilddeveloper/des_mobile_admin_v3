import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';
import 'user_verify_complete.dart';
import 'user_verify_edit_data.dart';

class UserVerifyConfirmDataPage extends StatefulWidget {
  const UserVerifyConfirmDataPage({super.key, required this.imageUint8List});
  final Uint8List imageUint8List;

  @override
  State<UserVerifyConfirmDataPage> createState() =>
      _UserVerifyConfirmDataPageState();
}

class _UserVerifyConfirmDataPageState extends State<UserVerifyConfirmDataPage> {
  dynamic _userData = {};
  bool _loadingSubmit = false;
  String imageFace = '';

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    var value = await ManageStorage.read('tempUser') ?? '';
    var result = json.decode(value);
    setState(() {
      _userData = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4FF),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
          left: 20,
          right: 20,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 40),
            Text(
              'ยืนยันข้อมูลเจ้าหน้าที่',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.start,
            ),
            const Text(
              'โปรดยืนยันว่าข้อมูลของท่านถูกต้อง',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.memory(
                  widget.imageUint8List,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItem(
                    title: 'ประเภทสมาชิก',
                    value: '${_userData['memberType'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ศูนย์ดิจิทัลชุมชนที่ประจำการ',
                    value: '', //ตำบลท่าอิฐ
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'รหัสพนักงาน',
                    value: '${_userData['employeeID'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ชื่อ-นามสกุล',
                    value: '${_userData['fullName'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'เลขประจำตัวประชาชน',
                    value: '${_userData['idcard'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ช่วงอายุ',
                    value: '${_userData['ageRange'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ที่อยู่',
                    value: '${_userData['address'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'จังหวัด',
                    value: '${_userData['province'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'อำเภอ/เขต',
                    value: '${_userData['amphoe'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ตำบล/แขวง',
                    value: '${_userData['tambon'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'รหัสไปรษณีย์',
                    value: '${_userData['postno'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: ' E-mail',
                    value: '${_userData['email'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'หมายเลขโทรศัพท์',
                    value: '${_userData['phone'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ชื่อผู้ใช้งาน',
                    value: '${_userData['username'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'รหัสผ่าน',
                    value: '${_userData['password'] ?? '-'}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                _register();
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
                child: const Text(
                  'ยืนยัน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const UserVerifyEditDataPage(),
                    transitionDuration: const Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) =>
                        FadeTransition(opacity: a, child: c),
                  ),
                ).then((value) => _getUserData());
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x40F3D2FF),
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  'แก้ไขข้อมูลลงทะเบียน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  _buildItem({String title = '', String value = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0x807209B7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  updateSaveBase64(Uint8List imageFile) async {
    final tempDir = await getTemporaryDirectory();
    Random random = Random();
    final file =
        await File('${tempDir.path}/${random.nextInt(10000).toString()}.jpg')
            .create();
    file.writeAsBytesSync(imageFile);
    XFile xFile = XFile(file.path);

    await _uploadImageId(xFile, _userData['idcard']).then((res) {
      setState(() {
        // image = res;
      });
    }).catchError((err) {
      debugPrint(err);
    });
  }

  _uploadImageId(XFile file, String id) async {
    Dio dio = Dio();

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "ImageCaption": 'face',
      "Image": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    var response =
        await dio.post('$serverUrl/dcc-api/de-document/upload', data: formData);
    setState(() {
      imageFace = response.data['imageUrl'];
    });
  }

  _register() async {
    setState(() {
      _loadingSubmit = true;
    });
    try {
      await updateSaveBase64(widget.imageUint8List);
      _userData['imageUrl'] = imageFace;

      var response = await Dio()
          .post('$serverUrl/dcc-api/m/Register/create/user', data: _userData);

      if (response.statusCode == 200) {
        setState(() {
          // _loadingSubmit = false;
        });
        if (response.data['status'] == 'S') {
          if (!mounted) return;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const UserVerifyCompletePage(),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
            ),
          );
        } else {
          setState(() {
            // _loadingSubmit = false;
          });
          Fluttertoast.showToast(
              msg: response.data['message'] ?? 'เกิดข้อผิดพลาด');
        }
      } else {
        setState(() {
          // _loadingSubmit = false;
        });
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      setState(() {
        _loadingSubmit = false;
      });
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }
}
