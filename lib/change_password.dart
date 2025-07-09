import 'package:des_mobile_admin_v3/change_password_send.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';
import 'widget/input_decoration.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late TextEditingController _passwordOldController;
  late TextEditingController _passwordNewController;
  late TextEditingController _passwordConfirmController;

  late String _passwordOldStringValidate;
  late String _passwordNewStringValidate;
  late String _passwordConfirmStringValidate;

  late bool _visibilityPasswordOld;
  late bool _visibilityPasswordNew;
  late bool _visibilityPasswordConfirm;

  late bool _loadingSubmit;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _loadingSubmit = false;
    _visibilityPasswordOld = true;
    _visibilityPasswordNew = true;
    _visibilityPasswordConfirm = true;

    _passwordOldStringValidate = '';
    _passwordNewStringValidate = '';
    _passwordConfirmStringValidate = '';

    _passwordOldController = TextEditingController(text: '');
    _passwordNewController = TextEditingController(text: '');
    _passwordConfirmController = TextEditingController(text: '');
    super.initState();
  }

  @override
  dispose() {
    _passwordOldController.dispose();
    _passwordNewController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

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
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFeildPassword(
                  controller: _passwordOldController,
                  hint: 'รหัสผ่านเดิม',
                  inputFormatters: InputFormatTemple.password(),
                  validateString: _passwordOldStringValidate,
                  visibility: _visibilityPasswordOld,
                  suffixTap: () {
                    setState(() {
                      _visibilityPasswordOld = !_visibilityPasswordOld;
                    });
                  },
                  validator: (value) {
                    var result = ValidateForm.password(value!);
                    setState(() {
                      _passwordOldStringValidate = result ?? '';
                    });
                    return result == null ? null : '';
                  },
                ),
                const SizedBox(height: 15),
                _buildFeildPassword(
                  controller: _passwordNewController,
                  hint: 'รหัสผ่านใหม่',
                  inputFormatters: InputFormatTemple.password(),
                  validateString: _passwordNewStringValidate,
                  visibility: _visibilityPasswordNew,
                  suffixTap: () {
                    setState(() {
                      _visibilityPasswordNew = !_visibilityPasswordNew;
                    });
                  },
                  validator: (value) {
                    var result = ValidateForm.password(value!);
                    setState(() {
                      _passwordNewStringValidate = result ?? '';
                    });
                    return result == null ? null : '';
                  },
                ),
                const SizedBox(height: 15),
                _buildFeildPassword(
                  controller: _passwordConfirmController,
                  hint: 'ยืนยันรหัสผ่านใหม่',
                  inputFormatters: InputFormatTemple.password(),
                  validateString: _passwordConfirmStringValidate,
                  visibility: _visibilityPasswordConfirm,
                  suffixTap: () {
                    setState(() {
                      _visibilityPasswordConfirm = !_visibilityPasswordConfirm;
                    });
                  },
                  validator: (value) {
                    var result = ValidateForm.password(value!);
                    if (_passwordConfirmController.text !=
                        _passwordNewController.text) {
                      result = 'กรุณากรอกรหัสผ่านใหม่ให้ตรงกัน.';
                    }
                    setState(() {
                      _passwordConfirmStringValidate = result ?? '';
                    });
                    return result == null ? null : '';
                  },
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    final form = _formKey.currentState;
                    if (form!.validate() && !_loadingSubmit) {
                      form.save();
                      _save();
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _loadingSubmit
                          ? Theme.of(context).primaryColor.withOpacity(0.8)
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x40F3D2FF),
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Text(
                          'ยืนยัน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        if (_loadingSubmit)
                          const Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePasswordSendPage()));
                  },
                  child: const Text(
                    'ลืมรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeildPassword({
    required TextEditingController controller,
    String hint = '',
    Function(String?)? validator,
    String validateString = '',
    bool visibility = false,
    List<TextInputFormatter>? inputFormatters,
    Function? suffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 12),
          alignment: Alignment.centerLeft,
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
            obscureText: visibility,
            controller: controller,
            style: const TextStyle(fontSize: 14),
            onEditingComplete: () => FocusScope.of(context).unfocus(),
            decoration: CusInpuDecoration.password(
              context,
              hintText: hint,
              visibility: visibility,
              suffixTap: suffixTap,
            ),
            inputFormatters: inputFormatters,
            validator: (String? value) => validator!(value),
          ),
        ),
        if (validateString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 3),
            child: Text(
              validateString,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
              ),
            ),
          )
      ],
    );
  }

  _dialogSuccess() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: 127,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'สำเร็จ',
                    style: TextStyle(
                      color: Color(0xFF7A4CB1),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'เปลี่ยนรหัสผ่านสำเร็จ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 95,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A4CB1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getTokenKeycloak(String email) async {
    try {
      // get token
      Response response = await Dio().post(
        '$ssoURL/realms/$keycloakReaml/protocol/openid-connect/token',
        data: {
          'username': email,
          'password': _passwordOldController.text,
          'client_id': clientID,
          'client_secret': clientSecret,
          'grant_type': 'password',
        },
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200) {
        return response.data['access_token'];
      } else {
        logE(response.data);
        return 'invalid_grant';
      }
    } on DioError catch (e) {
      logE('error');
      logE(e.error);
      setState(() => _loadingSubmit = false);
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data.toString();
      }
      Fluttertoast.showToast(msg: err);
      return null;
    }
  }

  _save() async {
    try {
      logWTF('save');
      setState(() => _loadingSubmit = true);

      var profileMe = await ManageStorage.readDynamic('profileMe');
      var accessToken = await _getTokenKeycloak(profileMe['email']);

      logWTF(accessToken);
      if (accessToken == null) {
        return;
      }

      if (accessToken == 'invalid_grant') {
        Fluttertoast.showToast(msg: 'รหัสผ่านเดิมไม่ถูกต้อง');
        setState(() => _loadingSubmit = false);
        return;
        // กรอกรหัสผ่าน
      }

      Response response = await Dio().post(
        '$ondeURL/api/user/resetPassword',
        data: {
          'email': profileMe['email'],
          'password': _passwordNewController.text,
        },
      );

      if (response.statusCode == 200) {
        if (response.data) {
          logWTF('success');
          await Dio().post(
            '$serverUrl/dcc-api/m/register/reset/password',
            data: {
              'email': profileMe['email'],
              'password': _passwordNewController.text,
            },
          );

          setState(() => _loadingSubmit = false);
          _dialogSuccess();
          return;
        }
      }
      setState(() => _loadingSubmit = false);
      logE(response.data);
      Fluttertoast.showToast(msg: response.data?['title'] ?? 'ลองใหม่อีกครั้ง');
    } catch (e) {
      logE(e);
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
    }
  }
}
