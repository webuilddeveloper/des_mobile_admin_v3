import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:des_mobile_admin_v3/profile_verify_face_confirm.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'verify_face_confirm.dart';
// import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class ProfileVerifyFacePage extends StatefulWidget {
  const ProfileVerifyFacePage({Key? key}) : super(key: key);

  @override
  State<ProfileVerifyFacePage> createState() => _ProfileVerifyFacePageState();
}

class _ProfileVerifyFacePageState extends State<ProfileVerifyFacePage> {
  bool loading = false;
  String image = '';
  XFile? xFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFAF4FF),
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
            left: 20,
            right: 20,
          ),
          child: ListView(
            children: [
              const SizedBox(height: 120),
              Image.asset(
                'assets/images/verify_face_pic.png',
                height: 166,
                width: 205,
              ),
              Text(
                'ยืนยันตัวตน\nด้วยใบหน้า',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                'ยืนยันตัวตนใกล้เสร็จแล้ว! \nเริ่มสแกนใบหน้าของคุณเพื่อยืนยันตัวตน',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  _faceRecognition();
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
                    'เริ่มสแกน',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // face recognition start
  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;
  Image img1 = Image.asset('logo.png');
  Image img2 = Image.asset('logo.png');
  String _liveness = "nil";

  void _faceRecognition() async {
    try {
      final result = await regula.FaceSDK.instance.startFaceCapture();

      final captureImage = result.image;
      if (captureImage == null || captureImage.image.isEmpty) {
        return;
      }

      // เก็บภาพที่ได้ไว้ใน image1 ด้วย constructor ใหม่
      image1 = regula.MatchFacesImage(
        captureImage.image,
        captureImage.imageType,
      );

      // แสดงภาพบนหน้าจอ
      setState(() {
        img1 = Image.memory(captureImage.image);
        _liveness = "nil";
        loading = true;
      });

      // บันทึกภาพเป็น String ใน SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final base64String = base64Encode(captureImage.image);
      await prefs.setString('imageTempAdmin', base64String);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileVerifyFaceConfirmPage()),
      );
    } catch (e) {
      print("Error in _faceRecognition: $e");
    }
  }

  updateSaveBase64(Uint8List imageFile) async {
    final tempDir = await getTemporaryDirectory();
    Random random = Random();
    final file =
        await File(
          '${tempDir.path}/${random.nextInt(100000).toString()}.jpg',
        ).create();
    file.writeAsBytesSync(imageFile);
    setState(() {
      xFile = XFile(file.path);
    });
    // await uploadImageId(xFile, 'idcard').then((res) {
    //   setState(() {
    //     image = res;
    //   });
    //   debugPrint('image 2 -----> ');
    //   debugPrint(image);
    // }).catchError((err) {
    //   debugPrint('error -----> ');
    //   debugPrint(err);
    // });
  }

  Future<String> uploadImageId(XFile file, String id) async {
    Dio dio = Dio();

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "ImageCaption": id,
      "Image": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    var response = await dio.post(
      '$serverUrl/de-document/upload',
      data: formData,
    );
    return response.data['imageUrl'];
  }
}
