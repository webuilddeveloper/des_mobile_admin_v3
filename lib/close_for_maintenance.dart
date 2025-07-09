import 'package:flutter/material.dart';

class CloseForMaintenance extends StatefulWidget {
  const CloseForMaintenance({super.key, this.model});

  final dynamic model;

  @override
  State<CloseForMaintenance> createState() => _CloseForMaintenanceState();
}

class _CloseForMaintenanceState extends State<CloseForMaintenance> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF4FF),
        body: Center(
          child: SizedBox(
            height: 380,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/icon_tools.png',
                  height: 170,
                  width: 170,
                ),
                Text(
                  'ปิดปรับปรุงระบบชั่วคราว',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'ระบบนี้อยู่ในระหว่างการปรับปรุงชั่วคราว \nยังไม่สามารถเข้าใช้งานได้ เตรียมพบกันเร็วๆ นี้!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
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
                        'กลับสู่หน้าหลัก',
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
