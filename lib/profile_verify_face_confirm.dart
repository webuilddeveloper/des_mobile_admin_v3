import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/flutter_face_api.dart' as regula;
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class ProfileVerifyFaceConfirmPage extends StatefulWidget {
  const ProfileVerifyFaceConfirmPage({Key? key}) : super(key: key);

  @override
  State<ProfileVerifyFaceConfirmPage> createState() =>
      _ProfileVerifyFaceConfirmPageState();
}

class _ProfileVerifyFaceConfirmPageState
    extends State<ProfileVerifyFaceConfirmPage> {
  late Uint8List imageUint8List;
  bool loading = false;
  String imageFace = '';
  List<String> _checkImageList = [];
  dynamic _userData = {};
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  @override
  void initState() {
    _getImageUnit8List();
    _getUserData();
    super.initState();
  }

  _getImageUnit8List() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? action = prefs.getString('imageTempAdmin');
    setState(() {
      imageUint8List = Uint8List.fromList(action!.codeUnits);
    });
  }

  _getUserData() async {
    var value = await ManageStorage.read('tempAdmin') ?? '';
    var result = json.decode(value);
    setState(() {
      _userData = result;
    });
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
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
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 100),
              Text(
                'ผลการสแกนใบหน้า',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                'โปรดตรวจสอบภาพของคุณ\nคุณต้องการเลือกภาพนี้หรือสแกนใหม่อีกครั้ง',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 25),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      imageUint8List,
                      width: 200,
                      height: 267.35,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () async {
                  if (!mounted) return;
                  _save();
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
                    'เลือกภาพนี้',
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
                  _faceRecognition();
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
                      ),
                    ],
                  ),
                  child: Text(
                    'สแกนใหม่อีกครั้ง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
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

  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;
  Widget img1 = Image.asset('logo.png');
  Widget img2 = Image.asset('logo.png');
  String _liveness = "nil";

  void _faceRecognition() async {
    try {
      final result = await regula.FaceSDK.instance.startFaceCapture();

      final faceCaptureResponse =
          result; // result คือ FaceCaptureResponse อยู่แล้ว

      if (faceCaptureResponse.image == null ||
          faceCaptureResponse.image!.image.isEmpty) {
        // กรณีไม่มีภาพ
        return;
      }

      final imageFile = faceCaptureResponse.image!.image; // เป็น Uint8List
      final imageType = faceCaptureResponse.image!.imageType;

      // ใช้ setImage() ที่ถูกแก้ไว้แล้ว
      setImage(true, imageFile, imageType);

      setState(() {
        imageUint8List = imageFile; // บันทึกไว้ใช้งานภายหลัง
      });
    } catch (e) {
      print("Face recognition error: $e");
    }
  }

  // ฟังก์ชันตั้งค่ารูปภาพ
  void setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImage = regula.MatchFacesImage(imageFile, type);

    if (first) {
      image1 = faceImage;
      setState(() {
        img1 = Image.memory(imageFile);
        _liveness = "nil";
        loading = true;
      });
    } else {
      image2 = faceImage;
      setState(() {
        img2 = Image.memory(imageFile);
      });
    }
  }

  updateSaveBase64(Uint8List imageFile, String idcard) async {
    final tempDir = await getTemporaryDirectory();
    Random random = Random();
    final file =
        await File(
          '${tempDir.path}/${random.nextInt(10000).toString()}.jpg',
        ).create();
    file.writeAsBytesSync(imageFile);
    XFile xFile = XFile(file.path);

    await _uploadImageId(xFile, idcard)
        .then((res) {
          setState(() {
            // image = res;
          });
        })
        .catchError((err) {
          logE('error upload image ::: $err');
        });
  }

  _uploadImageId(XFile file, String id) async {
    try {
      Dio dio = Dio();

      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "ImageCaption": id,
        "Image": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      var response = await dio.post(
        '$serverUrl/de-document/upload/face',
        data: formData,
      );

      setState(() {
        imageFace = response.data?['imageUrl1'] ?? '';
        _checkImageList = [
          response.data['imageUrl1'],
          response.data['imageUrl2'],
          response.data['imageUrl3'],
        ];
      });
    } catch (e) {
      logE('de-document/upload/face');
      logE(e);
      // throw Exception(e);
    }
  }

  _save() async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      await updateSaveBase64(imageUint8List, profileMe['idcard']);
      logWTF(profileMe);
      logWTF(_checkImageList);
      var response = await Dio().post(
        '$serverUrl/dcc-api/m/register/checkImage/create',
        data: {
          "idcard": profileMe['idcard'],
          "imageUrl1": _checkImageList[0],
          "imageUrl2": _checkImageList[1],
          "imageUrl3": _checkImageList[2],
        },
      );

      if (!mounted) return;
      if (response.data['status'] == 'S') {
        _dialog(text: 'ยืนยันตัวตนด้วยใบหน้าเรียบร้อยแล้ว', pass: true);
      } else {
        _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      logE(e);
      _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }

  _dialog({required String text, bool pass = false}) {
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
                  if (pass) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
    );
  }
}
