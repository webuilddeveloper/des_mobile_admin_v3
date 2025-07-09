import 'dart:convert';

import 'package:des_mobile_admin_v3/register_link_account.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/google_firebase.dart';
import 'package:des_mobile_admin_v3/shared/line.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/verify_confirm_data.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'policy_web.dart';

enum ValidateStatus { empty, pass, fail }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.model, this.category = ''});

  final dynamic model;
  final String category;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loadingSubmit = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idCardController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _employeeIDController;
  late TextEditingController _centerController;
  final txtDescription = TextEditingController();
  String keySearch = "";
  late FocusNode _focusNodeEmail;
  final fieldEmailKey = GlobalKey<FormFieldState>();
  final _controller = ScrollController();

  String _firstNameStringValidate = '';
  String _lastNameStringValidate = '';
  String _idCardStringValidate = '';
  String _emailStringValidate = '';
  String _phoneStringValidate = '';
  String _usernameStringValidate = '';
  String _passwordStringValidate = '';
  String _employeeStringValidate = '';
  String _centerStringValidate = '';
  String _loadingDropdown = '';
  dynamic _province;
  dynamic _center;

  List<dynamic> _provinceList = [
    {'code': '', 'title': 'เลือกจังหวัด'}
  ];
  List<dynamic> _districtList = [
    {'code': '', 'title': 'เลือกอำเภอ'}
  ];
  List<dynamic> _subDistrictList = [
    {'code': '', 'title': 'เลือกตำบล'}
  ];
  List<dynamic> _postCodeList = [
    {'code': '', 'title': 'เลือกรหัสไปรษณีย์'}
  ];
  List<dynamic> memberTypeList = [
    // {'code': '', 'title': 'เลือกประเภทสมาชิก'},
    {"code": '0', "title": "เจ้าหน้าที่ศูนย์"},
    // {"code": '1', "title": "Emerald"},
    // {"code": '2', "title": "Gold"},
    // {"code": '3', "title": "Platinum"},
  ];
  List<dynamic> ageRangeList = [
    {'code': '', 'title': 'เลือกช่วงอายุ', 'value': ''},
    // {'code': '00', 'title': 'ต่ำกว่า 15 ปี', 'value': 'ต่ำกว่า 15 ปี'},
    {'code': '2', 'title': '18 - 24 ปี', 'value': '18 - 24 ปี'},
    {'code': '3', 'title': '25 - 54 ปี', 'value': '25 - 54 ปี'},
    {'code': '4', 'title': '55 - 64 ปี', 'value': '55 - 64 ปี'},
    // {'code': '03', 'title': '51 - 60 ปี', 'value': '51 - 60 ปี'},
    {'code': '5', 'title': '65 ปีขึ้นไป', 'value': '65 ปีขึ้นไป'},
  ];

  List<dynamic> _centerList = [
    {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
  ];
  List<dynamic> _centerListTemp = [
    {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
  ];

 

  String _provinceSelected = '';
  String _districtSelected = '';
  String _subDistrictSelected = '';
  String _postCodeSelected = 'รหัสไปรษณีย์';
  String _memberTypeSelected = '0';
  String _ageRangeSelected = '';
  String _centerSelected = '';

  String _prefixName = '';
  bool _visibilityPassword = true;
  bool _acceptPolicy = false;

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
          child: SingleChildScrollView(
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
                    'ลงทะเบียนเจ้าหน้าที่',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // _dropdown(
                  //   data: memberTypeList,
                  //   value: _memberTypeSelected,
                  //   type: '',
                  //   onChanged: (String value) {
                  //     setState(() {
                  //       _memberTypeSelected = value;
                  //     });
                  //   },
                  // ),
                  // Row(
                  //   children: [
                  //     _buildRadio(
                  //       value: 'นาย',
                  //     ),
                  //     _buildRadio(
                  //       value: 'นาง',
                  //     ),
                  //     _buildRadio(
                  //       value: 'นางสาว',
                  //     ),
                  //   ],
                  // ),
                  // _buildFeild(
                  //   controller: _firstNameController,
                  //   hint: 'ชื่อ',
                  //   validateString: _firstNameStringValidate,
                  //   validator: (value) {
                  //     var result = ValidateForm.username(value!);
                  //     setState(() {
                  //       _firstNameStringValidate = result ?? '';
                  //     });
                  //     return result == null ? null : '';
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  // _buildFeild(
                  //   controller: _lastNameController,
                  //   hint: 'นามสกุล',
                  //   validateString: _lastNameStringValidate,
                  //   validator: (value) {
                  //     var result = ValidateForm.username(value!);
                  //     setState(() {
                  //       _lastNameStringValidate = result ?? '';
                  //     });
                  //     return result == null ? null : '';
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  // _buildFeild(
                  //   controller: _idCardController,
                  //   hint: 'เลขประจำตัวประชาชน',
                  //   validateString: _idCardStringValidate,
                  //   keyboardType: TextInputType.number,
                  //   // autovalidateMode: AutovalidateMode.onUserInteraction,
                  //   inputFormatters: InputFormatTemple.idcard(),
                  //   onChanged: (value) {
                  //     String result = ValidateForm.idcard(value!);
                  //     if (result.isNotEmpty && value.length == 13) {
                  //       setState(() {
                  //         _idCardStringValidate = result;
                  //       });
                  //     } else if (value.isNotEmpty && value.length == 13) {
                  //       setState(() {
                  //         _employeeIDController.text = _idCardController.text;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         _idCardStringValidate = '';
                  //         _employeeIDController.text = '';
                  //       });
                  //     }
                  //   },
                  //   validator: (value) {
                  //     String result = ValidateForm.idcard(value!);
                  //     setState(() {
                  //       _idCardStringValidate = result;
                  //     });
                  //     if (result.isNotEmpty) {
                  //       return '';
                  //     } else {
                  //       return null;
                  //     }
                  //   },
                  // ),
                  const SizedBox(height: 10),
                  _dropdown(
                    data: ageRangeList,
                    value: _ageRangeSelected,
                    type: '',
                    onChanged: (String value) {
                      setState(() {
                        _ageRangeSelected = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      _buildFeild(
                        key: fieldEmailKey,
                        focusNode: _focusNodeEmail,
                        controller: _emailController,
                        readOnly:
                            (widget.model?['email'] ?? '') != '' ? true : false,
                        hint: 'E-mail',
                        validateString: _emailStringValidate,
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),
                        validator: (value) {
                          var result = ValidateForm.email(value!);
                          setState(() {
                            _emailStringValidate = result ?? '';
                          });
                          return result == null ? null : '';
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildFeild(
                    controller: _phoneController,
                    hint: 'หมายเลขโทรศัพท์',
                    keyboardType: TextInputType.number,
                    validateString: _phoneStringValidate,
                    inputFormatters: InputFormatTemple.phone(),
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      var result = ValidateForm.phone(value!);
                      setState(() {
                        _phoneStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                  // const SizedBox(height: 10),
                  // if (widget.category.isEmpty)
                  //   _buildFeild(
                  //     controller: _usernameController,
                  //     hint: 'ชื่อผู้ใช้งาน',
                  //     readOnly: widget.category.isNotEmpty ? true : false,
                  //     validateString: _usernameStringValidate,
                  //     inputFormatters: InputFormatTemple.username(),
                  //     onEditingComplete: () => FocusScope.of(context).unfocus(),
                  //     validator: (value) {
                  //       var result = ValidateForm.username(value!);
                  //       setState(() {
                  //         _usernameStringValidate = result ?? '';
                  //       });
                  //       return result == null ? null : '';
                  //     },
                  //   ),
                  const SizedBox(height: 10),
                  if (widget.category.isEmpty)
                    _buildFeildPassword(
                      controller: _passwordController,
                      hint: 'รหัสผ่านเข้าสู่ระบบ',
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
                  const SizedBox(height: 30),
                  Text(
                    'ศูนย์ดิจิทัลชุมชนที่ประจำการ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _dropdown(
                    data: _provinceList,
                    value: _provinceSelected,
                    type: 'province',
                    onChanged: (String value) async {
                      setState(() {
                        _provinceSelected = value;
                        _centerSelected = '';
                        _centerController.text = '';
                        _centerList = [
                          {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
                        ];
                      });

                      // //set lat lng
                      // await ManageStorage.createSecureStorage(
                      //   value: _provinceList.firstWhere((element) =>
                      //       element['value'] == _provinceSelected)['latitude'],
                      //   key: 'latitude',
                      // );

                      // await ManageStorage.createSecureStorage(
                      //   value: _provinceList.firstWhere((element) =>
                      //       element['value'] == _provinceSelected)['longitude'],
                      //   key: 'longitude',
                      // );

                      if (_provinceSelected.isNotEmpty) {
                        _getCenter();
                      }
                    },
                  ),
                  // const SizedBox(height: 10),
                  // _dropdown(
                  //   data: _centerList,
                  //   value: _centerSelected,
                  //   type: 'center',
                  //   onChanged: (String value) async {
                  //     setState(() {
                  //       _centerSelected = value;
                  //     });
                  //   },
                  // ),
                  // _dropdown(
                  //   data: _districtList,
                  //   value: _districtSelected,
                  //   type: 'district',
                  //   onChanged: (String value) async {
                  //     setState(() {
                  //       _districtSelected = value;
                  //       _subDistrictSelected = '';
                  //       _postCodeSelected = 'รหัสไปรษณีย์';
                  //       _subDistrictList = [
                  //         {'code': '', 'title': 'เลือกตำบล'}
                  //       ];
                  //     });
                  //     if (_districtSelected.isNotEmpty) {
                  //       await getSubDistrict();
                  //     }
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  // _dropdown(
                  //   data: _subDistrictList,
                  //   value: _subDistrictSelected,
                  //   type: 'subDistrict',
                  //   onChanged: (String value) async {
                  //     String postcode = _subDistrictList.firstWhere(
                  //         (element) => value == element['code'])['postCode'];
                  //     setState(() {
                  //       _subDistrictSelected = value;
                  //       _postCodeSelected = postcode;
                  //     });
                  //     await getPostCode();
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  // Container(
                  //   height: 50,
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.only(left: 19),
                  //   alignment: Alignment.centerLeft,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(7),
                  //     boxShadow: const [
                  //       BoxShadow(
                  //         blurRadius: 4,
                  //         color: Color(0x40F3D2FF),
                  //         offset: Offset(0, 4),
                  //       )
                  //     ],
                  //   ),
                  //   child: Text(
                  //     _postCodeSelected,
                  //     style: const TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w400,
                  //       color: Color(0x807209B7),
                  //       height: 1,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  _buildFeildCenter(
                    controller: _centerController,
                    hint: 'ศูนย์ดิจิทัลชุมชน',
                    validateString: _centerStringValidate,
                    readOnly: true,
                    validator: (value) {
                      var result = ValidateForm.username(value!);
                      setState(() {
                        _centerStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                  // const SizedBox(height: 10),
                  // _buildFeild(
                  //   controller: _employeeIDController,
                  //   hint: 'รหัสพนักงาน',
                  //   validateString: _employeeStringValidate,
                  //   readOnly: true,
                  //   validator: (value) {
                  //     // var result = ValidateForm.username(value!);
                  //     // setState(() {
                  //     //   _employeeStringValidate = result ?? '';
                  //     // });
                  //     // return result == null ? null : '';
                  //   },
                  // ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.5,
                        child: Checkbox(
                          value: _acceptPolicy,
                          onChanged: (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PolicyWebPage(),
                              ),
                            ).then((value) {
                              setState(() {
                                _acceptPolicy = value;
                              });
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ฉันยอมรับการให้ข้อมูล',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'ยอมรับการให้ข้อมูลเพื่อสมัครสมาชิก เพื่อให้เป็นไปตามหลักข้อกำหนดในการเก็บข้อมูลส่วนบุคคล',
                              style: TextStyle(
                                color: Color(0xFF707070),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (_acceptPolicy) {
                        final form = _formKey.currentState;
                        if (form!.validate() && !_loadingSubmit) {
                          form.save();
                          try {
                            // check prefixName not empty.
                            // if (_prefixName.isEmpty) {
                            //   Fluttertoast.showToast(
                            //       msg: 'กรุณาเลือกคำนำหน้าชื่อ');
                            //   return;
                            // }

                            // if (_memberTypeSelected.isEmpty) {
                            //   Fluttertoast.showToast(
                            //       msg: 'กรุณาเลือกประเภทสมาชิก');
                            //   return;
                            // }

                            if (_ageRangeSelected.isEmpty) {
                              Fluttertoast.showToast(msg: 'กรุณาเลือกช่วงอายุ');
                              return;
                            }
                            setState(() => _loadingSubmit = true);
                            // check duplicate username && idcard.
                            String usernameDup = await _checkDuplicateUser();
                            logWTF('usernameDup');
                            logWTF(usernameDup);
                            setState(() => _loadingSubmit = false);
                            if (usernameDup.isNotEmpty) {
                              if (usernameDup == 'อีเมลนี้ถูกใช้งานไปแล้ว' &&
                                  widget.category != '') {
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterLinkAccountPage(
                                      email: _emailController.text,
                                      category: widget.category,
                                      model: widget.model,
                                    ),
                                  ),
                                );
                                return;
                              }
                              Fluttertoast.showToast(msg: usernameDup);
                              return;
                            }

                            _register();
                          } catch (e) {
                            setState(() {
                              _loadingSubmit = false;
                            });
                            Fluttertoast.showToast(msg: 'error');
                          }
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _acceptPolicy
                            ? _loadingSubmit
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8)
                                : Theme.of(context).primaryColor
                            : const Color(0xFFc5c5c5),
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
                            'ลงทะเบียนเจ้าหน้าที่',
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
                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: 'มีบัญชีแล้ว',
                          style: TextStyle(
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
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadio({required String value}) {
    return GestureDetector(
      onTap: () => setState(() {
        _prefixName = value;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Row(
          children: [
            Container(
              height: 14.42,
              width: 14.42,
              padding: const EdgeInsets.all(2.45),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: value == _prefixName
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0x807209B7),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeild({
    Key? key,
    FocusNode? focusNode,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    Function(String?)? validator,
    Function(String?)? onChanged,
    Function(String?)? onFieldSubmitted,
    Function()? onEditingComplete,
    String validateString = '',
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
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
            key: key,
            focusNode: focusNode,
            readOnly: readOnly,
            onEditingComplete: () => onEditingComplete!(),
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (val) => onChanged!(val),
            onFieldSubmitted: (val) => onFieldSubmitted!(val),
            style: const TextStyle(fontSize: 14),
            decoration: CusInpuDecoration.base(
              context,
              hintText: hint,
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

  _dropdown({
    required List<dynamic> data,
    required String value,
    Function(String)? onChanged,
    required String type,
  }) {
    return Stack(
      children: [
        Container(
          height: 50,
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
          child: DropdownButtonFormField(
            icon: Image.asset(
              'assets/images/arrow_down.png',
              width: 16,
              height: 8,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0x807209B7),
            ),
            decoration: CusInpuDecoration.base(context),
            value: value,
            // validator: (value) =>
            //     value == '' || value == null ? 'กรุณาเลือก' : null,
            onChanged: (dynamic newValue) {
              onChanged!(newValue);
            },
            items: data.map((item) {
              return DropdownMenuItem(
                value: item['code'],
                child: Text(
                  '${item['title']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0x807209B7),
                    fontFamily: 'Kanit',
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (type == _loadingDropdown && type != '')
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.only(right: 50),
              alignment: Alignment.centerRight,
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeildCenter({
    Key? key,
    FocusNode? focusNode,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    Function(String?)? validator,
    Function(String?)? onChanged,
    Function(String?)? onFieldSubmitted,
    Function()? onEditingComplete,
    String validateString = '',
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
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
            key: key,
            focusNode: focusNode,
            readOnly: readOnly,
            onEditingComplete: () => onEditingComplete!(),
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (val) => onChanged!(val),
            onFieldSubmitted: (val) => onFieldSubmitted!(val),
            style: const TextStyle(fontSize: 14),
            decoration: CusInpuDecoration.base(
              context,
              hintText: hint,
            ),
            inputFormatters: inputFormatters,
            validator: (String? value) => validator!(value),
            onTap: () {
              setState(() {
                txtDescription.text = '';
                _centerListTemp = _centerList;
              });
              if (_loadingDropdown != "center") centerDialog();
            },
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

  @override
  void initState() {
    _firstNameController = TextEditingController(text: '');
    _lastNameController = TextEditingController(text: '');
    _idCardController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _usernameController = TextEditingController(text: '');
    _passwordController = TextEditingController(text: '');
    _employeeIDController = TextEditingController(text: '');
    _centerController = TextEditingController(text: '');
    _focusNodeEmail = FocusNode();
    logWTF('widget.category');
    logWTF(widget.category);
    _focusNodeEmail.addListener(() {
      if (!_focusNodeEmail.hasFocus) {
        fieldEmailKey.currentState!.validate();
      }
    });
    _setDataFromThridParty();
    _clearData();
    // _getProvince();
    _getProvinceCenter();

    super.initState();
  }

  _getProvinceCenter() async {
    try {
      setState(() => _loadingDropdown = 'province');
      var response = await Dio().get(
        '$ondeURL/api/masterdata/changwat',
      );
      if (response.statusCode == 200) {
        setState(() {
          _provinceList = [
            {'code': '', 'title': 'เลือกจังหวัด'}
          ];

          for (var i = 0; i < response.data.length; i++) {
            _province = {
              'code': response.data[i]['value'].toString(),
              'title': response.data[i]['label']
            };
            _provinceList.add(_province);
          }
          _loadingDropdown = '';
        });
      }
    } catch (e) {
      _loadingDropdown = '';
      Fluttertoast.showToast(msg: 'error $e');
    }
  }

  _getCenter() async {
    setState(() => _loadingDropdown = 'center');
    var response = await Dio().get(
      '$ondeURL/api/masterdata/centers/province/$_provinceSelected',
    );
    if (response.statusCode == 200) {
      setState(() {
        _centerList = [
          {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
        ];
        _centerListTemp = [
          {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
        ];

        for (var i = 0; i < response.data.length; i++) {
          _center = {
            'code': response.data[i]['value'].toString(),
            'title': response.data[i]['label']
          };
          _centerList.add(_center);
          _centerListTemp.add(_center);
        }
        _loadingDropdown = '';
      });
    }
  }

  _setDataFromThridParty() {
    if (widget.category.isNotEmpty) {
      logWTF(widget.model);
      setState(() {
        // _firstNameController.text = widget.model?['firstName'] ?? '';
        // _lastNameController.text = widget.model?['lastName'] ?? '';
        _emailController.text = widget.model?['email'] ?? '';
        _usernameController.text = widget.model?['username'] ?? '';
        _passwordController.text = widget.category;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idCardController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _employeeIDController.dispose();
    _centerController.dispose();
    _focusNodeEmail.dispose();
    switch (widget.category) {
      // case 'facebook':
      //   logoutFacebook();
      //   break;
      case 'google':
        logoutGoogle();
        break;
      case 'line':
        logoutLine();
        break;
      default:
    }
    super.dispose();
  }

  Future<dynamic> _getProvince() async {
    try {
      setState(() => _loadingDropdown = 'province');
      dynamic response =
          await Dio().post("$serverUrl/dcc-api/route/province/read", data: {});
      if (response.statusCode == 200) {
        setState(() {
          _provinceList = [
            {'code': '', 'title': 'เลือกจังหวัด'},
            ...response.data['objectData']
          ];
          _loadingDropdown = '';
        });
      }
    } catch (e) {
      _loadingDropdown = '';
      Fluttertoast.showToast(msg: 'error $e');
    }
  }

  Future<dynamic> getDistrict() async {
    setState(() => _loadingDropdown = 'district');
    dynamic response = await Dio().post(
      "$serverUrl/dcc-api/route/district/read",
      data: {
        'province': _provinceSelected,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _districtList = [
          {'code': '', 'title': 'เลือกอำเภอ'},
          ...response.data['objectData']
        ];
        _loadingDropdown = '';
      });
    }
  }

  Future<dynamic> getSubDistrict() async {
    setState(() => _loadingDropdown = 'subDistrict');
    dynamic response = await Dio().post(
      "$serverUrl/dcc-api/route/tambon/read",
      data: {
        'province': _provinceSelected,
        'district': _districtSelected,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _subDistrictList = [
          {'code': '', 'title': 'เลือกตำบล'},
          ...response.data['objectData']
        ];
        _loadingDropdown = '';
      });
    }
  }

  Future<dynamic> getPostCode() async {
    dynamic response = await Dio().post(
      "$serverUrl/dcc-api/route/postcode/read",
      data: {
        'tambon': _subDistrictSelected,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _postCodeList = [
          {'code': '', 'title': 'เลือกรหัสไปรษณีย์'},
          response.data['objectData'],
        ];
      });
    }
  }



  // Future<bool?> _checkDuplicateEmail() async {
  //   try {
  //     Response<bool> response = await Dio().get(
  //       '$ondeURL/api/user/verify/duplicate/${_emailController.text}',
  //     );
  //     return response.data;
  //   } catch (e) {
  //     setState(() {
  //       _loadingSubmit = false;
  //     });
  //     Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
  //   }
  //   return null;
  // }

  centerDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        bool testBool = true;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text(
                'ศูนย์ดิจิทัลชุมชน',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                // constraints:
                //     BoxConstraints(minWidth: 0, maxWidth: 300, maxHeight: 600),
                // padding: EdgeInsets.all(0),
                width: 300.0,
                height: 600.0,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: labelTextFormField(
                              'ค้นหาชื่อศูนย์ดิจิทัลชุมชน', txtDescription),
                        ),
                        const SizedBox(width: 8.0),
                        InkWell(
                          onTap: () {
                            setData(txtDescription.text);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.75),
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color(0xFF7209B7),
                            ),
                            child: Image.asset(
                              "assets/images/search.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 500.0, // Change as per your requirement
                      width: 600.0, // Change as per your requirement
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        controller: _controller,
                        itemCount: _centerListTemp.length,
                        itemBuilder: (context, index) {
                          return _buildContent(_centerListTemp[index]);
                        },
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(), // 2nd
                      ),
                    ),
                  ],
                ), //Column
              ),
            );
          },
        );
      },
    );
  }

  _buildContent(dynamic model) {
    return InkWell(
      onTap: () {
        _centerController.text = model['title'];
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(model['title']),
      ),
    );
  }

  Future<String> _checkDuplicateUser() async {
    try {
      Response<String> response = await Dio().get(
        '$serverUrl/dcc-api/m/register/admin/duplicate/${_emailController.text}/${_emailController.text}',
      );

      // if (response.data == 'username') {
      //   return 'ชื่อผู้ใช้งานนี้ถูกใช้งานไปแล้ว';
      // }
      if (response.data == 'email_validate') {
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      }
      if (response.data == 'email') {
        return 'อีเมลนี้ถูกใช้งานไปแล้ว';
      }
      if (response.data == 'server') {
        return 'internal server error';
      }

      return '';
    } catch (e) {
      return 'เกิดข้อผิดพลาด';
    }
  }

  _register() async {
    try {
      String? provinceName = '',
          districtName = '',
          subDistrictName = '',
          centerCode = '';

      if (_provinceSelected.isNotEmpty) {
        provinceName = _provinceList
            .firstWhere((e) => e['code'] == _provinceSelected)['title'];
      }

      if (_centerController.text != '') {
        centerCode = _centerList
            .firstWhere((e) => e['title'] == _centerController.text)['code'];
      }
      // if (_districtSelected.isNotEmpty) {
      //   districtName = _districtList
      //       .firstWhere((e) => e['code'] == _districtSelected)['title'];
      // }
      // if (_subDistrictSelected.isNotEmpty) {
      //   subDistrictName = _subDistrictList
      //       .firstWhere((e) => e['code'] == _subDistrictSelected)['title'];
      // }

      // if (_postCodeSelected == 'รหัสไปรษณีย์') {
      //   _postCodeSelected = '';
      // }

      dynamic param = {
        'memberType': memberTypeList.firstWhere(
            (element) => element['code'] == _memberTypeSelected)['title'],
        'prefixName': _prefixName,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'fullName': '${_firstNameController.text} ${_lastNameController.text}',
        'idcard': _idCardController.text,
        'age': int.parse(_ageRangeSelected),
        'ageRange': ageRangeList.firstWhere(
            (element) => element['code'] == _ageRangeSelected)['title'],
        'email': _emailController.text.toLowerCase(),
        'phone': _phoneController.text,
        'username': widget.category.isNotEmpty
            ? widget.model['username']
            : _emailController.text,
        'password': _passwordController.text,
        'provinceCode': _provinceSelected,
        'province': provinceName,
        // 'amphoeCode': _districtSelected,
        // 'amphoe': districtName,
        // 'tambonCode': _subDistrictSelected,
        // 'tambon': subDistrictName,
        // 'postnoCode': _postCodeSelected,
        // 'postno': _postCodeSelected,
        'centerName': _centerController.text,
        'centerCode': centerCode,
        'employeeID': _employeeIDController.text,
        'category': "face",
        'status': "N",
        'lineID': widget.model?['lineID'] ?? '',
        'googleID': widget.model?['googleID'] ?? '',
        'xID': widget.model?['xID'] ?? '',
        'facebookID': widget.model?['facebookID'] ?? '',
        'imageUrl': widget.model?['imageUrl'] ?? '',
        'from': widget.category,
      };

      logWTF(param);

      await ManageStorage.createSecureStorage(
        key: 'tempAdmin',
        value: json.encode(param),
      );
      setState(() {
        _loadingSubmit = false;
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const VerifyConfirmDataPage(),
        ),
      );
    } catch (e) {
      setState(() {
        _loadingSubmit = false;
      });
      print('$e');
    }
  }

  Widget labelTextFormField(
    String label,
    TextEditingController txtController,
  ) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 249, 233, 255),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        width: double.infinity,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        child: TextField(
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFCEA8F3)),
            controller: txtDescription,
            decoration: CusInpuDecoration.base(
              context,
              hintText: 'ค้นหาชื่อศูนย์ดิจิทัลชุมชน',
            ),
            onChanged: (value) {
              // setData(value);
            },
            focusNode: FirstDisabledFocusNode()),
      ),
    );
  }

  void setData(String keySearkch) {
    setState(() {
      keySearch = keySearkch;
      var result =
          _centerList.where((map) => map["title"].contains(keySearch)).toList();
      _centerListTemp = result;
      Navigator.pop(context);
      centerDialog();
    });
  }

  _clearData() async {
    ManageStorage.deleteStorage('tempAdmin');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('imageTempAdmin');
  }
}

class FirstDisabledFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    return false;
  }
}
