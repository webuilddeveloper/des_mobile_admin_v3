import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/image_picker.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:ui' as ui show ImageFilter;

import 'config.dart';
import 'menu.dart';
import 'widget/input_decoration.dart';

// ignore: must_be_immutable
class ProfileFormPage extends StatefulWidget {
  ProfileFormPage({super.key, this.changePage, this.title});
  late _ProfileFormPageState homeCentralPageState;
  Function? changePage;
  String? title;

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();

  getState() => homeCentralPageState;
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  // late Future<dynamic> _futureProfile;
  dynamic _model;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProfile;
  bool _loadingSubmit = false;
  XFile? _imageFile;
  String _imageProfile = '';

  late TextEditingController txtFirstName;
  late TextEditingController txtLastName;
  late TextEditingController txtEmail;
  late TextEditingController txtIdCard;
  late TextEditingController txtPhone;
  late TextEditingController txtUserName;
  late TextEditingController txtPassword;

  bool _obscureTextPassword = true;
  String _passwordStringValidate = '';

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    txtFirstName = TextEditingController(text: '');
    txtLastName = TextEditingController(text: '');
    txtEmail = TextEditingController(text: '');
    txtIdCard = TextEditingController(text: '');
    txtPhone = TextEditingController(text: '');
    txtUserName = TextEditingController(text: '');
    txtPassword = TextEditingController(text: '');
    _getImageProfile();
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    txtFirstName.dispose();
    txtLastName.dispose();
    txtEmail.dispose();
    txtIdCard.dispose();
    txtPhone.dispose();
    txtUserName.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  _getImageProfile() async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      var responseCenter = await Dio().get(
        '$ondeURL/api/user/GetImageProfile/${profileMe['userid']}',
      );

