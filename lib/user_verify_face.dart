import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'config.dart';
import 'user_verify_face_confirm.dart';
// import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class UserVerifyFacePage extends StatefulWidget {
  const UserVerifyFacePage({Key? key}) : super(key: key);

  @override
  State<UserVerifyFacePage> createState() => _UserVerifyFacePageState();
}

class _UserVerifyFacePageState extends State<UserVerifyFacePage> {
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
                  _faceRecognition(context);
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

  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;
  Image img1 = Image.asset('logo.png');
  Image img2 = Image.asset('logo.png');
  String _liveness = "nil";

  Uint8List? imageUint8List;

  void _faceRecognition(BuildContext context) async {
    try {
      final result = await regula.FaceSDK.instance.startFaceCapture();

      final captureImage = result.image;

      if (captureImage == null || captureImage.image.isEmpty) return;

      _setImage(true, captureImage.image, captureImage.imageType);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  UserVerifyFaceConfirmPage(imageUint8List: captureImage.image),
        ),
      );

      // await updateSaveBase64(captureImage.image);
      // _register();
    } catch (e) {
      print("Face recognition error: $e");
    }
  }

  void _setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImg = regula.MatchFacesImage(imageFile, type);

    if (first) {
      image1 = faceImg;
      img1 = Image.memory(imageFile);
      _liveness = "nil";
      loading = true;
    } else {
      image2 = faceImg;
      img2 = Image.memory(imageFile);
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
      '$serverUrl/dcc-api/de-document/upload',
      data: formData,
    );
    return response.data['imageUrl'];
  }
}
