import 'dart:convert';

import 'package:des_mobile_admin_v3/profile_verify_center.dart';
import 'package:des_mobile_admin_v3/profile_verify_email.dart';
import 'package:des_mobile_admin_v3/profile_verify_face.dart';
import 'package:des_mobile_admin_v3/profile_verify_phone.dart';
import 'package:des_mobile_admin_v3/profile_verify_thai_id.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/user_verify_email.dart';
import 'package:des_mobile_admin_v3/user_verify_phone.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';
import 'login.dart';

class ProfileVerifyPage extends StatefulWidget {
  const ProfileVerifyPage({super.key});

  @override
  State<ProfileVerifyPage> createState() => _ProfileVerifyPageState();
}

class _ProfileVerifyPageState extends State<ProfileVerifyPage> {
  late dynamic _userData;
  late dynamic _checkImage;
  bool _loading = true;
  bool checkImage = false;

  @override
  initState() {
    _userData = {};
    _getData();
    super.initState();
  }

  _getData() async {
    try {
      await _getProfileMe();
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      _userData = profileMe;
      var response = await Dio().post(
          '$serverUrl/dcc-api/m/register/checkImage/read',
          data: {'idcard': _userData['idcard']});

      logWTF(response.data);

      if (response.data['message'] == 'invalid_idcard') {
        // ไม่พบข้อมูล ไปยืนยันใบหน้า
        setState(() {
          _loading = false;
        });
      }

      if (response.data['objectData'] != null) {
        setState(() {
          checkImage = true;
        });
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  dynamic _getProfileMe() async {
    try {
      // get info
      logWTF('_getProfileMe');
      String token = await ManageStorage.read('accessToken_122') ?? '';
      if (token.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
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
        logWTF('success');
        await ManageStorage.createSecureStorage(
          value: json.encode(response.data?['data']),
          key: 'profileMe',
        );
      } else if (response.statusCode == 500) {
        logE(response.data);
      }
    } on DioError catch (e) {
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
    }
  }

  _checkVerify(param) {
    if (param != '' && param != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFCF9FF),
        elevation: 0,
        leadingWidth: 50,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'ยืนยันตัวตน',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // _buildItem(
            //   title: 'ยืนยันด้วยเบอร์โทรศัพท์',
            //   image: 'assets/images/icon_verify_phone.png',
            //   value: _checkVerify(_userData?['phone'] ?? ''),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (builder) => const ProfileVerifyPhonePage(),
            //       ),
            //     ).then((value) => _getUserData());
            //   },
            // ),
            const SizedBox(height: 20),
            _buildItem(
              title: 'ยืนยันด้วยอีเมล',
              image: 'assets/images/icon_verify_email.png',
              value: _checkVerify(_userData?['email'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const ProfileVerifyEmailPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildItem(
              title: 'ยืนยันด้วยใบหน้า',
              image: 'assets/images/icon_verify_face.png',
              value: checkImage,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const ProfileVerifyFacePage(),
                  ),
                ).then((value) => _getData());
              },
            ),
            const SizedBox(height: 20),
            _buildItem(
              title: 'ยืนยันด้วยแอปพลิเคชัน ThaID',
              image: 'assets/images/icon_verify_thai_id.png',
              value: _userData?['isVerify'] == 1 ? true : false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => const ProfileVerifyThaiIDPage(),
                  ),
                );
              },
            ),
            // const SizedBox(height: 20),
            // _buildItem(
            //   title: 'ยืนยันศูนย์ดิจิทัลที่ประจำการ',
            //   image: 'assets/images/icon_app.png',
            //   value: _checkVerify(_userData?['centerName'] ?? ''),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (builder) => const ProfileVerifyCenterPage(),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    String image = '',
    String title = '',
    String sub = '',
    bool value = false,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (!value && !_loading) {
          onTap!();
        }
      },
      child: Row(
        children: [
          Image.asset(
            image,
            height: 40,
            width: 40,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  value ? 'ยืนยันตัวตนแล้ว' : 'รอการยืนยันตัวตน',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: value
                        ? const Color(0xFF767676)
                        : const Color(0xFF767676),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 3),
          _buildBtnVerify(value)
        ],
      ),
    );
  }

  Widget _buildBtnVerify(value) {
    if (_loading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 24,
      width: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: !value ? Colors.white : const Color(0xFFD9D9D9),
          border: Border.all(
            color: !value ? const Color(0xff7209B7) : const Color(0xFFD9D9D9),
          )),
      child: Text(
        'ยืนยันตัวตน',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: !value ? const Color(0xff7209B7) : const Color(0xFFB3B3B3),
        ),
      ),
    );
  }
}
