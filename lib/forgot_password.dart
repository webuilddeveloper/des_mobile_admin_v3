import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';
import 'forgot_password_otp.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  String _validateEmail = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF4FF),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 20,
              right: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 55,
                    width: 55,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Text(
                    'กรุณากรอกEmailของท่าน ระบบจะส่งรหัสยืนยัน\nเผื่อรีเซ็ตรหัสผ่านของท่าน',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 58),
                  AutofillGroup(
                    child: Column(
                      children: [
                        _buildFeild(
                          controller: _emailController,
                          hint: 'อีเมล',
                          validateString: _validateEmail,
                          validator: (value) {
                            var result = ValidateForm.email(value!);
                            setState(() {
                              _validateEmail = result ?? '';
                            });
                            return result == null ? null : '';
                          },
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final form = _formKey.currentState;
                                if (form!.validate()) {
                                  form.save();
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
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'กลับสู่หน้า',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Kanit',
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' เข้าสู่ระบบ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).primaryColor,
                                    height: 1,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      setState(() => _loading = true);
      String email = _emailController.text.trim().toLowerCase();

      var verifyResponse = await Dio().get(
          '$ondeURL/api/user/verify/duplicate/$email?isDatabaseOnly=false');

      if (verifyResponse.data == true) {
        var otpResponse = await Dio().post(
            '$serverUrl/dcc-api/m/register/otp/request',
            data: {'email': email});

        setState(() => _loading = false);

        if (otpResponse.data['status'] == 'S') {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForgotPasswordOTPPage(
                email: email,
              ),
            ),
          );
        }
      } else {
        setState(() => _loading = false);
        Fluttertoast.showToast(msg: 'ไม่พบอีเมลของคุณในระบบ');
      }
    } catch (e) {
      logE(e);
      setState(() => _loading = false);
      Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
    }
  }
}
