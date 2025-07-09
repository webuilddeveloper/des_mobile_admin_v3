// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:des_mobile_admin_v3/check_version.dart';
import 'package:des_mobile_admin_v3/config.dart';
import 'package:des_mobile_admin_v3/login.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'menu.dart';

// ignore: must_be_immutable
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.code});
  final String? code;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  late int version_store;
  dynamic _model_version;
  String os = Platform.operatingSystem;
  String _urlImage = '';
  int _timeOut = 1000;
  Future<dynamic>? futureModel;

  @override
  void initState() {
    version_store = versionNumber;
    _getImage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getImage() async {
    try {
      Response result = await Dio().post(
        '$serverUrl/dcc-api/m/splash/read',
        data: {},
      );
      // logE('load splash screen');

      if (result.data['objectData'].length > 0) {
        setState(() {
          _urlImage = result.data['objectData'][0]['imageUrl'];
          _timeOut = int.parse(result.data['objectData'][0]['timeOut'] ?? 0);
        });
      }
      // logWTF(_urlImage);
      int time = (_timeOut / 1000).round();
      Timer(Duration(seconds: time), _checkVersion);
    } catch (e) {
      logE('catch splash screen');
      _checkVersion();
    }
  }

  void _checkVersion() async {
    try {
      String osDevice = os == 'ios' ? 'Ios' : 'Android';
      // print('os : ${os_device}');
      Dio dio = Dio();
      var res = await dio.post(
        '$serverUrl/dcc-api/version/read',
        data: {"platform": osDevice},
      );
      setState(() {
        version_store = int.parse(
          res.data['objectData'][0]['version'].split('.').join(''),
        );
        _model_version = res.data['objectData'][0];
      });
      navigationPage();
    } catch (e) {
      logE(e);
      navigationPage();
    }
  }

  Future<void> navigationPage() async {
    if (!mounted) return;
    if (version_store > versionNumber) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckVersionPage(model: _model_version),
        ),
      );
    } else {
      String accessToken = await ManageStorage.read('accessToken_122');
      if (!mounted) return;
      if (accessToken.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Menupage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  // ignore: unused_element
  _check() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Menupage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Container(
        alignment: Alignment.bottomCenter,
        child: CachedImageWidget(
          imageUrl: _urlImage,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
          errorWidget: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/logo.png', height: 100),
            ),
          ),
        ),
      ),
    );
  }
}
