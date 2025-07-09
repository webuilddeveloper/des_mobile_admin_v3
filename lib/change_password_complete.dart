import 'package:des_mobile_admin_v3/menu.dart';
import 'package:flutter/material.dart';

class ChangePasswordCompletePage extends StatefulWidget {
  const ChangePasswordCompletePage({super.key});

  @override
  State<ChangePasswordCompletePage> createState() =>
      _ChangePasswordCompletePageState();
}

class _ChangePasswordCompletePageState
    extends State<ChangePasswordCompletePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF4FF),
        extendBody: true,
        body: ListView(
          children: [
            const SizedBox(height: 100),
            Image.asset(
              'assets/images/lock.png',
              height: 162.57,
              width: 96.58,
            ),
            const SizedBox(height: 20),
            Text(
              'เปลี่ยนรหัสผ่านใหม่ของคุณแล้ว',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Menupage(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
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
                    'กลับหน้าหลัก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
