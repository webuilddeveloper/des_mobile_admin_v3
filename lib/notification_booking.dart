import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'config.dart';
import 'notification_form.dart';

class NotificationBookingPage extends StatefulWidget {
  const NotificationBookingPage({
    Key? key,
  }) : super(key: key);
  @override
  State<NotificationBookingPage> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationBookingPage> {
  late bool _loadingWidget;
  late List<dynamic> _listFirstPage;
  late List<dynamic> _listSecondPage;
  late String _selectedType;
  late ScrollController _scrollController;
  late RefreshController _refreshController;
  late int _limit;

  @override
  void initState() {
    _limit = 10;
    _listFirstPage = [];
    _listSecondPage = [];
    _loadingWidget = true;
    _selectedType = '0';
    _scrollController = ScrollController();
    _refreshController = RefreshController();
    _readBooking();
    super.initState();
  }

  @override
  dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  _read() async {
    var profile = await ManageStorage.readDynamic('profileMe');
    logWTF(profile['centerId']);
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/v2/notification/read',
        data: {
          'centerId': profile['centerId'].toString(),
        },
      );

      logWTF(response);
      var data = response.data['objectData'];

      List<dynamic> list = [];

      var listDa = data.map<dynamic>((e) {
        DateTime date = dateStringToDateBirthDay(e['createDate']);
        DateTime now = DateTime.now();

        int dif = now.difference(date).inDays;

        String type =
            (e?['bookingSlotType'] != '' && e?['bookingSlotType'] != null)
                ? 'ทำการ' + e['bookingSlotType']
                : 'ทำการเลื่อนการจอง';

        var categoryDays = dif == 0
            ? "1"
            : dif == 1
                ? "2"
                : dif <= 7 && dif > 0
                    ? "3"
                    : dif > 7
                        ? "4"
                        : "";
        return {
          "isSelected": false,
          "code": e['code'],
          "email": e['email'],
          "category": "bookingPage",
          "title": "เวลา ${e['startTime']} ถึง ${e['endTime']}",
          "totalDays": dif,
          "categoryDays": categoryDays,
          "status": e?['status'] ?? '',
          "docTime": e?['docTime'] ?? '',
          "createDate": e?['createDate'] ?? '',
          "createBy": e?['createBy'] ?? '',
        };
      }).toList();
      setState(() {
        _listFirstPage = list;
        _loadingWidget = false;
      });
    } on DioError catch (e) {
      setState(() => _loadingWidget = false);
      var err = e.toString();
      if (e.response!.statusCode != 200) {
        err = e.response!.data['message'];
      }
      // Fluttertoast.showToast(msg: err);
    } catch (e) {
      setState(() => _loadingWidget = false);
      logE(e);
    }
  }

  _readBooking() async {
    var profile = await ManageStorage.readDynamic('profileMe');
    logWTF(profile['centerId']);
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/v2/notificationbooking/read',
        data: {
          'centerId': profile['centerId'].toString(),
          'skip': 0,
          'limit': _limit,
        },
      );

      logWTF(response);
      var data = response.data['objectData'];

      List<dynamic> list = [];

      list = data.map<dynamic>((e) {
        DateTime date = dateStringToDateBirthDay(e['createDate']);
        DateTime now = DateTime.now();

        int dif = now.difference(date).inDays;

        String type =
            (e?['bookingSlotType'] != '' && e?['bookingSlotType'] != null)
                ? 'ทำการ' + e['bookingSlotType']
                : 'ทำการเลื่อนการจอง';

        var categoryDays = dif == 0
            ? "1"
            : dif == 1
                ? "2"
                : dif <= 7 && dif > 0
                    ? "3"
                    : dif > 7
                        ? "4"
                        : "";
        return {
          "isSelected": false,
          "code": e['code'],
          "email": e['email'],
          "category": "bookingPage",
          "title":
              "มีผู้ใช้งาน ${e['email']} จองใช้บริการศูนย์ฯวัน ${dateStringToDateStringFormat(e['createDate'])} เวลา ${e['startTime']} ถึง ${e['endTime']}",
          "totalDays": dif,
          "categoryDays": categoryDays,
          "status": e?['status'] ?? '',
          "docTime": e?['docTime'] ?? '',
          "createDate": e?['createDate'] ?? '',
          "createBy": e?['createBy'] ?? '',
        };
      }).toList();
      setState(() {
        _listFirstPage = list;
        _loadingWidget = false;
        // chkListCount = _listFirstPage.length > 0 ? true : false;
        // chkListActive =
        //     _listFirstPage.where((x) => x['status'] != "A").toList().length > 0
        //         ? true
        //         : false;
        // totalSelected = 0;
      });
    } on DioError catch (e) {
      setState(() => _loadingWidget = false);
      var err = e.toString();
      if (e.response!.statusCode != 200) {
        err = e.response!.data['message'];
      }
      // Fluttertoast.showToast(msg: err);
    } catch (e) {
      setState(() => _loadingWidget = false);
      logE(e);
    }
  }

  _update(param) async {
    var profile = await ManageStorage.readDynamic('profileMe');
    logWTF(profile['centerId']);
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/v2/notificationbooking/update',
        data: {
          'code': param,
        },
      );
    } on DioError catch (e) {
      setState(() => _loadingWidget = false);
      var err = e.toString();
      if (e.response!.statusCode != 200) {
        err = e.response!.data['message'];
      }
      // Fluttertoast.showToast(msg: err);
    } catch (e) {
      setState(() => _loadingWidget = false);
      logE(e);
    }
  }

  void _onLoading() async {
    _limit += 10;
    await _readBooking();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9FF),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildHead(),
                const SizedBox(height: 20),
                _buildButtion(),
                const SizedBox(height: 20),
                if (_loadingWidget) const CircularProgressIndicator(),
                _buildSelectedType(_selectedType),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHead() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 30,
              width: 30,
              color: const Color(0xFFFCF9FF),
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/arrow_back.png',
                height: 16,
                width: 8,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'การแจ้งเตือน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildButtion() {
    return Center(
      child: Container(
        height: 32,
        width: 267,
        decoration: BoxDecoration(
          color: const Color(0xFF7209B7),
          borderRadius: BorderRadius.circular(17.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40F3D2FF),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = '0';
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17.5),
                    color: _selectedType == '0'
                        ? const Color(0xFFFFFFFF)
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'ทั้งหมด',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _selectedType == '1'
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF7209B7),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = '1';
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedType == '1'
                        ? const Color(0xFFFFFFFF)
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'ยังไม่อ่าน',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _selectedType == '1'
                          ? const Color(0xFF7209B7)
                          : const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedType(String type) {
    if (type == '1') {
      if (_listSecondPage.isEmpty) {
        return Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 200),
          child: const Text('ไม่มีข้อความที่ยังไม่อ่าน'),
        );
      }
      return Expanded(
        child: SmartRefresher(
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
          child: FadingEdgeScrollView.fromScrollView(
            child: ListView.separated(
              shrinkWrap: true,
              controller: _scrollController,
              physics: const ClampingScrollPhysics(), // 2nd
              padding: EdgeInsets.zero,
              itemCount: _listFirstPage.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildCard(_listFirstPage[index]);
              },
            ),
          ),
        ),
      );
    }

    if (_listFirstPage.isEmpty) {
      return Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 200),
        child: const Text('ไม่มีการแจ้งเตือน'),
      );
    }
    return Expanded(
      child: SmartRefresher(
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
        child: FadingEdgeScrollView.fromScrollView(
          child: ListView.separated(
            shrinkWrap: true,
            controller: _scrollController,
            physics: const ClampingScrollPhysics(), // 2nd
            padding: EdgeInsets.zero,
            itemCount: _listFirstPage.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildCard(_listFirstPage[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(dynamic param) {
    return GestureDetector(
      onTap: () async {
        _update(param['code']);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationFormPage(
              title: 'แจ้งเตือนระบบ',
              title2: param['title'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40F3D2FF),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 7),
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: param['status'] == 'N'
                    ? const Color(0xFF7209B7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'แจ้งเตือนระบบ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    param['title'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
