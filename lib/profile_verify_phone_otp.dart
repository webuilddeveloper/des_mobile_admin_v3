import 'dart:convert';

import 'package:des_mobile_admin_v3/profile_verify.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'config.dart';
import 'user_verify_email_skip.dart';

class ProfileVerifyPhoneOTPPage extends StatefulWidget {
  const ProfileVerifyPhoneOTPPage(
      {Key? key,
      required this.token,
      required this.refCode,
      required this.phone})
      : super(key: key);
  final String token;
  final String refCode;
  final String phone;

  @override
  State<ProfileVerifyPhoneOTPPage> createState() =>
      _ProfileVerifyPhoneOTPPageState();
}

class _ProfileVerifyPhoneOTPPageState extends State<ProfileVerifyPhoneOTPPage> {
  final txtNumber1 = TextEditingController();
  bool loading = false;
  String image = '';
  final _formKey = GlobalKey<FormState>();
  late String token;
  late String refCode;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    token = widget.token;
    refCode = widget.refCode;
    super.initState();
  }

  @override
  void dispose() {
    txtNumber1.dispose();
    super.dispose();
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
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
                'กรอกรหัส OTP\nจากเบอร์โทรศัพท์',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Text(
                'กรุณากรอกรหัส OTP ที่ท่านได้รับทางโทรศัพท์\nเพื่อยืนยันตัวตนของท่าน',
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
                  controller: txtNumber1,
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
                    if (await _validateOTP()) {
                      if (!mounted) return;
                      _save();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const ProfileVerifyEmailSkipPage(),
                      //   ),
                      // );
                    } else {
                      Fluttertoast.showToast(msg: 'OTP ไม่ถูกต้อง');
                    }
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
                    if (await _validateOTP()) {
                      if (!mounted) return;
                      _save();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const ProfileVerifyEmailSkipPage(),
                      //   ),
                      // );
                      // _faceRecognition();
                    } else {
                      Fluttertoast.showToast(msg: 'OTP ไม่ถูกต้อง');
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
                      txtNumber1.text = '';
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
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' ส่งรหัสอีกครั้ง',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                            height: 1,
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

  _requestOTP() async {
    Dio dio = Dio();
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.headers["api_key"] = "50b65b319f67b4cf9b8e8b6891690f8f";
    dio.options.headers["secret_key"] = "j4L5ectwQEsOqRLB";
    var response = await dio.post('https://portal-otp.smsmkt.com/api/otp-send',
        data: {
          "project_key": "c16a224e3f",
          "phone": widget.phone,
          "ref_code": "xxx123"
        });

    var otp = response.data['result'];
    if (otp['token'] != null) {
      setState(() {
        token = otp['token'];
        refCode = otp['ref_code'];
      });
    } else {
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  _validateOTP() async {
    Dio dio = Dio();
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.headers["api_key"] = "50b65b319f67b4cf9b8e8b6891690f8f";
    dio.options.headers["secret_key"] = "j4L5ectwQEsOqRLB";
    var response = await dio
        .post('https://portal-otp.smsmkt.com/api/otp-validate', data: {
      "token": token,
      "otp_code": txtNumber1.text,
      "refCode": refCode
    });
    var validate = response.data['result'];
    if (validate != null && validate['status']) {
      Fluttertoast.showToast(msg: 'complete');
      return true;
    } else {
      return false;
    }
  }

  _save() async {
    try {
      var value = await ManageStorage.read('profileData') ?? '';
      var user = json.decode(value);
      user['phone'] = widget.phone;

      final response = await Dio()
          .post('$serverUrl/dcc-api/m/Register/update/adminCenter', data: user);
      var result = response.data;
      if (result['status'] == 'S') {
        await ManageStorage.createProfile(
          key: result['objectData']['category'],
          value: result['objectData'],
        );
        onRefresh();
        _dialog(text: 'ยืนยันตัวตนด้วยโทรศัพท์เรียบร้อยแล้ว');
      } else {
        _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }

  _dialog({required String text}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (builder) => const ProfileVerifyPage(),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
