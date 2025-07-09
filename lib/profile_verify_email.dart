import 'package:des_mobile_admin_v3/profile_verify_email_otp.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/user_verify_email_otp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'config.dart';
import 'verify_email_otp.dart';
import 'widget/input_decoration.dart';

class ProfileVerifyEmailPage extends StatefulWidget {
  const ProfileVerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<ProfileVerifyEmailPage> createState() => _ProfileVerifyEmailPageState();
}

class _ProfileVerifyEmailPageState extends State<ProfileVerifyEmailPage> {
  TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _emailStringValidate = '';
  late bool _loadindSubmit;

  @override
  void initState() {
    _loadindSubmit = false;
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                const SizedBox(height: 100),
                Image.asset(
                  'assets/images/verify_email_pic.png',
                  height: 166,
                  width: 205,
                ),
                Text(
                  'ยืนยันตัวตน\nด้วยอีเมล',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.start,
                ),
                const Text(
                  'กรุณากรอกอีกเมลของท่าน \nเพื่อรับรหัส OTP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeild(
                  controller: _emailController,
                  hint: 'Email',
                  validateString: _emailStringValidate,
                  validator: (value) {
                    var result = ValidateForm.empty(value!);
                    setState(() {
                      _emailStringValidate = result ?? '';
                    });
                    return result == null ? null : '';
                  },
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
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
                          'ส่งรหัส OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_loadindSubmit)
                      Positioned.fill(
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      )
                  ],
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

  _requestOTP() async {
    try {
      setState(() {
        _loadindSubmit = true;
      });
      Dio dio = Dio();
      var responseEmail = await dio.post(
        '$serverUrl/dcc-api/m/register/otp/request',
        data: {"email": _emailController.text},
      );

      var result = responseEmail.data;

      if (result['status'] == "S") {
        _emailController.text;
        setState(() {
          _loadindSubmit = false;
        });
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileVerifyEmailOTPPage(
              // model: widget.model,
              email: _emailController.text,
            ),
          ),
        );
      } else {
        setState(() {
          _loadindSubmit = false;
        });
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (ex) {
      setState(() {
        _loadindSubmit = false;
      });
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
    }
  }
}
