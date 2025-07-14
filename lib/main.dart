import 'package:des_mobile_admin_v3/profile_verify_thai_id.dart';
import 'package:des_mobile_admin_v3/report.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/verify_thai_id.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash.dart';
import 'dart:io';
import 'package:app_links/app_links.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  Intl.defaultLocale = 'th';
  initializeDateFormatting();

  LineSDK.instance.setup('2000149922').then((_) {
  });

  // runApp(DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) => MyApp(), // Wrap your app
  // ));
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final AppLinks _appLinks = AppLinks();
  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      try {
        _appLinks.uriLinkStream.listen(
          (Uri? uri) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? state = prefs.getString('thaiDState') ?? '';
            String? action = prefs.getString('thaiDAction') ?? '';

            if (uri != null && state == uri.queryParameters['state']) {
              await prefs.setString(
                'thaiDCode',
                uri.queryParameters['code'].toString(),
              );
              if (action == 'create') {
                navigatorKey.currentState!.pushReplacementNamed(
                  '/verifyThaiId',
                );
              } else if (action == 'update') {
                navigatorKey.currentState!.pushReplacementNamed(
                  '/profileVerify',
                );
              }
            }
          },
          onError: (err) {
            logD('got err: $err');
          },
        );
      } catch (e) {
        logE(e);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DCC Admin',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        '/report': (BuildContext context) => const ReportPage(),
        '/verifyThaiId': (BuildContext context) => const VerifyThaiIDPage(),
        '/profileVerify':
            (BuildContext context) => const ProfileVerifyThaiIDPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF7209B7),
        unselectedWidgetColor: const Color(0xFF7209B7),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF7209B7),
          circularTrackColor: Color(0xFFE0AAFF),
        ),
        fontFamily: 'Kanit',
        useMaterial3: true,
      ),
      home: const SplashPage(),
      builder: (context, child) {
        // แก้ไขจาก child เป็น body
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!, // เพิ่ม '!' เพื่อจัดการกับ null safety
        );
      },
    );
  }
}
