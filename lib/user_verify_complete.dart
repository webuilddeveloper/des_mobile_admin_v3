import 'package:des_mobile_admin_v3/menu.dart';
import 'package:flutter/material.dart';

class UserVerifyCompletePage extends StatelessWidget {
  const UserVerifyCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF4FF),
        body: Center(
          child: SizedBox(
            height: 330,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/like_success.png',
                  height: 150,
                  width: 150,
                ),
                Text(
                  'ลงทะเบียนสมาชิก\nและยืนยันตัวตนสำเร็จ!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Menupage(),
                        ),
                      );
                    },
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
                        'เข้าสู่หน้าหลัก',
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
        ),
      ),
    );
  }
}
