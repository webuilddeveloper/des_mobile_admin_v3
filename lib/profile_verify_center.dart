import 'dart:convert';

import 'package:des_mobile_admin_v3/register.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';
import 'menu.dart';

enum ValidateStatus { empty, pass, fail }

class ProfileVerifyCenterPage extends StatefulWidget {
  const ProfileVerifyCenterPage({super.key});

  @override
  State<ProfileVerifyCenterPage> createState() =>
      _ProfileVerifyCenterPageState();
}

class _ProfileVerifyCenterPageState extends State<ProfileVerifyCenterPage> {
  late bool _loading;
  String _loadingDropdown = '';
  String _provinceSelected = '';
  String _centerSelected = '';
  late TextEditingController _centerController;
  late TextEditingController txtDescription;
  final _controller = ScrollController();
  String keySearch = "";
  String _centerStringValidate = '';
  dynamic _center;
  dynamic _province;

  List<dynamic> _provinceList = [
    {'code': '', 'title': 'เลือกจังหวัด'}
  ];

  List<dynamic> _centerList = [
    {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
  ];
  List<dynamic> _centerListTemp = [
    {'code': '', 'title': 'เลือกศูนย์ดิจิทัลชุมชน'}
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCF9FF),
          elevation: 0,
          leadingWidth: 50,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'ยืนยันศูนย์ดิจิทัลที่ประจำการ',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFAF4FF),
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
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
                if (_provinceSelected.isNotEmpty) {
                  _getCenter();
                }
              },
            ),
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
            const SizedBox(height: 33),
            GestureDetector(
              onTap: () async {
                _register();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _loading
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
                    if (_loading)
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
            key: key,
            focusNode: focusNode,
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

  @override
  void initState() {
    _centerController = TextEditingController(text: '');
    txtDescription = TextEditingController(text: '');
    _loading = false;
    _getProvinceCenter();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  _register() async {
    try {
      var value = await ManageStorage.read('profileData') ?? '';
      var user = json.decode(value);

      var centerCode = _centerList
          .firstWhere((e) => e['title'] == _centerController.text)['code'];
      user['centerName'] = _centerController.text;
      user['centerCode'] = centerCode;

      var response = await Dio().post(
        '$serverUrl/dcc-api/m/Register/update/adminCenter',
        data: user,
      );
      if (response.statusCode == 200) {
        await ManageStorage.createProfile(
          key: '',
          value: response.data['objectData'],
        );

        if (!mounted) return;

        _dialog(text: 'ลงทะเบียนศูนย์ดิจิทัลที่ประจำการสำเร็จ');
      }
    } catch (e) {
      logE('$e');
    }
  }

  _dialog({required String text, bool error = false}) {
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
              if (!error) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const Menupage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
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
                  style: const TextStyle(
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
              if (_loadingDropdown != "center") _centerDialog();
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

  _centerDialog() {
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
              content: Container(
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
                        SizedBox(
                          width: 8.0,
                        ),
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
              setData(value);
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
              content: Container(
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
                        SizedBox(
                          width: 8.0,
                        ),
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
}
