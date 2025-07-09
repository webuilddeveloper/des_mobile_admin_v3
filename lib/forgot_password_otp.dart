import 'package:des_mobile_admin_v3/forgot_password_complete.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'config.dart';
import 'forgot_password_new_password.dart';

class ForgotPasswordOTPPage extends StatefulWidget {
  const ForgotPasswordOTPPage({
    Key? key,
    required this.email,
  }) : super(key: key);
  final String email;

  @override
  State<ForgotPasswordOTPPage> createState() => _ForgotPasswordOTPPageState();
}

class _ForgotPasswordOTPPageState extends State<ForgotPasswordOTPPage> {
  final _passwordController = TextEditingController();
  bool _loadingSubmit = false;
  String image = '';
  final _formKey = GlobalKey<FormState>();
  late String token;
  late String refCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 100),
              Text(
                'กรอกรหัส OTP\nจากอีเมล',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Text(
                'กรุณากรอกรหัส OTP ที่ท่านได้รับทางอีเมล\nเพื่อรับรหัสผ่านใหม่',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: PinCodeTextField(
                  appContext: context,
                  controller: _passwordController,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  pastedTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  obscureText: false,
                  obscuringCharacter: '*',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // obscuringWidget: const FlutterLogo(
                  //   size: 24,
                  // ),
                  blinkWhenObscuring: true,
                  animationType: AnimationType.fade,
                  validator: (v) {
                    if (v!.length < 6) {
                      return "";
                    } else {
                      return null;
                    }
                  },
                  pinTheme: PinTheme(
                    inactiveColor: Colors.transparent,
                    activeColor: Colors.transparent,
                    selectedColor: Theme.of(context).primaryColor,
                    // disabledColor: Colors.white,
                    selectedFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(15),
                    fieldHeight: 45.2,
                    fieldWidth: 45.2,
                    activeFillColor: Colors.white,
                  ),
                  cursorColor: Colors.black,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  // errorAnimationController: errorController,
                  // controller: textEditingController,
                  keyboardType: TextInputType.number,
                  boxShadows: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x40F3D2FF),
                      offset: Offset(0, 4),
                    )
                  ],
                  onCompleted: (v) async {
                    _send();
                  },
                  // onTap: () {
                  //   print("Pressed");
                  // },
                  onChanged: (value) {
                    debugPrint(value);
                    setState(() {
                      // currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    debugPrint("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    _send();
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
                      'ยืนยัน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _passwordController.text = '';
                    });
                    _requestOTP();
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'ยังไม่ได้รับรหัส?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: 'Kanit',
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' ส่งรหัสอีกครั้ง',
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  _reset() async {
    try {
      // update password
      if (token.isEmpty) return null;
      Response response = await Dio().put(
        '$ondeURL/api/user/resetPassword',
        data: {
          'email': widget.email,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        logE(response.data);
        Fluttertoast.showToast(msg: response.data['title']);
        setState(() => _loadingSubmit = false);
        return null;
      }
    } on DioError catch (e) {
      setState(() => _loadingSubmit = false);
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
      Fluttertoast.showToast(msg: err);
      return null;
    }
  }

  _send() async {
    if (await _validateOTP()) {
      // var response = await Dio().post(
      //   '$serverUrl/dcc-api/m/register/forgot/password',
      //   data: {'email': widget.email},
      // );

      setState(() => _loadingSubmit = false);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordNewPasswordPage(
            email: widget.email,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: 'OTP ไม่ถูกต้อง');
    }
  }

  _requestOTP() async {
    var response = await Dio().post('$serverUrl/dcc-api/m/register/otp/request',
        data: {'email': widget.email.trim().toLowerCase()});
    setState(() => _loadingSubmit = false);
    if (response.data['status'] == 'S') {
      // pass
      return true;
    } else {
      setState(() => _loadingSubmit = false);
      logE(response.data['message']);
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      return false;
    }
  }

  _validateOTP() async {
    try {
      setState(() => _loadingSubmit = true);
      var response = await Dio().post(
        '$serverUrl/dcc-api/m/register/otp/validate',
        data: {
          'email': widget.email.trim().toLowerCase(),
          'title': _passwordController.text,
        },
      );

      logWTF(response.data);

      setState(() => _loadingSubmit = false);
      if (response.data['status'] == 'S') {
        // pass
        return true;
      }
      Fluttertoast.showToast(msg: 'OTP ไม่ถูกต้อง');
    } catch (e) {
      logE(e);
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }
}
