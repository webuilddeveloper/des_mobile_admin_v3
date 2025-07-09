import 'dart:convert';

import 'package:des_mobile_admin_v3/login.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';

class RegisterLinkAccountPage extends StatefulWidget {
  const RegisterLinkAccountPage({
    super.key,
    required this.email,
    required this.category,
    this.model,
  });

  final String email;
  final String category;
  final dynamic model;

  @override
  State<RegisterLinkAccountPage> createState() =>
      _RegisterLinkAccountPageState();
}

class _RegisterLinkAccountPageState extends State<RegisterLinkAccountPage> {
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _loadingSubmit = false;
  String _passwordStringValidate = '';
  bool _visibilityPassword = true;
  String _username = '';

  @override
  void initState() {
    _passwordController = TextEditingController(text: '');

    if ((widget.model?['lineID'] ?? '') != '') {
      _username = widget.model?['lineID'];
      logWTF(widget.model?['lineID']);
    }
    if ((widget.model?['googleID'] ?? '') != '') {
      _username = widget.model?['googleID'];
    }
    if ((widget.model?['xID'] ?? '') != '') {
      _username = widget.model?['xID'];
      logWTF(_username);
    }

    if ((widget.model?['facebookID'] ?? '') != '') {
      _username = widget.model?['facebookID'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF4FF),
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/logo.png', height: 55, width: 55),
                const SizedBox(height: 12),
                Text(
                  'เชื่อมต่อบัญชี ${widget.category} กับ อีเมล ${widget.email}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'กรอกรหัสผ่าน',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    // color: Color(0xFF707070),
                  ),
                ),
                const SizedBox(height: 10),
                _buildFeildPassword(
                  controller: _passwordController,
                  hint: 'รหัสผ่าน',
                  inputFormatters: InputFormatTemple.password(),
                  validateString: _passwordStringValidate,
                  visibility: _visibilityPassword,
                  suffixTap: () {
                    setState(() {
                      _visibilityPassword = !_visibilityPassword;
                    });
                  },
                  validator: (value) {
                    var result = ValidateForm.password(value!);
                    setState(() {
                      _passwordStringValidate = result ?? '';
                    });
                    return result == null ? null : '';
                  },
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => _submit(),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          _loadingSubmit
                              ? Theme.of(context).primaryColor.withOpacity(0.8)
                              : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x40F3D2FF),
                          offset: Offset(0, 4),
                        ),
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
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
              ),
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
              style: const TextStyle(fontSize: 10, color: Colors.red),
            ),
          ),
      ],
    );
  }

  _submit() async {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form!.validate() && !_loadingSubmit) {
      form.save();

      try {
        setState(() => _loadingSubmit = true);
        var param = {
          'username': _username,
          'password': _passwordController.text,
          'lineID': widget.model?['lineID'] ?? '',
          'googleID': widget.model?['googleID'] ?? '',
          'xID': widget.model?['xID'] ?? '',
        };
        logWTF(param);
        Response response = await Dio().post(
          '$serverUrl/dcc-api/m/register/link/socialaccount/admin',
          data: param,
        );

        logWTF('response');
        logWTF(response.data);

        if (response.data['message'] == 'username_not_found') {
          _callLoginGuest();
        } else {
          // if (!mounted) return;
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(
          //     builder: (context) => const LoginPage(),
          //   ),
          //   (Route<dynamic> route) => false,
          // );
          setState(() => _loadingSubmit = false);
        }
      } catch (e) {
        setState(() => _loadingSubmit = false);
        Fluttertoast.showToast(msg: 'error');
      }
    }
  }

  _getTokenKeycloak({String username = '', String password = ''}) async {
    try {
      if (username.isEmpty) {
        username = widget.email.trim().toLowerCase();
        password = _passwordController.text;
      }
      // get token
      Response response = await Dio().post(
        '$ssoURL/realms/$keycloakReaml/protocol/openid-connect/token',
        data: {
          'username': username,
          'password': password,
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
        String err = response.data['error_description'].toString();
        logE(response.data);
        if (response.data['error_description'] == 'Invalid user credentials') {
          err = 'email หรือ รหัสผ่านไม่ถูกต้อง';
        }
        Fluttertoast.showToast(msg: err);
        setState(() => _loadingSubmit = false);
        return null;
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

  dynamic _getUserInfoKeycloak(String token) async {
    try {
      // get info
      if (token.isEmpty) return null;
      Response response = await Dio().get(
        '$ssoURL/realms/dcc-portal/protocol/openid-connect/userinfo',
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
        return response.data;
      } else {
        logE(response.data);
        Fluttertoast.showToast(msg: response.data['error_description']);
        setState(() => _loadingSubmit = false);
        return null;
      }
    } on DioError catch (e) {
      setState(() => _loadingSubmit = false);
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data.toString();
      }
      Fluttertoast.showToast(msg: err);
      return null;
    }
  }

  dynamic _getProfileMe(String token) async {
    try {
      // get info
      if (token.isEmpty) return null;
      logWTF(token);
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

      logWTF('response.statusCode');
      logWTF(response.statusCode);

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 500) {
        logE(response.data);
        Fluttertoast.showToast(msg: response.statusCode.toString());
        setState(() => _loadingSubmit = false);
        return null;
      } else {
        logE(response.data);
        Fluttertoast.showToast(msg: 'error ' + response.data['title']);
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

  dynamic _getStaffProfileData(String token) async {
    try {
      // get info
      if (token.isEmpty) return null;
      Response response = await Dio().post(
        '$ondeURL/api/user/GetStaffProfileData',
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
        return response.data;
      } else {
        logE(response.data);
        Fluttertoast.showToast(msg: response.data['title']);
        setState(() => _loadingSubmit = false);
        return null;
      }
    } on DioError catch (e) {
      logE(e);
      setState(() => _loadingSubmit = false);
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
      Fluttertoast.showToast(msg: err);
      return null;
    }
  }

  _getUserProfile() async {
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/read/admin',
        data: {'username': _username},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      logWTF('_getUserProfile error');
      Fluttertoast.showToast(msg: response.data['message']);
      return null;
    } catch (e) {
      logWTF('_getUserProfile error catch');
      Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
      return null;
    }
  }

  dynamic _getUser() async {
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/login',
        data: {
          'username': _username,
          'password': _passwordController.text,
          'category': 'face',
        },
      );
      setState(() => _loadingSubmit = false);
      if (response.data['status'] == 'S') {
        return response.data['objectData'];
      }
      if (response.data['status'] == 'F') {
        return response.data;
      }
      return null;
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

  void _callLoginGuest() async {
    try {
      setState(() => _loadingSubmit = true);

      logWTF('token');
      String accessToken = await _getTokenKeycloak();
      logWTF('response accessToken');
      logWTF(accessToken);

      logWTF('key cloak');
      dynamic responseKeyCloak = await _getUserInfoKeycloak(accessToken);
      logWTF('responseKeyCloak');
      logWTF(responseKeyCloak);

      if (responseKeyCloak == null) {
        return;
      }

      dynamic responseProfileMe = await _getProfileMe(accessToken);
      logWTF('responseProfileMe');
      logWTF(responseProfileMe);
      if (responseProfileMe == null) {
        return;
      }

      dynamic responseStaffProfileData = await _getStaffProfileData(
        accessToken,
      );
      logWTF('responseStaffProfileData');
      logWTF(responseStaffProfileData);
      if (responseStaffProfileData == null) {
        return;
      }

      dynamic responseUser = await _getUserProfile();
      logWTF('responseUser');
      logWTF(responseUser);

      if (responseUser?['message'] == 'code_not_found') {
        var create = await _createUserProfile(responseProfileMe['data']);
        if (create == null) {
          return;
        }
        responseUser = await _getUser();
      }

      if (responseUser == null) {
        Fluttertoast.showToast(msg: responseUser['message']);
        return;
      }
      if (responseUser?['status'] == "F") {
        Fluttertoast.showToast(msg: responseUser['message']);
        return;
      }

      await ManageStorage.createSecureStorage(
        value: accessToken,
        key: 'accessToken',
      );
      await ManageStorage.createSecureStorage(
        value: json.encode(responseStaffProfileData),
        key: 'staffProfileData',
      );
      await ManageStorage.createSecureStorage(
        value: json.encode(responseKeyCloak),
        key: 'loginData',
      );
      await ManageStorage.createSecureStorage(
        value: json.encode(responseProfileMe?['data']),
        key: 'profileMe',
      );

      logWTF(responseUser);
      await ManageStorage.createProfile(value: responseUser, key: 'face');

      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'เชื่อมบัญชีสำเร็จ');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() => _loadingSubmit = false);
      logE(e);
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  _createUserProfile(param) async {
    try {
      if (param['isStaff'] == 0) {
        // email ประชาชน
        return;
      }

      var data = {
        'username': _username,
        'password': _passwordController.text,
        'idcard': param['idcard'],
        'category': 'face',
        'email': widget.email,
        // 'firstName': param['firstnameTh'],
        // 'lastName': param['lastnameTh'],
        // 'centerCode': param['centerId'].toString(),
        'status': 'N',
        // 'lineID': widget.model?['lineID'] ?? '',
        // 'googleID': widget.model?['googleID'] ?? '',
        // 'xID': widget.model?['xID'] ?? '',
        'hasThaiD': param['isVerify'] == 1 ? true : false,
        // 'phone': param?['phonenumber'] ?? '',
        // 'gender': param?['gender'] ?? '',
        // 'uuid': param['uuid'],
        // 'age': param['ageRange'],
        // 'career': param?['jobName'] ?? '',
        // 'favorites': param?['lmsCat'] ?? '',
      };
      logE('data');
      logE(data);
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/link/account/admin/create',
        data: data,
      );

      if (response.statusCode == 200) {
        logD(response.data['objectData']);
        return response.data['objectData'];
      } else {
        logE(response.data);
        Fluttertoast.showToast(msg: response.data['error_description']);
        return null;
      }
    } on DioError catch (e) {
      setState(() => _loadingSubmit = false);
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
      logE(err);
      Fluttertoast.showToast(msg: err);
      return null;
    }
  }
}
