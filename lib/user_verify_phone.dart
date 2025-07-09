import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'user_verify_phone_otp.dart';
import 'widget/input_decoration.dart';

class UserVerifyPhonePage extends StatefulWidget {
  const UserVerifyPhonePage({Key? key}) : super(key: key);

  @override
  State<UserVerifyPhonePage> createState() => _UserVerifyPhonePageState();
}

class _UserVerifyPhonePageState extends State<UserVerifyPhonePage> {
  TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _phoneStringValidate = '';
  bool _loading = false;

  @override
  void initState() {
    _phoneController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFFAF4FF),
        body: Form(
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
                  'assets/images/verify_phone_pic.png',
                  height: 166,
                  width: 205,
                ),
                Text(
                  'ยืนยันตัวตน\nด้วยเบอร์โทรศัพท์',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.start,
                ),
                const Text(
                  'กรุณากรอกเบอร์โทรศัพท์ของท่าน\nเพื่อรับรหัส OTP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeild(
                  controller: _phoneController,
                  hint: 'หมายเลขโทรศัพท์',
                  validateString: _phoneStringValidate,
                  validator: (value) {
                    var result = ValidateForm.empty(value!);
                    setState(() {
                      _phoneStringValidate = result ?? '';
                    });
                    return result == null ? null : '';
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final form = _formKey.currentState;
                    if (form!.validate() && !_loading) {
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
                      'ส่งรหัส OTP',
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
            keyboardType: TextInputType.number,
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

  _requestOTP() async {
    _loading = true;
    Dio dio = Dio();
    dio.options.contentType = Headers.formUrlEncodedContentType;
    dio.options.headers["api_key"] = "50b65b319f67b4cf9b8e8b6891690f8f";
    dio.options.headers["secret_key"] = "j4L5ectwQEsOqRLB";
    var response =
        await dio.post('https://portal-otp.smsmkt.com/api/otp-send', data: {
      "project_key": "c16a224e3f",
      "phone": _phoneController.text.replaceAll('-', '').trim(),
      "ref_code": "xxx123"
    });

    // Dio dioEmail = Dio();
    // var responseEmail = await dioEmail.post(
    //   'https://core148.we-builds.com/email-api/Email/Create',
    //   data: {
    //     "email": ["${_emailController.text}"],
    //     "title": "DES ดิจิทัลชุมชน",
    //     "description": "รหัส OTP ของคุณคือ 234156",
    //     "subject": "DES ดิจิทัลชุมชน รับรหัส OTP"
    //   },
    // );

    // print(responseEmail.data.toString());

    var otp = response.data['result'];
    _loading = false;
    if (otp['token'] != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserVerifyPhoneOTPPage(
            token: otp['token'],
            refCode: otp['ref_code'],
            phone: _phoneController.text.replaceAll('-', '').trim(),
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }
}
