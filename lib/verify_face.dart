// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:des_mobile_admin_v3/verify_face_confirm.dart';
import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class VerifyFacePage extends StatefulWidget {
  const VerifyFacePage({Key? key}) : super(key: key);

  @override
  State<VerifyFacePage> createState() => _VerifyFacePageState();
}

class _VerifyFacePageState extends State<VerifyFacePage> {
  bool loading = false;
  String image = '';
  XFile? xFile;

  @override
  void initState() {
    super.initState();
    _initializeFaceSDK();
  }

  Future<void> _initializeFaceSDK() async {
    final (success, error) = await regula.FaceSDK.instance.initialize();
    if (!success) {
      print("❌ FaceSDK init failed: ${error?.message}");
      // เพิ่มการแสดง error message ให้ user เห็น
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถเริ่มต้นระบบจดจำใบหน้าได้: ${error?.message}',
          ),
        ),
      );
    } else {
      print("✅ FaceSDK initialized successfully");
    }
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
                  await _faceRecognition();
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
                  child:
                      loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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

  String livenessStatus = "nil";

  Future<void> _faceRecognition() async {
    try {
      setState(() {
        loading = true;
      });

      final result = await regula.FaceSDK.instance.startLiveness(
        config: regula.LivenessConfig(
          skipStep: [regula.LivenessSkipStep.ONBOARDING_STEP],
        ),
        notificationCompletion: (notification) {
          print("📣 Liveness status: ${notification.status}");
        },
      );
      if (result.image == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่สามารถถ่ายภาพได้')));
        return;
      }
      final bytes = result.image!;
      _setImage(true, bytes, regula.ImageType.LIVE);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imageTempAdmin', base64Encode(bytes));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyFaceConfirmPage()),
      );
    } catch (e) {
      print("❌ Face recognition error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImg = regula.MatchFacesImage(imageFile, type);
    if (first) {
      image1 = faceImg;
      img1 = Image.memory(imageFile);
      livenessStatus = "nil";
      loading = true;
    } else {
      image2 = faceImg;
      img2 = Image.memory(imageFile);
    }
  }
}
