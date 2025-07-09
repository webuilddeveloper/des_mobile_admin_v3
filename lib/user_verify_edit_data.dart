import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'shared/secure_storage.dart';

class UserVerifyEditDataPage extends StatefulWidget {
  const UserVerifyEditDataPage({super.key});

  @override
  State<UserVerifyEditDataPage> createState() => _UserVerifyEditDataPageState();
}

class _UserVerifyEditDataPageState extends State<UserVerifyEditDataPage> {
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
  String memberType = '0';
  String rangeAge = '0';
  int selectedSexIndex = 0;
  dynamic _userData = {};

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

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    txtFirstName.text = "";
    _getUserData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    var value = await ManageStorage.read('tempUser') ?? '';
    var result = json.decode(value);
    setState(() {
      memberType = memberTypeModel
          .firstWhere(
              (element) => element['title'] == result["memberType"])['value']
          .toString();
      txtFirstName.text = result["firstName"];
      txtLastName.text = result["lastName"];
      txtidcard.text = result["idcard"];
      rangeAge = rangeAgeModel
          .firstWhere(
              (element) => element['title'] == result["ageRange"])['value']
          .toString();
      txtEmail.text = result["email"];
      txtPhone.text = result["phone"];
      txtUserName.text = result["username"];
      txtPassword.text = result["password"];
    });
  }

  void onRefresh() async {
    _refreshController.refreshCompleted();
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
            const SizedBox(height: 20),
            _buildForm(),
            const SizedBox(height: 20),
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
          DropdownCustom(
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
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("ชื่อ", txtFirstName),
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("นามสกุล", txtLastName),
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("เลขบัตรประชาชน", txtidcard),
          const SizedBox(
            height: 15,
          ),
          DropdownCustom(rangeAgeModel, "ช่วงอายุ", (value) {
            setState(() {
              rangeAge = value;
            });
          }, rangeAge),
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("E-mail", txtEmail),
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("หมายเลขโทรศัพท์", txtPhone),
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("ชื่อผู้ใช้งาน", txtUserName),
          const SizedBox(
            height: 15,
          ),
          labelTextFormField("รหัสผ่าน", txtPassword),
          const SizedBox(
            height: 60,
          ),
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

  DropdownCustom(List<dynamic> itemModel, String label, Function onChanged,
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
    };

    await ManageStorage.createSecureStorage(
      key: 'tempUser',
      value: json.encode(param),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }
}
