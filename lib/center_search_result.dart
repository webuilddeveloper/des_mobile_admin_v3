import 'dart:async';
import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/shared/center_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CenterSearchResultPage extends StatefulWidget {
  CenterSearchResultPage({super.key, required this.keySearch});
  String? keySearch;

  @override
  State<CenterSearchResultPage> createState() => _CenterSearchResultPageState();

  // getState() => homeCentralPageState;
}

class _CenterSearchResultPageState extends State<CenterSearchResultPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late TextEditingController _searchController;

  // late Future<dynamic> _futureProfile;
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProfile;

  TextEditingController txtSearch = TextEditingController();

  int selectedMenuIndex = 0;
  String selectProvince = "1";
  String selectDistrict = "1";
  String selectSubDistrict = "1";
  late List<dynamic> _modelFilter;
  bool _loading = false;

  @override
  void initState() {
    _modelFilter = [];
    _filterSearch();
    _searchController = TextEditingController(text: '');

    // _callReadUser();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void onRefresh() async {
    _filterSearch();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  _filterSearch() async {
    try {
      setState(() => _loading = true);
      Response responseCenter = await Dio()
          .get('https://dcc.onde.go.th/dcc-api/api/masterdata/centers');

      logWTF(widget.keySearch);
      logWTF(responseCenter.data);
      List<dynamic> responseData = responseCenter.data;
      var data = responseData;
      if (widget.keySearch!.isNotEmpty) {
        data = responseData
            .where((item) => item['label'].contains(widget.keySearch!))
            .toList();
      }
      setState(() {
        _modelFilter = data;
        widget.keySearch = '';
      });
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    }
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
            'ผลการค้นหาศูนย์ดิจิทัลชุมชน',
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
            Expanded(
              child: _loading
                  ? Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    )
                  : _listItems(),
            )
          ],
        ),
      ),
    );
  }

  Widget _listItems() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      itemCount: _modelFilter.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (_, __) => _buildResultList(__),
    );
  }

  Widget _buildBoxSearch() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('พบข้อมูลการค้นหา " ${_modelFilter.length} " รายการ')
              //   Text(
              // 'พบข้อมูลการค้นหา "${widget.keySearch}" ${_modelFilter.length}" รายการ')
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _modelFilter.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => _buildResultList(_modelFilter[__]),
      ),
    );
  }

  Widget _buildResultList(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if ((_modelFilter[index]?['showMore'] == null)) {
            _modelFilter[index]['showMore'] = true;
          } else {
            _modelFilter[index]['showMore'] = !_modelFilter[index]['showMore'];
          }
        });
        _getMoreData(index);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (contex) => MemberDetailsPage(
        //       model: model,
        //     ),
        //   ),
        // );
      },
      child: Container(
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB325F8).withOpacity(0.10),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _modelFilter[index]?["label"] ?? '',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  (_modelFilter[index]?['showMore'] ?? false)
                      ? RotationTransition(
                          turns: const AlwaysStoppedAnimation(180 / 360),
                          child: Image.asset(
                            'assets/images/arrow_down.png',
                            width: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Image.asset(
                          'assets/images/arrow_down.png',
                          width: 15,
                          color: Theme.of(context).primaryColor,
                        )
                ],
              ),
              if ((_modelFilter[index]?['showMore'] ?? false)) _listMore(index),
            ],
          ),
        ),
      ),
    );
  }

  _getMoreData(index) async {
    try {
      if (_modelFilter[index]?['centerRefno'] == null) {
        Response response = await Dio().get(
            'https://dcc.onde.go.th/dcc-api/api/OfficeDigital/GetCenterByID/${_modelFilter[index]['value']}');
        logWTF(response.data['data']);
        dynamic data = response.data['data'];
        setState(() {
          _modelFilter[index] = <dynamic, dynamic>{
            ..._modelFilter[index],
            ...data
          };
        });
        logWTF(_modelFilter[index]);
      }
    } catch (e) {
      logE(e);
    }
  }

  String _appareAddress(index) {
    String address = _modelFilter[index]?["centerAdd"] ?? '';
    // String tambon = _modelFilter[index]?["tambonT"] ?? '';
    // String amphoe = _modelFilter[index]?["amphoeT"] ?? '';
    // String changwat = _modelFilter[index]?["changwatT"] ?? '';

    return '$address ';
  }

  Widget _listMore(index) {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            if (_modelFilter[index]?['centerRefno'] == null)
              const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
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
                    _appareAddress(index),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
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
                    _modelFilter[index]?["centerTel"] ?? "-",
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
                if (_modelFilter[index]?['centerTel'] != null)
                  GestureDetector(
                    onTap: () {
                      launchUrl(
                          Uri.parse('tel:${_modelFilter[index]['centerTel']}'));
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
                if (_modelFilter[index]?['latitude'] != null &&
                    _modelFilter[index]?['longitude'] != null)
                  GestureDetector(
                    onTap: () {
                      String googleMapsLocationUrl =
                          'https://www.google.com/maps/search/?api=1&query=${_modelFilter[index]['latitude']},${_modelFilter[index]['longitude']}';

                      final String encodedURl =
                          Uri.encodeFull(googleMapsLocationUrl);

                      launchUrl(Uri.parse(encodedURl),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
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
          border: Border.all(color: const Color(0xFF7209B7))),
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
        padding: const EdgeInsets.symmetric(horizontal: 19),
        width: double.infinity,
        // height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        child: SizedBox(
          child: TextFormField(
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFCEA8F3)),
            controller: txtController,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: Color(0xFFCEA8F3),
                fontSize: 16,
              ),
              floatingLabelStyle:
                  TextStyle(color: Colors.black.withOpacity(0.24)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
