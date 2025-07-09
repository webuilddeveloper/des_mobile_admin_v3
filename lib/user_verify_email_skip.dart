import 'package:flutter/material.dart';
import 'user_verify_email.dart';
import 'user_verify_face.dart';

class UserVerifyEmailSkipPage extends StatefulWidget {
  const UserVerifyEmailSkipPage({Key? key}) : super(key: key);

  @override
  State<UserVerifyEmailSkipPage> createState() =>
      _UserVerifyEmailSkipPageState();
}

class _UserVerifyEmailSkipPageState extends State<UserVerifyEmailSkipPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFAF4FF),
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
            left: 20,
            right: 20,
          ),
          child: ListView(
            children: [
              const SizedBox(height: 120),
              Image.asset(
                'assets/images/verify_email_pic.png',
                height: 166,
                width: 205,
              ),
              Text(
                'ยืนยันตัวตน\nด้วยอีเมล',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                'ท่านสามารถข้ามขั้นตอนนี้ \nและกลับมายืนยันตัวตนด้วยอีเมลอีกครั้งได้ในภายหลัง',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const UserVerifyEmailPage(),
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (_, a, __, c) => FadeTransition(opacity: a, child: c),
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
                      ),
                    ],
                  ),
                  child: const Text(
                    'ดำเนินการต่อ',
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
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const UserVerifyFacePage(),
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (_, a, __, c) => FadeTransition(opacity: a, child: c),
                    ),
                  );
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
                      ),
                    ],
                  ),
                  child: Text(
                    'ข้ามขั้นตอนนี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
