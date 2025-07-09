import 'package:des_mobile_admin_v3/change_password_otp.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';

class ChangePasswordSendPage extends StatefulWidget {
  const ChangePasswordSendPage({super.key});

  @override
  State<ChangePasswordSendPage> createState() => _ChangePasswordSendPageState();
}

class _ChangePasswordSendPageState extends State<ChangePasswordSendPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  String _validateEmail = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFfdf9ff),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Color(0xFFfdf9ff)),
          ),
          leading: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          title: const Text(
            'เปลี่ยนรหัสผ่าน',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'ระบบจะส่งรหัสยืนยัน OTP ไปยังอีเมลของท่านเพื่อรีเซ็ตรหัสผ่านของท่าน',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            if (!_loading) {
                              _requestOTP();
                            }
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
                                )
                              ],
                            ),
                            child: const Text(
                              'ส่งรหัส',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_loading)
                          const Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeild({
    required TextEditingController controller,
    String hint = '',
    Function(String?)? validator,
    String validateString = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x40F3D2FF),
                offset: Offset(0, 4),
              )
            ],
          ),
          child: TextFormField(
            // obscureText: true,
            keyboardType: TextInputType.emailAddress,
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: CusInpuDecoration.base(
              context,
              hintText: hint,
            ),
            validator: (String? value) => validator!(value),
          ),
        ),
        if (validateString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 3),
            child: Text(
              validateString,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.red,
              ),
            ),
          )
      ],
    );
  }

  @override
  void initState() {
    _emailController = TextEditingController(text: '');
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  _requestOTP() async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe');
      setState(() => _loading = true);
      String email = profileMe['email'];
      logWTF(email);
      var response = await Dio().post(
          '$serverUrl/dcc-api/m/register/otp/request',
          data: {'email': email.trim().toLowerCase()});

      setState(() => _loading = false);
      if (response.data['status'] == 'S') {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangePasswordOTPPage(
              email: email.trim().toLowerCase(),
            ),
          ),
        );
      }
    } catch (e) {
      logE(e);
      setState(() => _loading = false);
      Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
    }
  }
}
