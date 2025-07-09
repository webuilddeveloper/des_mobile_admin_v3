import 'dart:convert';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/verify_phone.dart';
import 'package:des_mobile_admin_v3/verify_route.dart';
import 'package:flutter/material.dart';

class VerifyConfirmDataPage extends StatefulWidget {
  const VerifyConfirmDataPage({super.key});

  @override
  State<VerifyConfirmDataPage> createState() => _VerifyConfirmDataPageState();
}

class _VerifyConfirmDataPageState extends State<VerifyConfirmDataPage> {
  dynamic _userData = {};
  bool _loadingSubmit = false;
  String imageFace = '';
  List<String> _checkImageList = [];

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    var value = await ManageStorage.read('tempAdmin') ?? '';
    var result = json.decode(value);
    setState(() {
      _userData = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4FF),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
          left: 20,
          right: 20,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 40),
            Text(
              'ยืนยันข้อมูลเจ้าหน้าที่',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.start,
            ),
            const Text(
              'โปรดยืนยันว่าข้อมูลของท่านถูกต้อง',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 25),
            // Center(
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(75),
            //     child: Image.memory(
            //       widget.imageUint8List,
            //       height: 150,
            //       width: 150,
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItem(
                    title: 'ประเภทสมาชิก',
                    value: '${_userData['memberType'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ศูนย์ดิจิทัลชุมชนที่ประจำการ',
                    value:
                        '${_userData['centerName'] ?? '-'} จ.${_userData['province'] ?? '-'}',
                  ),
                  // const SizedBox(height: 25),
                  // _buildItem(
                  //   title: 'รหัสสมาชิก',
                  //   value: '${_userData['employeeID'] ?? '-'}',
                  // ),
                  // const SizedBox(height: 25),
                  // _buildItem(
                  //   title: 'ชื่อ-นามสกุล',
                  //   value: '${_userData['fullName'] ?? '-'}',
                  // ),
                  // const SizedBox(height: 25),
                  // _buildItem(
                  //   title: 'เลขประจำตัวประชาชน',
                  //   value: '${_userData['idcard'] ?? '-'}',
                  // ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'ช่วงอายุ',
                    value: '${_userData['ageRange'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: ' E-mail',
                    value: '${_userData['email'] ?? '-'}',
                  ),
                  const SizedBox(height: 25),
                  _buildItem(
                    title: 'หมายเลขโทรศัพท์',
                    value: '${_userData['phone'] ?? '-'}',
                  ),
                  // const SizedBox(height: 25),
                  // if (_userData['from'] == '')
                  //   _buildItem(
                  //     title: 'ชื่อผู้ใช้งาน',
                  //     value: '${_userData['username'] ?? '-'}',
                  //   ),
                  // const SizedBox(height: 25),
                  // if (_userData['from'] == '')
                  //   _buildItem(
                  //     title: 'รหัสผ่าน',
                  //     value: '${_userData['password'] ?? '-'}',
                  //   ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifyPhonePage(phone: _userData['phone']),
                  ),
                );
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x40F3D2FF),
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  'แก้ไขข้อมูลลงทะเบียน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  _buildItem({String title = '', String value = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0x807209B7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
