import 'package:des_mobile_admin_v3/menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widget/cache_image.dart';

class SuccessFacePage extends StatelessWidget {
  const SuccessFacePage({super.key, this.model});
  final dynamic model;

  @override
  Widget build(BuildContext context) {
    String nowStr = DateFormat('dd MMM yyyy').format(DateTime.now());
    return Scaffold(
      body: Center(
        child: Container(
          height: 490,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              Text(
                'ยินดีต้อนรับ!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 23),
              ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: CachedImageWidget(
                  imageUrl: model['imageUrl'],
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${model['firstName']} ${model['lastName']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                'คอมพิวเตอร์ A1',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                height: 1,
                color: const Color(0x1A7209B7),
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/calendar.png',
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      nowStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/time.png',
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${model['timeStart']}  -  ${model['timeEnd']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Expanded(
                child: SizedBox(),
              ),
              GestureDetector(
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
                    'เสร็จสิ้น',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
