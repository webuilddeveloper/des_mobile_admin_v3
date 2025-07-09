import 'package:des_mobile_admin_v3/login.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'menu.dart';

// ignore: must_be_immutable
class PolicyPage extends StatefulWidget {
  const PolicyPage({
    Key? key,
    this.code,
  }) : super(key: key);
  final String? code;

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String pf = await ManageStorage.read('profileCode') ?? '';

      if (pf.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    });
    _callCheckPolicy();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDF8),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 15, left: 35, right: 35),
            child: Text(
              'นโยบายการคุ้มครองข้อมูลส่วนบุคคลสำหรับบุคคลทั่วไป',
              style: TextStyle(
                fontSize: 23,
                color: Color(0xFF53327A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(35.0),
            child: Text(
              '''1. ข้อมูลส่วนบุคคลที่เก็บรวบรวม
เก็บรวบรวมข้อมูลส่วนบุคคลของเจ้ำของข้อมูลส่วนบุคคล ทั่วไป ดังต่อไปนี้
     o ข้อมูลที่ใช้ระบุตัวตน เช่น ชื่อ นามสกุล เลขบัตรประจำตัวประชาชน รูปถ่าย
     o ข้อมูลติดต่อ เช่น หมายเลขโทรศัพท์ e-mail

2. วัตถุประสงค์และฐานอันชอบธรรมตามกฎหมายของการประมวลผลข้อมูลส่วนบุคคลเพื่อวัตถุประสงค์ทำงธุรกิจตามมาตรฐาน
วิชาชีพ ดังนี้
     o เพื่อเก็บประวัติการใช้งานของสมาชิกและนำข้อมูลมาแสดงผ่านระบบ
     
3. การเปลี่ยนแปลงนโยบายการคุ้มครองข้อมูลส่วนบุคคล
อาจดำเนินการปรับปรุงหรือเปลี่ยนแปลงนโยบายการคุ้มครองข้อมูลส่วนบุคคลนี้ เพื่อให้สอดคล้อง
กับการเปลี่ยนแปลงใด ๆ ในการเก็บ รวบรวมใช้และเปิดเผยข้อมูลส่วนบุคคลของเจ้าของข้อมูลส่วนบุคคล หรือ
การเปลี่ยนแปลงใด ๆ ของกฎหมายว่าด้วยการคุ้มครองข้อมูลส่วนบุคคลหรือกฎหมายอื่นที่เกี่ยวข้อง
ทั้งนี้ ขอให้เจ้าของข้อมูลส่วนบุคคลทำการตรวจสอบทบทวนนโยบายนี้เป็นครั้งคราว
''',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () async {
                final storage = new FlutterSecureStorage();
                await storage.write(key: 'policy', value: 'Y');

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const Menupage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF7A4CB1),
                ),
                child: const Text(
                  'ยอมรับการใช้งาน',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callCheckPolicy() async {
    final storage = new FlutterSecureStorage();
    String isPolicy = await storage.read(key: 'policy') ?? '';

    if (isPolicy != '') {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Menupage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
