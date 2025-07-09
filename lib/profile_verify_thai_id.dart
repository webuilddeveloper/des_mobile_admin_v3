import 'dart:convert';

import 'package:des_mobile_admin_v3/profile_verify_complete.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '/config.dart';

class ProfileVerifyThaiIDPage extends StatefulWidget {
  const ProfileVerifyThaiIDPage({Key? key}) : super(key: key);

  @override
  State<ProfileVerifyThaiIDPage> createState() =>
      _ProfileVerifyThaiIDPageState();
}

class _ProfileVerifyThaiIDPageState extends State<ProfileVerifyThaiIDPage> {
  bool _loadingSubmit = false;
  final _formKey = GlobalKey<FormState>();
  late String _thiaDCode = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? state = prefs.getString('thaiDState') ?? '';
      setState(() {
        _thiaDCode = prefs.getString('thaiDCode') ?? '';
        if (_thiaDCode.isNotEmpty) {
          _loadingSubmit = true;
          _getToken();
        }
      });
    });
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
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Padding(
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
                      'assets/images/verify_thai_id.png',
                      height: 166,
                      width: 205,
                    ),
                    Text(
                      'ยืนยันตัวตน\nด้วยแอปพลิเคชัน ThaID',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const Text(
                      'ยืนยันตัวตนขั้นสุดท้าย! โปรดเตรียมมือถือของท่านที่ติดตั้งแอปพลิเคชัน ThaID เพื่อพิสูจน์และยืนยันตัวตนต่อไป',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () async {
                        _callThaiID();
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
                          'ยืนยันตัวตน',
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
                        Navigator.pop(context);
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
                          'ย้อนกลับ',
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
            if (_loadingSubmit)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.5),
                  child: const SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _callThaiID() async {
    try {
      String responseType = 'code';
      String clientId = 'TVE4MVpwQWNrc0NxSzNLWXFQYjVmdGFTdFgxNVN3bU4';
      String clientSecret =
          'cjhOVEpmdk03NUZydFlCU3B0bHhwb2t3SkhSbFZnWjJOQm9lMkx3Mg';
      String redirectUri = '$serverUrl/auth';
      String base = 'https://imauth.bora.dopa.go.th/api/v2/oauth2/auth/';

      //random string, 1 = use for admin,2 = use for guest.
      String state = '1${getRandomString()}';
      String scope =
          'pid%20given_name%20family_name%20address%20birthdate%20gender%20openid';
      String parameter =
          '?response_type=$responseType&client_id=$clientId&redirect_uri=$redirectUri&scope=$scope&state=$state';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('thaiDState', state);
      await prefs.setString('thaiDAction', 'update');

      launchUrl(
        Uri.parse('$base$parameter'),
        mode: LaunchMode.externalApplication,
      );
    } catch (ex) {
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('thaiDCode');
      await prefs.remove('thaiDState');

      String clientId = 'TVE4MVpwQWNrc0NxSzNLWXFQYjVmdGFTdFgxNVN3bU4';
      String clientSecret =
          'cjhOVEpmdk03NUZydFlCU3B0bHhwb2t3SkhSbFZnWjJOQm9lMkx3Mg';
      String credentials = "$clientId:$clientSecret";
      String encoded = base64Url.encode(utf8.encode(credentials));

      var res = await Dio().post(
        'https://imauth.bora.dopa.go.th/api/v2/oauth2/token/',
        // data: formData,
        data: {
          "grant_type": "authorization_code",
          "redirect_uri": "$serverUrl/auth",
          "code": _thiaDCode,
        },
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
          headers: {
            'Content-type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic $encoded',
          },
        ),
      );

      Map<String, dynamic> idData = JwtDecoder.decode(res.data['id_token']);
      var result = await ManageStorage.readDynamic('profileMe') ?? '';
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';

      var send = {
        'token': accessToken,
        'email': result['email'],
        'thaiID': {
          'pid': idData['pid'],
          'name': '',
          'name_th': '',
          'birthdate': idData['birthdate'],
          'address': idData['address']['formatted'],
          'given_name': idData['given_name'],
          'middle_name': '',
          'family_name': idData['family_name'],
          'given_name_en': '',
          'middle_name_en': '',
          'family_name_en': '',
          'gender': idData['gender'],
        },
      };

      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/verify/id/admin',
        data: send,
      );

      if (response.data['status'] == 'S') {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileVerifyCompletePage()),
        );
      } else {
        Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
      }

      setState(() => _loadingSubmit = false);
    } catch (e) {
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }
}
