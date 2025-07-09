import 'package:des_mobile_admin_v3/login.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCompletePage extends StatefulWidget {
  const VerifyCompletePage({super.key, this.model});

  final dynamic model;

  @override
  State<VerifyCompletePage> createState() => _VerifyCompletePageState();
}

class _VerifyCompletePageState extends State<VerifyCompletePage> {
  bool _loadingSubmit = false;
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {});
    _clearData();
    super.initState();
  }

  _clearData() async {
    ManageStorage.deleteStorage('tempAdmin');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('imageTempAdmin');
    await prefs.remove('thaiDCode');
    await prefs.remove('thaiDState');
    await prefs.remove('thaiDAction');
  }

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
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          setState(() => _loadingSubmit = true);
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (Route<dynamic> route) => false,
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
                            'เข้าสู่หน้าหลัก',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (_loadingSubmit)
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.5),
                            child: const SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
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
