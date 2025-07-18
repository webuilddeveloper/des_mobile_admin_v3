import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_verify_confirm_data.dart';
// import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class UserVerifyFaceConfirmPage extends StatefulWidget {
  const UserVerifyFaceConfirmPage({Key? key, required this.imageUint8List})
    : super(key: key);
  final Uint8List imageUint8List;

  @override
  State<UserVerifyFaceConfirmPage> createState() =>
      _UserVerifyFaceConfirmPageState();
}

class _UserVerifyFaceConfirmPageState extends State<UserVerifyFaceConfirmPage> {
  late Uint8List imageUint8List;
  bool loading = false;

  @override
  void initState() {
    imageUint8List = widget.imageUint8List;
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => UserVerifyConfirmDataPage(
                            imageUint8List: imageUint8List,
                          ),
                    ),
                  );
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

  // face recognition start
  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;
  Image img1 = Image.asset('logo.png');
  Image img2 = Image.asset('logo.png');
  String _liveness = "nil";

  void _faceRecognition() async {
    try {
      final response = await regula.FaceSDK.instance.startFaceCapture();

      final faceImage = response.image;

      if (faceImage == null || faceImage.image.isEmpty) return;

      _setImage(true, faceImage.image, faceImage.imageType);

      setState(() {
        imageUint8List = faceImage.image;
      });

      // ถ้าต้องการเซฟหรือใช้งานต่อ:
      // await updateSaveBase64(faceImage.image);
      // _register();
    } catch (e) {
      print("Face recognition error: $e");
    }
  }

  void _setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImg = regula.MatchFacesImage(imageFile, type);

    setState(() {
      if (first) {
        image1 = faceImg;
        img1 = Image.memory(imageFile);
        _liveness = "nil";
        loading = true;
      } else {
        image2 = faceImg;
        img2 = Image.memory(imageFile);
      }
    });
  }

  updateSaveBase64(Uint8List imageFile) async {
    // debugPrint('image 0 -----> ');
    // final tempDir = await getTemporaryDirectory();
    // Random random = Random();
    // final file =
    //     await File('${tempDir.path}/${random.nextInt(10000).toString()}.jpg')
    //         .create();
    // file.writeAsBytesSync(imageFile);
    // setState(() {
    //   xFile = XFile(file.path);
    // });
    // print(file);

    debugPrint('image 1 -----> ');
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
}
