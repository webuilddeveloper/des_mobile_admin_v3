import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/verify_email.dart';
import 'package:des_mobile_admin_v3/verify_phone.dart';
import 'package:flutter/material.dart';

import 'widget/input_decoration.dart';

class VerifyRoutePage extends StatefulWidget {
  const VerifyRoutePage({
    Key? key,
  }) : super(key: key);

  @override
  State<VerifyRoutePage> createState() => _VerifyRoutePageState();
}

class _VerifyRoutePageState extends State<VerifyRoutePage> {
  bool _loading = false;
  dynamic _userData;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                'assets/images/verify_phone_pic.png',
                height: 166,
                width: 205,
              ),
              Text(
                'ยืนยันตัวตน',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                'เลือกช่องทางการยืนยันตัวตน',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifyPhonePage(
                      phone: _userData['phone'],
                    ),
                  ),
                ),
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
                    'ยืนยันตัวตนด้วยเบอร์โทรศัพท์',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerifyEmailPage(),
                  ),
                ),
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
                    'ยืนยันตัวตนด้วยอีเมล',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
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

  Widget _buildFeild({
    required TextEditingController controller,
    String hint = '',
    Function(String?)? validator,
    String validateString = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 10),
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
            keyboardType: TextInputType.number,
            controller: controller,
            style: const TextStyle(fontSize: 14),

            onEditingComplete: () => FocusScope.of(context).unfocus(),
            decoration: CusInpuDecoration.base(
              context,
              hintText: hint,
            ),
            validator: (String? value) => validator!(value),
          ),
        ),
        if (validateString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 3),
            child: Text(
              validateString,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.red,
              ),
            ),
          )
      ],
    );
  }
}