      setState(() {
        _imageProfile = responseCenter.data;
      });
    } catch (e) {
      logE('_getImageProfile');
    }
  }

  _callRead() async {
    var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
    var staffProfileData =
        await ManageStorage.readDynamic('staffProfileData') ?? '';

    setState(() {
      _model = profileMe;
      _model['roleName'] = staffProfileData?['roleName'] ?? '';
      _model['centerName'] = staffProfileData?['centerName'] ?? '';
      txtFirstName.text = profileMe?['firstnameTh'] ?? '';
      txtLastName.text = profileMe?['lastnameTh'] ?? '';
      txtIdCard.text = profileMe?['idcard'] ?? '';
      txtPhone.text = profileMe?['phonenumber'] ?? '';
      txtUserName.text = profileMe?['email'] ?? '';
      txtPassword.text = '';
    });
  }

  _uploadImage(XFile file) async {
    var serverUpload = '$serverUrl/de-document/upload';
    try {
      Dio dio = Dio();
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "ImageCaption": "de_profile",
        "Image": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      Response response = await dio.post(serverUpload, data: formData);
      _model['imageUrl'] = response.data?['imageUrl'];
    } catch (e) {
      setState(() => _loadingSubmit = false);
      logE(e);
      // throw Exception(e);
      //return empty list (you can also return custom error to be handled by Future Builder)
    }
  }

  _save() async {
    try {
      setState(() => _loadingSubmit = true);
      String base64Image = '';
      File? file;
      logWTF(_imageFile);
      if ((_imageFile?.path ?? '') != '') {
        file = File(_imageFile!.path);
      }
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';

      logWTF(file);

      FormData formData = FormData.fromMap({
        'Userid': _model['userid'],
        'Phonenumber': txtPhone.text,
        'photo':
            file != null
                ? await MultipartFile.fromFile(
                  file.path,
                  filename: _imageFile!.name,
                )
                : null,
        'Firstname': _model['firstnameTh'],
        'Lastname': _model['lastnameTh'],
        'Email': _model['email'],
        'Dob': _model['dob'],
        'Gender': _model['gender'],
        'JobName': _model?['jobName'] ?? '',
        'LmsCat': _model?['lmsCat'] ?? '',
      });

      Response response = await Dio().put(
        '$ondeURL/api/user/UpdateById',
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          responseType: ResponseType.json,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        var accessToken = await ManageStorage.read('accessToken_122') ?? '';

        var profileMe = await _getProfileMe(accessToken);

        await ManageStorage.createSecureStorage(
          value: json.encode(profileMe['data']),
          key: 'profileMe',
        );

        setState(() => _loadingSubmit = false);
        _dialog(text: 'อัพเดตข้อมูลเรียบร้อยแล้ว');
      } else {
        logE(response.data);
        setState(() => _loadingSubmit = false);
        _dialog(text: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง', error: true);
      }
    } on DioError catch (e) {
      logE('e.error');
      logE(e.error);
      setState(() => _loadingSubmit = false);
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
      Fluttertoast.showToast(msg: err);
      return null;
    }
  }

  dynamic _getProfileMe(String token) async {
    try {
      // get info
      if (token.isEmpty) return null;
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

  _dialog({required String text, bool error = false}) {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
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
                  if (!error) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Menupage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          ),
    );
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
                onTap: () => {goBack()},
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
          // backgroundColor: Color(0xFF9A1120),
          centerTitle: true,
          title: Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: ListView(
          children: [_buildUser(), const SizedBox(height: 10), _buildForm()],
        ),
      ),
    );
  }

  Widget _buildUser() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _modalImagePicker(),
                child: SizedBox(
                  height: 90,
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child:
                        _imageFile != null
                            ? Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            )
                            : Image.memory(
                              base64Decode(_imageProfile),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                    ),
                                  ),
                            ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 5,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFF7209B7),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset("assets/images/camera.png"),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_model?['firstnameTh'] ?? ''} ${_model?['lastnameTh'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '${_model?['roleName'] ?? ''} ${_model?['centerName'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  // textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          labelTextFormField("ชื่อ", txtFirstName, readOnly: true),
          const SizedBox(height: 15),
          labelTextFormField("นามสกุล", txtLastName, readOnly: true),
          const SizedBox(height: 15),
          labelTextFormField("เลขบัตรประชาชน", txtIdCard, readOnly: true),
          const SizedBox(height: 15),
          labelTextFormField("ชื่อผู้ใช้งาน", txtUserName, readOnly: true),
          const SizedBox(height: 15),
          labelTextFormField("โทรศัพท์มือถือ", txtPhone),
          const SizedBox(height: 60),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _save();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  // height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7209B7),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: const SizedBox(
                    // height: 60,
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (_loadingSubmit)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: const [
          //     Text(
          //       'ยืนยัน',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16,
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
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

  labelTextFormField(
    String label,
    TextEditingController txtController, {
    bool readOnly = false,
    bool obscureText = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 249, 233, 255),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        // height: 48,
        decoration: BoxDecoration(
          color: readOnly ? Colors.black.withOpacity(0.3) : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: SizedBox(
          child: TextFormField(
            readOnly: readOnly,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            controller: txtController,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black),
              floatingLabelStyle: TextStyle(
                color: Colors.black.withOpacity(0.24),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _modalImagePicker() {
    bool loading = false;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter mSetState /*You can rename this!*/,
          ) {
            return SafeArea(
              child: SizedBox(
                height: 120 + MediaQuery.of(context).padding.bottom,
                child: Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        SizedBox(
                          child: ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Photo Library'),
                            onTap: () async {
                              try {
                                mSetState(() {
                                  loading = true;
                                });
                                XFile? image = await ImagePickerFrom.gallery();

                                setState(() {
                                  _imageFile = image;
                                });
                              } catch (e) {
                                Fluttertoast.showToast(msg: 'ลอกงอีกครั้ง');
                              }
                              if (!mounted) return;
                              mSetState(() {
                                loading = false;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Camera'),
                          onTap: () async {
                            try {
                              mSetState(() {
                                loading = true;
                              });
                              XFile? image = await ImagePickerFrom.camera();

                              setState(() {
                                _imageFile = image;
                              });
                            } catch (e) {
                              Fluttertoast.showToast(msg: 'ลอกงอีกครั้ง');
                            }
                            if (!mounted) return;
                            mSetState(() {
                              loading = false;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    if (loading)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
