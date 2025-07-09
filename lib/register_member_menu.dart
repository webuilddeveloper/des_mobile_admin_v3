import 'dart:async';
import 'dart:convert';
import 'package:des_mobile_admin_v3/user_verify_face.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'config.dart';
import 'shared/secure_storage.dart';

// ignore: must_be_immutable
class RegisterMemberMenuPage extends StatefulWidget {
  const RegisterMemberMenuPage({super.key});

  @override
  State<RegisterMemberMenuPage> createState() => _RegisterMemberMenuPageState();
}

class _RegisterMemberMenuPageState extends State<RegisterMemberMenuPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtidcard = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtUserName = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtAddress = TextEditingController();

  String memberType = '0';
  String rangeAge = '0';
  String provinceSelected = '';
  String districtSelected = '';
  String subDistrictSelected = '';
  String postCodeSelected = 'รหัสไปรษณีย์';
  String provinceName = '';
  String districtName = '';
  String subDistrictName = '';
  int selectedSexIndex = 0;

  List<dynamic> memberTypeModel = [
    {"title": "สมาชิกทั่วไป", "value": 0},
    {"title": "Emerald", "value": 1},
    {"title": "Gold", "value": 2},
    {"title": "Platinum", "value": 3},
  ];

  List<dynamic> rangeAgeModel = [
    {"title": "0 - 20 ปี", "value": 0},
    {"title": "21 - 40 ปี", "value": 1},
    {"title": "41 - 60 ปี", "value": 2},
    {"title": "61 - 80 ปี", "value": 3},
  ];

  List<dynamic> listSexModel = [
    {"title": "นาย", "value": 0},
    {"title": "นาง", "value": 1},
    {"title": "นางสาว", "value": 2},
  ];

  List<dynamic> provinceList = [
    {'code': '', 'title': 'เลือกจังหวัด'}
  ];

  List<dynamic> districtList = [
    {'code': '', 'title': 'เลือกอำเภอ'}
  ];
  List<dynamic> subDistrictList = [
    {'code': '', 'title': 'เลือกตำบล'}
  ];
  List<dynamic> postCodeList = [
    {'code': '', 'title': 'เลือกรหัสไปรษณีย์'}
  ];

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    setState(() {
      txtFirstName.text = "";
    });
    getProvince();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  Future<dynamic> getProvince() async {
    dynamic response =
        await Dio().post("$serverUrl/dcc-api/route/province/read", data: {});
    if (response.statusCode == 200) {
      setState(() {
        provinceList = [
          {'code': '', 'title': 'เลือกจังหวัด'},
          ...response.data['objectData']
        ];
      });
    }
  }

  Future<dynamic> getDistrict() async {
    dynamic response = await Dio().post(
      "$serverUrl/dcc-api/route/district/read",
      data: {
        'province': provinceSelected,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        districtList = [
          {'code': '', 'title': 'เลือกอำเภอ'},
          ...response.data['objectData']
        ];
      });
    }
  }

  Future<dynamic> getSubDistrict() async {
    dynamic response = await Dio().post(
      "$serverUrl/dcc-api/route/tambon/read",
      data: {
        'province': provinceSelected,
        'district': districtSelected,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        subDistrictList = [
          {'code': '', 'title': 'เลือกตำบล'},
          ...response.data['objectData']
        ];
      });
    }
  }

  Future<dynamic> getPostCode() async {
    dynamic response = await Dio().post(
      "$serverUrl/dcc-api/route/postcode/read",
      data: {
        'tambon': subDistrictSelected,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        postCodeList = [
          {'code': '', 'title': 'เลือกรหัสไปรษณีย์'},
          response.data['objectData'],
        ];
      });
    }
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
          title: const Text(
            'ลงทะเบียนสมาชิก',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          dropdownCustom(
            memberTypeModel,
            "ประเภทสมาชิก",
            (value) {
              setState(() {
                memberType = value;
              });
            },
            memberType,
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listSexModel.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // FocusScope.of(context).unfocus();
                      // var status;
                      setState(() {
                        selectedSexIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 15),

                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: 0,
                      // ),
                      // child: SizedBox(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFF3D2FF),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Container(
                                width: 15,
                                height: 15,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: index == selectedSexIndex
                                    ? Padding(
                                        padding: const EdgeInsets.all(2.5),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF7209B7),
                                            // color: Colors.white
                                          ),
                                        ),
                                      )
                                    : const SizedBox()),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            listSexModel[index]['title'],
                            style: TextStyle(
                              color: index == selectedSexIndex
                                  ? Color(0xFF7209B7)
                                  : Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                              // letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          labelTextFormField("ชื่อ", txtFirstName),
          const SizedBox(height: 15),
          labelTextFormField("นามสกุล", txtLastName),
          const SizedBox(height: 15),
          labelTextFormField("เลขบัตรประชาชน", txtidcard),
          const SizedBox(height: 15),
          dropdownCustom(rangeAgeModel, "ช่วงอายุ", (value) {
            setState(() {
              rangeAge = value;
            });
          }, rangeAge),
          const SizedBox(height: 15),
          labelTextFormField("ที่อยู่ บ้านเลขที่ ซอย หมู่ ถนน", txtAddress),
          const SizedBox(height: 15),
          _dropdown(
            data: provinceList,
            value: provinceSelected,
            onChanged: (String value) {
              setState(() {
                provinceSelected = value;
                provinceName =
                    provinceList.firstWhere((e) => e['code'] == value)['title'];
                districtSelected = '';
                subDistrictSelected = '';
                postCodeSelected = 'รหัสไปรษณีย์';
                districtList = [
                  {'code': '', 'title': 'เลือกอำเภอ'}
                ];
                subDistrictList = [
                  {'code': '', 'title': 'เลือกตำบล'}
                ];
              });
              print('provinceName ${provinceName}');
              getDistrict();
            },
          ),
          const SizedBox(height: 15),
          _dropdown(
            data: districtList,
            value: districtSelected,
            onChanged: (String value) {
              setState(() {
                districtSelected = value;
                districtName =
                    districtList.firstWhere((e) => e['code'] == value)['title'];
                subDistrictSelected = '';
                postCodeSelected = 'รหัสไปรษณีย์';
                subDistrictList = [
                  {'code': '', 'title': 'เลือกตำบล'}
                ];
              });
              print('districtName ${districtName}');
              getSubDistrict();
            },
          ),
          const SizedBox(height: 15),
          _dropdown(
            data: subDistrictList,
            value: subDistrictSelected,
            onChanged: (String value) {
              String postcode = subDistrictList.firstWhere(
                  (element) => value == element['code'])['postCode'];
              setState(() {
                subDistrictSelected = value;
                subDistrictName = subDistrictList
                    .firstWhere((e) => e['code'] == value)['title'];
                postCodeSelected = postcode;
              });
              print('subDistrictName ${subDistrictName}');
              print('postCodeSelected ${postCodeSelected}');
              getPostCode();
            },
          ),
          const SizedBox(height: 15),
          labelText(postCodeSelected),
          const SizedBox(height: 15),
          labelTextFormField("E-mail", txtEmail),
          const SizedBox(height: 15),
          labelTextFormField("หมายเลขโทรศัพท์", txtPhone),
          const SizedBox(height: 15),
          labelTextFormField("ชื่อผู้ใช้งาน", txtUserName),
          const SizedBox(height: 15),
          labelTextFormField("รหัสผ่าน", txtPassword),
          const SizedBox(height: 60),
          GestureDetector(
            onTap: () => _submit(),
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
                  'ลงทะเบียน',
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
        ],
      ),
    );
  }

  labelText(String title) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        // height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF7209B7).withOpacity(.50),
          ),
        ),
      ),
    );
  }

  labelTextFormField(
    String label,
    TextEditingController txtController,
  ) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        // height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SizedBox(
          child: TextFormField(
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            controller: txtController,
            decoration: InputDecoration(
              labelText: label,
              labelStyle:
                  TextStyle(color: const Color(0xFF7209B7).withOpacity(.50)),
              floatingLabelStyle: TextStyle(
                  color: const Color(0xFF7209B7).withOpacity(.50),
                  fontSize: 12),
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

  dropdownCustom(List<dynamic> itemModel, String label, Function onChanged,
      String valueDropdown) {
    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        width: double.infinity,
        // height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SizedBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.expand_more,
                color: const Color(0xFF7209B7).withOpacity(0.5),
                size: 40,
              ),
              items: itemModel.map<DropdownMenuItem<String>>(
                (value) {
                  return DropdownMenuItem(
                    value: value['value'].toString(),
                    child: Text(
                      value['title'].toString(),
                      style: TextStyle(
                        color: const Color(0xFF7209B7).withOpacity(.50),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                onChanged(value);
              },
              hint: Text(
                label,
                style: TextStyle(
                    color: const Color(0xFF7209B7).withOpacity(.50),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              value: valueDropdown,
            ),
          ),
        ),
      ),
    );
  }

  _submit() async {
    var param = {
      'category': 'guest',
      'memberType': memberTypeModel.firstWhere(
          (element) => element['value'] == int.parse(memberType))['title'],
      'firstName': txtFirstName.text,
      'lastName': txtLastName.text,
      'fullName': '${txtFirstName.text} ${txtLastName.text}',
      'idcard': txtidcard.text,
      'ageRange': rangeAgeModel.firstWhere(
          (element) => element['value'] == int.parse(rangeAge))['title'],
      'email': txtEmail.text,
      'phone': txtPhone.text,
      'username': txtUserName.text,
      'password': txtPassword.text,
      'address': txtAddress.text,
      'provinceCode': provinceSelected,
      'amphoeCode': districtSelected,
      'tambonCode': subDistrictSelected,
      'postnoCode': postCodeSelected,
      'province': provinceName,
      'amphoe': districtName,
      'tambon': subDistrictName,
      'postno': postCodeSelected,
    };

    await ManageStorage.createSecureStorage(
      key: 'tempUser',
      value: json.encode(param),
    );
    if (!mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const UserVerifyFacePage()));
  }

  _dropdown({
    required List<dynamic> data,
    required String value,
    Function(String)? onChanged,
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
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        width: double.infinity,
        // height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SizedBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.expand_more,
                color: const Color(0xFF7209B7).withOpacity(0.5),
                size: 40,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0x807209B7),
              ),
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
                      color: const Color(0xFF7209B7).withOpacity(.50),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Kanit',
                    ),
                  ),
                );
              }).toList(),
              // hint: Text(
              //   label,
              //   style: TextStyle(
              //       color: const Color(0xFF7209B7).withOpacity(.50),
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500),
              // ),
            ),
          ),
        ),
      ),
    );
  }
//
}
