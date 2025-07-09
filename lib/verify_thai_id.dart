import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:des_mobile_admin_v3/config.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/verify_complete.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyThaiIDPage extends StatefulWidget {
  const VerifyThaiIDPage({super.key});

  @override
  State<VerifyThaiIDPage> createState() => _VerifyThaiIDPageState();
}

class _VerifyThaiIDPageState extends State<VerifyThaiIDPage> {
  dynamic _userData = {};
  bool _loadingSubmit = false;
  String imageFace = '';
  List<String> _checkImageList = [];
  late Uint8List imageUint8List;
  String _thiaDCode = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        _thiaDCode = prefs.getString('thaiDCode') ?? '';
        if (_thiaDCode.isNotEmpty) {
          _loadingSubmit = true;
          _getToken();
        }
      });
    });
    super.initState();
    _getImageUnit8List();
    _getUserData();
  }

  @override
  void dispose() {
    super.dispose();
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
            ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).padding.bottom,
                left: 20,
                right: 20,
              ),
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
                // const SizedBox(height: 10),
                // GestureDetector(
                //   onTap: () async {
                //     _userData['hasThaiD'] = false; // ไม่ได้ยืนยัน thaiD.
                //     _register();
                //   },
                //   child: Container(
                //     height: 50,
                //     width: double.infinity,
                //     alignment: Alignment.center,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       border: Border.all(
                //         color: Theme.of(context).primaryColor,
                //         width: 1,
                //       ),
                //       borderRadius: BorderRadius.circular(7),
                //       boxShadow: const [
                //         BoxShadow(
                //           blurRadius: 4,
                //           color: Color(0x40F3D2FF),
                //           offset: Offset(0, 4),
                //         )
                //       ],
                //     ),
                //     child: Text(
                //       'ข้ามขั้นตอนนี้',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w400,
                //         color: Theme.of(context).primaryColor,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
              ],
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

  updateSaveBase64(Uint8List imageFile) async {
    final tempDir = await getTemporaryDirectory();
    Random random = Random();
    final file =
        await File(
          '${tempDir.path}/${random.nextInt(10000).toString()}.jpg',
        ).create();
    file.writeAsBytesSync(imageFile);
    XFile xFile = XFile(file.path);

    await _uploadImageId(xFile, _userData['idcard'])
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

  _register() async {
    setState(() => _loadingSubmit = true);
    try {
      await updateSaveBase64(imageUint8List);
      _userData['imageUrl'] = imageFace;

      var response = await Dio().post(
        '$serverUrl/dcc-api/m/Register/create/admin',
        data: _userData,
      );

      setState(() {
        _loadingSubmit = false;
      });

      if (response.statusCode == 200) {
        logWTF(response.data['objectData']);
        if (response.data['status'] == 'S') {
          try {
            await Dio().post(
              '$serverUrl/dcc-api/m/register/checkImage/create',
              data: {
                "idcard": _userData['idcard'],
                "imageUrl1": _checkImageList[0],
                "imageUrl2": _checkImageList[1],
                "imageUrl3": _checkImageList[2],
              },
            );
          } catch (e) {
            logE('register/checkImage/create');
            logE(e);
          }
          if (!mounted) return;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => VerifyCompletePage(model: _userData),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder:
                  (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: response.data['message'] ?? 'เกิดข้อผิดพลาด',
          );
        }
      } else {
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      setState(() {
        _loadingSubmit = false;
      });
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  _callThaiID() async {
    try {
      String responseType = 'code';
      String clientId = 'TVE4MVpwQWNrc0NxSzNLWXFQYjVmdGFTdFgxNVN3bU4';
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
      await prefs.setString('thaiDAction', 'create');

      launchUrl(
        Uri.parse('$base$parameter'),
        mode: LaunchMode.externalApplication,
      );
    } catch (ex) {
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove('thaiDCode');
      await prefs.remove('thaiDState');

      String clientId = 'TVE4MVpwQWNrc0NxSzNLWXFQYjVmdGFTdFgxNVN3bU4';
      String clientSecret =
          'cjhOVEpmdk03NUZydFlCU3B0bHhwb2t3SkhSbFZnWjJOQm9lMkx3Mg';
      String credentials = "$clientId:$clientSecret";
      String encoded = base64Url.encode(utf8.encode(credentials));

      Dio dio = Dio();
      // dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      // dio.options.headers["Authorization"] = "Basic $encoded";
      // dio.options.contentType = 'application/x-www-form-urlencoded';
      // dio.options.validateStatus = (status) => true;

      var formData = FormData.fromMap({
        "grant_type": "authorization_code",
        "redirect_uri": "$serverUrl/auth",
        "code":
            "ZGJlNWUzMmQtOWUxMS00NGVkLTk1ZjQtOTU0MzJlNjU4N2NjI2ZhYzFlMDg3LTJjOGMtNGNjYy05MDhlLWJmMDIzNTllNTg5ZA",
      });

      var res = await dio.post(
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

      _userData['hasThaiD'] = true; // ยืนยัน thaiD. = true;
      _userData['thaiID'] = {
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
      };

      _userData['firstName'] = idData['given_name'];
      _userData['lastName'] = idData['family_name'];
      _userData['sex'] = idData['gender'];
      _userData['idcard'] = idData['pid'];

      // logWTF(_userData);

      _register();
    } catch (e) {
      await prefs.remove('thaiDCode');
      await prefs.remove('thaiDState');
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }
}
