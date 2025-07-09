import 'dart:async';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // late Future<dynamic> _futureProfile;
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProfile;

  TextEditingController txtSearch = TextEditingController();
  late List<dynamic> _centerList;
  late bool _loading;

  @override
  void initState() {
    _centerList = [];
    _loading = true;
    _getCenter();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getCenter() async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      var responseCenter = await Dio().get(
          '$ondeURL/api/OfficeDigital/GetCenterByID/${profileMe['centerId']}');

      // _provinceCenterName =
      //     (responseCenter.data?['data']?['changwatT'] ?? '') != ''
      //         ? 'จ.${responseCenter.data?['data']?['changwatT']}'
      //         : '';
      var response = await Dio().get(
        '$ondeURL/api/masterdata/centers/province/${responseCenter.data['data']['chId']}',
      );
      if (response.statusCode == 200) {
        setState(() {
          _centerList = response.data;
        });
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      logE('province center');
    }
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFfdf9ff),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Color(0xFFfdf9ff)),
          ),

          leading: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // backgroundColor: Color(0xFF9A1120),
          centerTitle: true,
          title: const Text(
            'เบอร์โทรติดต่อ',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ศูนย์ดิจิทัลชุมชน',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_centerList.isEmpty && !_loading)
              const Center(
                child: Text('ไม่พบข้อมูล'),
              ),
            ..._centerList.map((e) => _centerListItem(e)).toList(),
            const SizedBox(height: 20),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: Text(
            //     'เบอร์ติดต่อเร่งด่วน',
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontFamily: 'Kanit',
            //         color: Colors.black,
            //         fontWeight: FontWeight.w600),
            //   ),
            // ),
            const SizedBox(height: 10),
            // _exigentContactList(_futureExigentContactModel[i]),
          ],
        ),
      ),
    );
  }

  Widget _centerListItem(dynamic model) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model?['label'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    model?['centerTel'] ?? 'ไม่พบเบอร์โทรศัพท์',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            // Expanded(
            // flex: 1,
            // child:
            // if ((model?['phone'] ?? '') != '')
            InkWell(
              onTap: () {
                if (model?['centerTel'] != null) {
                  launchUrl(Uri.parse('tel:${model?['centerTel'] ?? ''}'));
                }
              },
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    color: Color(0xFF7209B7),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Image.asset(
                  "assets/images/phone.png",
                  color: Colors.white,
                  fit: BoxFit.contain,
                  // width: 26,
                  // height: 26,
                ),
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _exigentContactList(dynamic model) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    model['centerTel'],
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child:
            InkWell(
              onTap: () {
                launchUrl(Uri.parse('tel:${model['centerTel']}'));
              },
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    color: Color(0xFF7209B7),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Image.asset(
                  "assets/images/phone.png",
                  color: Colors.white,
                  fit: BoxFit.contain,
                  // width: 26,
                  // height: 26,
                ),
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}
