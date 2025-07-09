import 'dart:async';

import 'package:des_mobile_admin_v3/center_search_result.dart';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CenterSearchPage extends StatefulWidget {
  const CenterSearchPage({super.key});

  @override
  State<CenterSearchPage> createState() => _CenterSearchPageState();

  // getState() => homeCentralPageState;
}

class _CenterSearchPageState extends State<CenterSearchPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late TextEditingController _searchController;

  TextEditingController txtSearch = TextEditingController();
  late List<dynamic> _model;
  late bool _loading;

  @override
  void initState() {
    _searchController = TextEditingController(text: '');
    _loading = true;
    _model = [];
    _determinePosition();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onRefresh() async {
    // _callReadUser();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    } else if (permission == LocationPermission.always) {
    } else if (permission == LocationPermission.whileInUse) {
    } else if (permission == LocationPermission.unableToDetermine) {
    } else {
      setState(() => _loading = false);
      throw Exception('Error');
    }
    _getLocation();
  }

  _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _getCenterNearMe(LatLng(position.latitude as Angle, position.longitude as Angle));
    } catch (e) {
      setState(() => _loading = false);
      logE('_getLocation');
      logE(e);
    }
  }

  _getCenterNearMe(LatLng latlng) async {
    try {
      String path =
          'https://dcc.onde.go.th/dcc-api/api/DataManagement/GetCenterLocation';

      Response response = await Dio().get(
          '$path?latitude=${latlng.latitude}&longitude=${latlng.longitude}');
      setState(() {
        _model = response.data['data'];
      });
      setState(() => _loading = false);
      logWTF(_model);
    } catch (e) {
      setState(() => _loading = false);
      logE(e);
    }
  }

  void goBack() async {
    Navigator.pop(context, false);
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
                onTap: () => {goBack()},
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
            'ค้นหาศูนย์ดิจิทัลชุมชน',
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            _buildBoxSearch(),
            const SizedBox(
              height: 16,
            ),
            if (_loading) const CircularProgressIndicator(),
            if (_model.isEmpty && !_loading)
              const Center(
                child: Text('ไม่พบข้อมูล'),
              ),
            Expanded(
              child: _buildBoxResult(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBoxSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 25,
                child: labelTextFormField('ค้นหาชื่อผู้ใช้งาน', txtSearch),
                // Container(
                //   width: double.infinity,
                //   // height: 41,
                //   decoration: const BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.all(Radius.circular(7)),
                //   ),
                //   child: Container(
                //     decoration: const BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.all(Radius.circular(7)),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Color.fromARGB(255, 249, 233, 255),
                //           blurRadius: 3,
                //           offset: Offset(0, 5),
                //         )
                //       ],
                //     ),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 19, vertical: 12),
                //       width: double.infinity,
                //       // height: 60,
                //       decoration: const BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.all(Radius.circular(7)),
                //       ),
                //       child: Text(
                //         'ค้นหาชื่อผู้ใช้งาน',
                //         style: TextStyle(
                //             color: Color(0xFF7209B7).withOpacity(0.38),
                //             fontSize: 14,
                //             fontWeight: FontWeight.w400),
                //       ),
                //     ),
                //   ),
                // ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Flexible(
                flex: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (contex) => CenterSearchResultPage(
                          keySearch: txtSearch.text,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.75),
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xFF7209B7),
                    ),
                    child: Image.asset(
                      "assets/images/search.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 15),
            child: Row(
              children: [
                const Expanded(
                  flex: 11,
                  child: Text(
                    'ศูนย์ดิจิทัลชุมชนใกล้ฉัน',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: InkWell(
                //     onTap: () {
                //       _dialogFilter();
                //     },
                //     child: Container(
                //       height: 20,
                //       alignment: Alignment.bottomRight,
                //       child: Image.asset(
                //         "assets/images/filter.png",
                //         fit: BoxFit.contain,
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxResult() {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: const ClassicFooter(
        loadingText: ' ',
        canLoadingText: ' ',
        idleText: ' ',
        idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
      ),
      controller: _refreshController,
      onLoading: _onLoading,
      child: ListView.separated(
        shrinkWrap: true,
        // physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        itemCount: _model.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (_, __) => _buildResultList(_model[__]),
      ),
    );
  }

  Widget _buildResultList(dynamic model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(11)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF9E9FF),
            blurRadius: 5,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Container(
        padding:
            const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 25),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: const Color(0xFFB325F8).withOpacity(0.10),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model?["center_Name"] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Image.asset(
                    "assets/images/location.png",
                    fit: BoxFit.contain,
                    width: 16,
                    height: 16,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 10,
                  child: Text(
                    model["center_Add"] ?? "-",
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Image.asset(
                    "assets/images/phone.png",
                    fit: BoxFit.contain,
                    width: 16,
                    height: 16,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 10,
                  child: Text(
                    model["phone"] ?? "-",
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Icon(
                    Icons.my_location_sharp,
                    size: 15,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 10,
                  child: Text(
                    '${((model?["distance_M"] ?? 0) / 1000).toStringAsFixed(2)} กม.',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (model?['center_Tel'] != null)
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse('tel:${model?['center_Tel'] ?? ''}'));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.5)),
                          color: Color(0xFF7209B7)),
                      child: const Text(
                        'โทรเลย',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    logWTF('${model['latitude']},${model['longitude']}');
                    String googleMapsLocationUrl =
                        'https://www.google.com/maps/search/?api=1&query=${model['latitude']},${model['longitude']}';

                    String encodedURl = Uri.encodeFull(googleMapsLocationUrl);

                    launchUrl(Uri.parse(encodedURl),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.5)),
                        color: Color(0xFF7209B7)),
                    child: const Text(
                      'ดูแผนที่',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _dialogFilter() {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(11.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'กรองการค้นหาศูนย์ดิจิทัลฯ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF7209B7),
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('เลือกจังหวัด'),
                  const SizedBox(
                    height: 10,
                  ),
                  // DropdownCustom(province, 'จังหวัด', (value) {
                  //   setState(() {
                  //     selectProvince = value;
                  //   });
                  // }, selectProvince),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Text('เลือกเขต/อำเภอ'),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // DropdownCustom(district, 'เขต/อำเภอ', (value) {
                  //   setState(() {
                  //     selectDistrict = value;
                  //   });
                  // }, selectDistrict),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Text('เลือกแขวง/ตำบล'),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // DropdownCustom(subDistrict, 'แขวง/ตำบล', (value) {
                  //   setState(() {
                  //     selectSubDistrict = value;
                  //   });
                  // }, selectSubDistrict),
                  const SizedBox(
                    height: 48,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      // height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7209B7),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const SizedBox(
                        // height: 60,
                        child: Text(
                          'ค้นหา',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget DropdownCustom(List<dynamic> itemModel, String label,
      Function onChanged, String valueDropdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      width: double.infinity,
      // height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Color(0xFF7209B7))),
      child: SizedBox(
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: Icon(
              Icons.expand_more,
              color: const Color(0xFF7209B7).withOpacity(0.5),
              size: 40,
            ),
            items: itemModel.map<DropdownMenuItem<String>>(
              (value) {
                return DropdownMenuItem(
                  value: value['code'],
                  child: Text(
                    value['title'].toString(),
                    style: TextStyle(
                      color: const Color(0xFF7209B7).withOpacity(.50),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Kanit',
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: (value) => onChanged(value),
            hint: Text(
              label,
              style: TextStyle(
                  color: const Color(0xFF7209B7).withOpacity(.50),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            value: valueDropdown,
          ),
        ),
      ),
    );
  }

  Widget labelTextFormField(
    String label,
    TextEditingController txtController,
  ) {
    return Container(
      // height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 249, 233, 255),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        width: double.infinity,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        child: TextField(
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFCEA8F3)),
          controller: txtController,
          decoration: CusInpuDecoration.base(
            context,
            hintText: 'ค้นหาชื่อศูนย์บริการหรือผู้ใช้งาน',
          ),
          // decoration: InputDecoration(
          //   labelText: label,
          //   labelStyle: const TextStyle(
          //     color: Color(0xFFCEA8F3),
          //     // fontSize: 16,
          //   ),
          //   floatingLabelStyle:
          //       TextStyle(color: Colors.black.withOpacity(0.24)),
          //   enabledBorder: const UnderlineInputBorder(
          //     borderSide: BorderSide(color: Colors.white, width: 0),
          //   ),
          //   focusedBorder: const UnderlineInputBorder(
          //     borderSide: BorderSide(color: Colors.white, width: 0),
          //   ),
          // ),
        ),
      ),
    );
  }
}
