import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'config.dart';

class UserVerifyEmailOTPPage extends StatefulWidget {
  const UserVerifyEmailOTPPage({Key? key, required this.email})
      : super(key: key);

  final String email;

  @override
  State<UserVerifyEmailOTPPage> createState() => _UserVerifyEmailOTPPageState();
}

class _UserVerifyEmailOTPPageState extends State<UserVerifyEmailOTPPage> {
  late TextEditingController txtNumber1;
  bool loading = false;
  String image = '';
  final _formKey = GlobalKey<FormState>();
  late bool _loadindSubmit;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    _loadindSubmit = false;
    txtNumber1 = TextEditingController(text: '');
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
                'กรอกรหัส OTP\nจากอีเมล',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Text(
                'กรุณากรอกรหัส OTP ที่ท่านได้รับทางอีเมล\nเพื่อยืนยันตัวตนของท่าน',
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
                  onCompleted: (v) {
                    _validateOTP();
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
                    _save();
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

  _requestOTP() async {
    try {
      setState(() {
        _loadindSubmit = true;
      });
      Dio dio = Dio();
      var responseEmail = await dio.post(
        '$serverUrl/dcc-api/m/register/otp/request',
        data: {"email": widget.email},
      );
      var result = responseEmail.data;
      setState(() {
        _loadindSubmit = false;
      });
      if (result['status'] == "E") {
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (ex) {
      setState(() {
        _loadindSubmit = false;
      });
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }

  _validateOTP() async {
    try {
      setState(() {
        _loadindSubmit = true;
      });
      Dio dio = Dio();
      var responseEmail = await dio.post(
        '$serverUrl/dcc-api/m/register/otp/validate',
        data: {"email": widget.email, "title": txtNumber1.text},
      );

      var result = responseEmail.data;
      setState(() {
        _loadindSubmit = false;
      });
      if (result['status'] == "S") {
        // TO DO Success.
        return true;
      } else if (result['status'] == "E") {
        Fluttertoast.showToast(msg: '${result['message']}');
      } else {
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
      return false;
    } catch (e) {
      setState(() {
        _loadindSubmit = false;
      });
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      return false;
    }
  }

  _save() async {
    // try {
    //   var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
    //   profileMe['email'] = widget.email;

    //   final response = await Dio().post(
    //       '$serverUrl/dcc-api/m/Register/update',
    //       data: user);
    //   var result = response.data;
    //   if (result['status'] == 'S') {
    //     await ManageStorage.createProfile(
    //       key: result['objectData']['category'],
    //       value: result['objectData'],
    //     );
    //     onRefresh();
    //     _dialog(text: 'ยืนยันตัวตนด้วยอีเมลเรียบร้อยแล้ว');
    //   } else {
    //     _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    //   }
    // } catch (e) {
    //   _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    // }
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
