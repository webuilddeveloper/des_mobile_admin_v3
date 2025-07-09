import 'dart:convert';

import 'package:des_mobile_admin_v3/forgot_password.dart';
import 'package:des_mobile_admin_v3/menu.dart';
import 'package:des_mobile_admin_v3/register.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/facebook_firebase.dart';
import 'package:des_mobile_admin_v3/shared/google_firebase.dart';
import 'package:des_mobile_admin_v3/shared/line.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:twitter_login/entity/auth_result.dart';
// import 'package:twitter_login/twitter_login.dart';
import 'config.dart';

import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordModalController;
  String _usernameStringValidate = '';
  String _passwordStringValidate = '';
  bool _remeberPassword = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? currentBackPressTime;
  bool _loadingSubmit = false;
  bool _obscureTextPassword = true;
  bool openLine = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: confirmExit,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFFAF4FF),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background_light_purple.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 20,
                    right: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/logo.png',
                          height: 48,
                          width: 50,
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
                          'DCC Admin',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 58),
                        AutofillGroup(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildFeild(
                                  controller: _usernameController,
                                  hint: 'E-mail',
                                  autofillHints: const [AutofillHints.email],
                                  validateString: _usernameStringValidate,
                                  inputFormatters: InputFormatTemple.email(),
                                  validator: (value) {
                                    var result = ValidateForm.email(value!);
                                    setState(() {
                                      _usernameStringValidate = result ?? '';
                                    });
                                    return result == null ? null : '';
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildFeildPassword(
                                  controller: _passwordController,
                                  hint: 'รหัสผ่าน',
                                  obscureText: _obscureTextPassword,
                                  autofillHints: const [AutofillHints.password],
                                  validateString: _passwordStringValidate,
                                  inputFormatters: InputFormatTemple.password(),
                                  suffixTap: () {
                                    setState(() {
                                      _obscureTextPassword =
                                          !_obscureTextPassword;
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
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap:
                                          () => setState(() {
                                            _remeberPassword =
                                                !_remeberPassword;
                                          }),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              _remeberPassword
                                                  ? const Color(0xFF973AA8)
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xFF973AA8),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Expanded(
                                      child: Text(
                                        'จำรหัสผ่าน',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const ForgotPasswordPage(),
                                            ),
                                          ),
                                      child: const Text(
                                        'ลืมรหัสผ่าน?',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 31.64),
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        final form = _formKey.currentState;
                                        if (form!.validate() &&
                                            !_loadingSubmit) {
                                          form.save();
                                          if (_remeberPassword) {
                                            TextInput.finishAutofillContext();
                                          }
                                          if (await connectInternet()) {
                                            _callLoginGuest();
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              _loadingSubmit
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.8)
                                                  : Theme.of(
                                                    context,
                                                  ).primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 4,
                                              color: Color(0x40F3D2FF),
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'เข้าสู่ระบบ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_loadingSubmit)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18.08),
                                // Stack(
                                //   children: [
                                //     GestureDetector(
                                //       onTap: () async {
                                //         FocusScope.of(context).unfocus();
                                //         final form = _formKey.currentState;
                                //         if (form!.validate() &&
                                //             !_loadingSubmit) {
                                //           form.save();
                                //           if (_remeberPassword) {
                                //             TextInput.finishAutofillContext();
                                //           }
                                //           _callLoginKeyCloak();
                                //         }
                                //       },
                                //       child: Container(
                                //         height: 50,
                                //         width: double.infinity,
                                //         alignment: Alignment.center,
                                //         decoration: BoxDecoration(
                                //           color: _loadingSubmit
                                //               ? Theme.of(context)
                                //                   .primaryColor
                                //                   .withOpacity(0.8)
                                //               : Theme.of(context).primaryColor,
                                //           borderRadius:
                                //               BorderRadius.circular(7),
                                //           boxShadow: const [
                                //             BoxShadow(
                                //               blurRadius: 4,
                                //               color: Color(0x40F3D2FF),
                                //               offset: Offset(0, 4),
                                //             )
                                //           ],
                                //         ),
                                //         child: const Text(
                                //           'เข้าสู่ระบบ KeyCloak',
                                //           style: TextStyle(
                                //             fontSize: 16,
                                //             fontWeight: FontWeight.w400,
                                //             color: Colors.white,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     if (_loadingSubmit)
                                //       Positioned.fill(
                                //         child: Container(
                                //           decoration: BoxDecoration(
                                //             color:
                                //                 Colors.white.withOpacity(0.5),
                                //             borderRadius:
                                //                 BorderRadius.circular(7),
                                //           ),
                                //           alignment: Alignment.center,
                                //           child: const SizedBox(
                                //             height: 20,
                                //             width: 20,
                                //             child: CircularProgressIndicator(),
                                //           ),
                                //         ),
                                //       ),
                                //   ],
                                // ),
                                // const SizedBox(height: 18.08),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFD5C0DC),
                                      ),
                                    ),
                                    const SizedBox(width: 19),
                                    const Text(
                                      'หรือเข้าสู่ระบบด้วย',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 17),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFD5C0DC),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 17.58),
                                _buildRowButton(),
                                const SizedBox(height: 20.08),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFD5C0DC),
                                      ),
                                    ),
                                    const SizedBox(width: 19),
                                    const Text(
                                      'ยังไม่มีบัญชีผู้ใช้งาน?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 17),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFD5C0DC),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 17.64),
                                GestureDetector(
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      ),
                                  child: const Text(
                                    'ลงทะเบียนเจ้าหน้าที่',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF7209B7),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  // Container(
                                  //   height: 50,
                                  //   width: double.infinity,
                                  //   alignment: Alignment.center,
                                  //   decoration: BoxDecoration(
                                  //       color: Colors.white,
                                  //       borderRadius: BorderRadius.circular(7),
                                  //       border: Border.all(
                                  //         width: 1,
                                  //         color: Theme.of(context).primaryColor,
                                  //       )),
                                  //   child: Text(
                                  //     'ลงทะเบียนเจ้าหน้าที่',
                                  //     style: TextStyle(
                                  //       fontSize: 16,
                                  //       fontWeight: FontWeight.w400,
                                  //       color: Theme.of(context).primaryColor,
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                                // const SizedBox(height: 17.64),
                                // GestureDetector(
                                //   onTap: () => {liveness()},
                                //   child: Text(
                                //     'กล้องกระพริบตา $_liveness',
                                //     style: const TextStyle(
                                //       fontSize: 16,
                                //       fontWeight: FontWeight.w400,
                                //       color: Color(0xFF7209B7),
                                //       decoration: TextDecoration.underline,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [const Text(version)],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var faceSdk = regula.FaceSDK.instance;

  regula.MatchFacesImage? image1;
  regula.MatchFacesImage? image2;

  Widget img1 = Image.asset('logo.png');
  Widget img2 = Image.asset('logo.png');

  Future<void> liveness() async {
    try {
      regula.LivenessResponse result = await faceSdk.startLiveness();

      if (result.image == null) return;

      // result.image เป็น Uint8List อยู่แล้วในเวอร์ชันนี้
      Uint8List imageBytes = result.image!;

      setImage(true, imageBytes, regula.ImageType.LIVE);

      // อัปเดต state
    } catch (e) {
      print("Liveness detection error: $e");
    }
  }

  // ✅ แก้ไขฟังก์ชัน setImage ให้ใช้ MatchFacesImage constructor ใหม่
  void setImage(bool first, Uint8List imageFile, regula.ImageType type) {
    final faceImage = regula.MatchFacesImage(imageFile, type);

    if (first) {
      image1 = faceImage;
      img1 = Image.memory(imageFile);
    } else {
      image2 = faceImage;
      img2 = Image.memory(imageFile);
    }
  }

  Widget _buildFeild({
    required TextEditingController controller,
    Iterable<String>? autofillHints,
    String hint = '',
    Function(String?)? validator,
    String validateString = '',
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 12),
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
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            controller: controller,
            style: const TextStyle(fontSize: 14),
            autofillHints: autofillHints,
            decoration: CusInpuDecoration.base(context, hintText: hint),
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

  Widget _buildFeildPassword({
    required TextEditingController controller,
    String hint = '',
    Function(String?)? validator,
    Iterable<String>? autofillHints,
    String validateString = '',
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    Function? suffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 12),
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
            obscureText: obscureText,
            controller: controller,
            style: const TextStyle(fontSize: 14),
            autofillHints: autofillHints,
            decoration: CusInpuDecoration.password(
              context,
              hintText: hint,
              visibility: obscureText,
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

  Widget _buildRowButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 64,
          width: 64,
          child: InkWell(
            onTap: () async {
              if (await connectInternet()) {
                if (!openLine) {
                  openLine = true;
                  _callLoginLine();
                }
              }
            },
            child: Image.asset('assets/images/line.png'),
          ),
        ),
        // const SizedBox(width: 16),
        // SizedBox(
        //   height: 64,
        //   width: 64,
        //   child: InkWell(
        //     onTap: () => _callLoginFacebook(),
        //     child: Image.asset('assets/images/facebook.png'),
        //   ),
        // ),
        const SizedBox(width: 16),
        SizedBox(
          height: 64,
          width: 64,
          child: InkWell(
            onTap: () async {
              if (await connectInternet()) {
                if (!openLine) {
                  openLine = true;
                  _callLoginGoogle();
                }
              }
            },
            child: Image.asset('assets/images/google.png'),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 64,
          width: 64,
          child: InkWell(
            onTap: () async {
              if (await connectInternet()) {
                if (!openLine) {
                  openLine = true;
                  _callLoginTwitter();
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/images/logo_x.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _usernameController = TextEditingController(text: '');
    _passwordController = TextEditingController(text: '');
    _passwordModalController = TextEditingController(text: '');

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'กดอีกครั้งเพื่อออก');
      return Future.value(false);
    }
    return Future.value(true);
  }

  _getTokenKeycloak({String username = '', String password = ''}) async {
    try {
      if (username.isEmpty) {
        username = _usernameController.text.trim().toLowerCase();
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
      // logWTF(token);

      // print ยาว
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern.allMatches(token).forEach((match) => print(match.group(0)));
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

      // logWTF('response.statusCode');
      // logWTF(response.statusCode);

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
        data: {
          'username': _usernameController.text.trim().toLowerCase(),
          // 'category': 'guest',
        },
      );
      // logWTF(response.data);
      if (response.statusCode == 200) {
        return response.data;
      }
      // logWTF('_getUserProfile error');
      Fluttertoast.showToast(msg: response.data['message']);
      return null;
    } catch (e) {
      // logWTF('_getUserProfile error catch');
      Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
      return null;
    }
  }

  dynamic _getUser() async {
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/login',
        data: {
          'username': _usernameController.text.trim(),
          // 'password': _passwordController.text,
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

      // logWTF('token');
      String accessToken = await _getTokenKeycloak();
      // logWTF('response accessToken');
      // logWTF(accessToken);

      if (accessToken == 'invalid_grant') {
        Fluttertoast.showToast(msg: 'email หรือ รหัสผ่านไม่ถูกต้อง');
        setState(() => _loadingSubmit = false);
        return;
        // กรอกรหัสผ่าน
      }

      // logWTF('key cloak');
      dynamic responseKeyCloak = await _getUserInfoKeycloak(accessToken);
      // logWTF('responseKeyCloak');
      // logWTF(responseKeyCloak);

      if (responseKeyCloak == null) {
        return;
      }

      dynamic responseProfileMe = await _getProfileMe(accessToken);
      // logWTF('responseProfileMe');
      logWTF(responseProfileMe);
      if (responseProfileMe == null) {
        return;
      }

      // check isStaff
      if (responseProfileMe['data']['isStaff'] == 0) {
        Fluttertoast.showToast(msg: 'บัญชีนี้ไม่ได้เป็นเจ้าหน้าที่');
        setState(() => _loadingSubmit = false);
        return;
      }

      // logWTF('start responseStaffProfileData');
      dynamic responseStaffProfileData = await _getStaffProfileData(
        accessToken,
      );
      // logWTF('responseStaffProfileData');
      // logWTF(responseStaffProfileData);
      if (responseStaffProfileData == null) {
        return;
      }

      dynamic responseUser = await _getUserProfile();
      // logWTF('responseUser');
      // logWTF(responseUser);

      if (responseUser?['message'] == 'code_not_found') {
        // logWTF('create');
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
        key: 'accessToken_122',
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

      // logWTF(responseUser);
      // await ManageStorage.createProfile(
      //   value: responseUser,
      //   key: 'face',
      // );

      setState(() => _loadingSubmit = false);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Menupage()),
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
      // logWTF(param);
      if (param['isStaff'] == 0) {
        // email ประชาชน
        return;
      }
      // logWTF('start');
      var data = {
        'username': _usernameController.text.trim().toLowerCase(),
        'idcard': param['idcard'],
        'category': 'face',
        'email': _usernameController.text,
        // 'firstName': param['firstnameTh'],
        // 'lastName': param['lastnameTh'],
        // 'centerCode': param['centerId'].toString(),
        'status': 'N',
        'hasThaiD': param['isVerify'] == 1 ? true : false,
        // 'password': _passwordController.text,
        // 'phone': param?['phonenumber'] ?? '',
        // 'gender': param?['gender'] ?? '',
        // 'uuid': param['uuid'],
        // 'age': param['ageRange'],
        // 'career': param?['jobName'] ?? '',
        // 'favorites': param?['lmsCat'] ?? '',
      };
      logE(data);
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/link/account/admin/create',
        data: data,
      );

      logE(response.data);
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

  void _callLoginLine() async {
    setState(() => _loadingSubmit = true);
    try {
      LoginResult? obj = await loginLine();
      openLine = false;

      if (obj != null) {
        var idToken = obj.accessToken.idToken;
        var model = {
          "username": obj.userProfile!.userId,
          "email": idToken?['email'] ?? '',
          "imageUrl":
              (obj.userProfile!.pictureUrl != '' &&
                      obj.userProfile!.pictureUrl != null)
                  ? obj.userProfile!.pictureUrl
                  : '',
          "firstName": obj.userProfile!.displayName,
          "lastName": '',
          "lineID": obj.userProfile!.userId,
        };
        _callLoginSocial(model, 'line');
      } else {
        setState(() => _loadingSubmit = false);
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'ยกเลิก');
    }
  }

  void _callLoginTwitter() async {
    setState(() => _loadingSubmit = true);
    try {
      // final twitterLogin = TwitterLogin(
      //   // Consumer API keys
      //   apiKey: 'VZWc4305qtisGTva2z52ue5A3',
      //   // Consumer API Secret keys
      //   apiSecretKey: 'WlBAmdIiGgUsDRJ0w2JuoFKrvh34CAwlC4l3ChzQhkHlt6Qd1W',
      //   // Registered Callback URLs in TwitterApp
      //   // Android is a deeplink
      //   // iOS is a URLScheme
      //   redirectURI: 'dccadmin://thaid',
      // );

      // final authResult = await twitterLogin.login();
      // AuthResult obj;
      // switch (authResult.status) {
      //   case TwitterLoginStatus.loggedIn:
      //     // success
      //     // logWTF(authResult.user!.id);
      //     // logWTF(authResult.user!.name);
      //     // logWTF(authResult.user!.email);
      //     // obj = authResult;
      //     break;
      //   case TwitterLoginStatus.cancelledByUser:
      //     // cancel
      //     break;
      //   case TwitterLoginStatus.error:
      //     // logWTF(authResult.errorMessage);
      //     Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      //     // error
      //     break;
      //   case null:
      //     break;
      // }

      // var model = {
      //   "username": authResult.user!.id.toString(),
      //   'imageUrl': authResult.user!.thumbnailImage,
      //   "email": authResult.user!.email.toLowerCase(),
      //   "firstName": authResult.user!.name,
      //   "lastName": '',
      //   "xID": authResult.user!.id.toString(),
      // };
      // _callLoginSocial(model, 'x');
    } catch (e) {
      setState(() => _loadingSubmit = false);
      logE(e);
      Fluttertoast.showToast(msg: 'ยกเลิก');
    }
  }

  void _callLoginFacebook() async {
    try {
      setState(() => _loadingSubmit = true);
      var obj = await signInWithFacebook();
      if (obj != null) {
        var model = {
          "username": obj.user.email,
          "email": obj.user.email,
          "imageUrl":
              obj.user.photoURL != null
                  ? obj.user.photoURL + "?width=9999"
                  : '',
          "firstName": obj.user.displayName,
          "lastName": '',
          "facebookID": obj.user.uid,
        };
        _callLoginSocial(model, 'facebook');
      } else {
        setState(() => _loadingSubmit = false);
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'ยกเลิก');
    }
  }

  void _callLoginGoogle() async {
    setState(() => _loadingSubmit = true);
    try {
      UserCredential? obj = await signInWithGoogle();

      var model = {
        "username": obj!.user!.uid,
        "email": obj.user!.email,
        "imageUrl": obj.user!.photoURL ?? '',
        "firstName": obj.user!.displayName,
        "lastName": '',
        "googleID": obj.user!.uid,
      };
      _callLoginSocial(model, 'google');
    } catch (e) {
      logE(e);
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      setState(() => _loadingSubmit = false);
    }
  }

  void _callLoginSocial(dynamic param, String type) async {
    setState(() => _loadingSubmit = true);
    try {
      // logWTF('check.data');
      if (param != null) {
        Dio dio = Dio();
        var check = await dio.post(
          '$serverUrl/dcc-api/m/register/check/login/social',
          data: {'username': param['username']},
        );
        // logWTF(check.data);
        if (check.data) {
          Response response = await dio.post(
            '$serverUrl/dcc-api/m/v2/register/social/login/admin',
            data: param,
          );
          // logWTF(response.data);
          if (response.data['status'] != 'S') {
            setState(() => _loadingSubmit = false);
            return null;
          }

          // logWTF(response.data);

          // logWTF('token');
          String accessToken = await _getTokenKeycloak(
            username: response.data['objectData']['email'],
            password: response.data['objectData']['password'],
          );
          // logWTF(accessToken);

          if (accessToken == 'invalid_grant') {
            // logWTF('password fail');
            Fluttertoast.showToast(msg: 'รหัสผ่านไม่ถูกต้อง');
            setState(() => _loadingSubmit = false);
            _modalPassword(param, type);
            return;
            // กรอกรหัสผ่าน
          }
          // logWTF(response);
          // logWTF('responseKeyCloak');
          dynamic responseKeyCloak = await _getUserInfoKeycloak(accessToken);
          // logWTF('responseProfileMe');
          dynamic responseProfileMe = await _getProfileMe(accessToken);
          // logWTF('responseStaffProfileData');
          dynamic responseStaffProfileData = await _getStaffProfileData(
            accessToken,
          );
          if (responseKeyCloak == null ||
              responseProfileMe == null ||
              responseStaffProfileData == null) {
            // Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
            return;
          }

          // check isStaff
          if (responseProfileMe['data']['isStaff'] == 0) {
            Fluttertoast.showToast(msg: 'บัญชีนี้ไม่ได้เป็นเจ้าหน้าที่');
            return;
          }

          await ManageStorage.createSecureStorage(
            value: accessToken,
            key: 'accessToken_122',
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
            value: json.encode(responseProfileMe['data']),
            key: 'profileMe',
          );
          // await ManageStorage.createProfile(
          //   value: response.data['objectData'],
          //   key: 'face',
          // );

          setState(() => _loadingSubmit = false);
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Menupage()),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() => _loadingSubmit = false);
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterPage(model: param, category: type),
            ),
          );
        }
      } else {
        logE('login social else');
        setState(() => _loadingSubmit = false);
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      logE('login social catch');
      logE(e);
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'ยกเลิก');
    }
  }

  void _callLoginSocialNewPassword(dynamic param, String type) async {
    setState(() => _loadingSubmit = true);
    try {
      if (param != null) {
        Dio dio = Dio();

        try {
          await Dio().post(
            '$serverUrl/dcc-api/m/register/reset/passwordbyusername',
            data: {
              'username': param['username'],
              'password': _passwordModalController.text,
            },
          );
        } catch (e) {
          Fluttertoast.showToast(msg: 'ลองใหม่อีกครั้ง');
          setState(() => _loadingSubmit = false);
          return;
        }
        var check = await dio.post(
          '$serverUrl/dcc-api/m/register/check/login/social',
          data: {'username': param['username']},
        );
        if (check.data) {
          Response response = await dio.post(
            '$serverUrl/dcc-api/m/v2/register/social/login/admin',
            data: param,
          );
          // logWTF(response.data);
          if (response.data['status'] != 'S') {
            setState(() => _loadingSubmit = false);
            return null;
          }

          // logWTF(response.data);

          // logWTF('token');
          String accessToken = await _getTokenKeycloak(
            username: response.data['objectData']['email'],
            password: response.data['objectData']['password'],
          );
          // logWTF(accessToken);

          if (accessToken == 'invalid_grant') {
            logWTF('password fail');
            Fluttertoast.showToast(msg: 'รหัสผ่านไม่ถูกต้อง');
            setState(() => _loadingSubmit = false);
            _modalPassword(param, type);
            return;
            // กรอกรหัสผ่าน
          }
          // logWTF(response);
          // logWTF('responseKeyCloak');
          dynamic responseKeyCloak = await _getUserInfoKeycloak(accessToken);
          // logWTF('responseProfileMe');
          dynamic responseProfileMe = await _getProfileMe(accessToken);
          // logWTF('responseStaffProfileData');
          dynamic responseStaffProfileData = await _getStaffProfileData(
            accessToken,
          );
          if (responseKeyCloak == null ||
              responseProfileMe == null ||
              responseStaffProfileData == null) {
            // Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
            return;
          }

          await ManageStorage.createSecureStorage(
            value: accessToken,
            key: 'accessToken_122',
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
            value: json.encode(responseProfileMe['data']),
            key: 'profileMe',
          );
          await ManageStorage.createProfile(
            value: response.data['objectData'],
            key: 'face',
          );

          setState(() => _loadingSubmit = false);
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Menupage()),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() => _loadingSubmit = false);
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterPage(model: param, category: type),
            ),
          );
        }
      } else {
        setState(() => _loadingSubmit = false);
        Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'ยกเลิก');
    }
  }

  void _modalPassword(dynamic param, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeildPassword(
                controller: _passwordModalController,
                hint: 'รหัสผ่าน',
                obscureText: _obscureTextPassword,
                autofillHints: const [AutofillHints.password],
                validateString: _passwordStringValidate,
                inputFormatters: InputFormatTemple.password(),
                suffixTap: () {
                  setState(() {
                    _obscureTextPassword = !_obscureTextPassword;
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
              const SizedBox(height: 20),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      _callLoginSocialNewPassword(param, type);
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _loadingSubmit
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.8)
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
                  if (_loadingSubmit)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
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
        );
      },
    );
  }
}
