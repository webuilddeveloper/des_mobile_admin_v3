import 'dart:async';
import 'dart:convert';
import 'package:des_mobile_admin_v3/center_search.dart';
import 'package:des_mobile_admin_v3/news.dart';
import 'package:des_mobile_admin_v3/news_detail.dart';
import 'package:des_mobile_admin_v3/register_menu.dart';
import 'package:des_mobile_admin_v3/report.dart';
import 'package:des_mobile_admin_v3/reservation_calendar.dart';
import 'package:des_mobile_admin_v3/shared/mock_data.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'close_for_maintenance.dart';
import 'config.dart';
import 'login.dart';
import 'notification_booking.dart';
import 'reservation_today.dart';
import 'center_search_result.dart';
import 'contact.dart';
import 'shared/extension.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key, this.changePage});
  _HomePageState? homePageState;
  Function? changePage;

  @override
  State<HomePage> createState() => _HomePageState();

  getState() => homePageState;
}

class _HomePageState extends State<HomePage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  late TextEditingController _searchController;

  // late Future<dynamic> _futureProfile;
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
  Future<dynamic>? _futureProfile;
  Future<dynamic>? _futureNews;
  List<dynamic> listDesktop = [];
  bool isShowDesktop = false;
  String desktopName = "";
  late String _timeReservation;

  LatLng? latLng;
  String? currentLocation = 'ตำแหน่งปัจจุบัน';
  int _notiCountTotal = 0;
  int _bookingToday = 0;
  dynamic DashBoardBooking = {}; // Initialize as a map
  dynamic _usedToday = 0;

  String _provinceCenterName = '';
  String _imageProfile = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_home.png', fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: onRefresh,
                onLoading: _onLoading,
                child: ListView(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  children: [
                    _buildLocation(),
                    const SizedBox(height: 18),
                    //user
                    _buildUser(),
                    const SizedBox(height: 18),
                    // ประวัติคนเข้าใช้งาน
                    _buildReservationHistory(),
                    const SizedBox(height: 18),
                    //search
                    _buildSearch(),
                    const SizedBox(height: 18),
                    //บริการ
                    ..._buildService(),
                    const SizedBox(height: 10),
                    // banner
                    _buildBanner(),
                    const SizedBox(height: 15),
                    //สถานะการใช้เครื่อง
                    _buildUseStatus(),
                    const SizedBox(height: 25),
                    // ข่าวประชาสัมพันธ์
                    ..._buildNews(),
                    const SizedBox(height: 5),
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 0),
                    //   child: CachedImageWidget(
                    //     imageUrl:
                    //         'https://raot.we-builds.com/raot-document/images/event/event_235104674.png',
                    //     height: 145,
                    //     width: double.infinity,
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CenterSearchPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(11)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF1EAFF),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            height: 145,
                            // width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              image: DecorationImage(
                                alignment: Alignment.bottomRight,
                                fit: BoxFit.contain,
                                image: AssetImage(
                                  'assets/images/center_me.jpg',
                                ),
                              ),
                            ),
                            child: OverflowBox(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 17,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: const Alignment(0.5, 0),
                                    colors: [
                                      const Color(0xffF1EAFF),
                                      const Color(0xffEAF0FF),
                                      const Color(0xffEAF2FF),
                                      const Color(0xffBDF2FA).withOpacity(0),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "ศูนย์ใกล้ฉัน",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "ค้นหาศูนย์ดิจิทัลชุมชนใกล้ฉัน\nDigital Communication Center",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          // alignment: Alignment.bottomRight,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 4,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            "คลิก",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF7209B7),
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
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(11)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF1EAFF),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            height: 145,
                            // width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              image: DecorationImage(
                                alignment: Alignment.bottomRight,
                                fit: BoxFit.contain,
                                image: AssetImage(
                                  'assets/images/contact_menu.jpg',
                                ),
                              ),
                            ),
                            child: OverflowBox(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 17,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: const Alignment(0.8, 0),
                                    colors: [
                                      const Color(0xffF1EAFF),
                                      const Color(0xffEAF0FF),
                                      const Color(0xffEAF2FF),
                                      const Color(0xffBDF2FA).withOpacity(0),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "เบอร์โทรติดต่อ",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "เบอร์โทรติดต่อสำคัญ ศูนย์ดิจิทัลชุมชน\nโรงพยาบาล Helpdesk",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          // alignment: Alignment.bottomRight,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 4,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            "คลิก",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF7209B7),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          _determinePosition();
          // ปิดก่อน ios เด้ง
          // if (latLng != null)
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => PoiPage(latLng: latLng!),
          //     ),
          //   );
        },
        child: Row(
          children: [
            Image.asset(
              'assets/images/vector.png',
              // height: 20,
              // width: 20,
            ),
            const SizedBox(width: 10),
            Text(
              currentLocation ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUser() {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<dynamic>(
        future: _futureProfile,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.memory(
                      base64Decode(_imageProfile),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/logo.png'),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${snapshot.data?['firstnameTh'] ?? ''} ${snapshot.data?['lastnameTh'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${snapshot.data?['roleName'] ?? ''}\n$_provinceCenterName ${snapshot.data?['centerName'] ?? ''}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const CloseForMaintenance(),
                    //   ),
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationBookingPage(),
                      ),
                    ).then((value) => _notiCount());
                  },
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/bell.png',
                        width: 20,
                        height: 28,
                      ),
                      if (_notiCountTotal > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 9,
                            width: 9,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildReservationHistory() {
    return SizedBox(
      height: (MediaQuery.of(context).size.width + 60) * 0.30,
      child: Row(
        children: [
          const SizedBox(width: 20),
          _buildItemReservationHistory(
            index: 0,
            count: DashBoardBooking['countBookingToday']?.toString() ?? '0',
          ),
          const SizedBox(width: 10),
          _buildItemReservationHistory(index: 1, count: _usedToday.toString()),
          const SizedBox(width: 10),
          _buildItemReservationHistory(
            index: 2,
            count: DashBoardBooking['countTicketToday']?.toString() ?? '0',
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildItemReservationHistory({int? index, String count = ''}) {
    var bgList = [
      'assets/images/bg_reservation_blue.png',
      'assets/images/bg_reservation_purple.png',
      'assets/images/bg_reservation_yellow.png',
    ];
    var iconList = [
      'assets/images/mobile_check.png',
      'assets/images/user.png',
      'assets/images/user.png',
    ];
    var titleList = [
      'การจองวันนี้',
      'ผู้ใช้งานทั่วประเทศวันนี้',
      'รายงานปัญหาศูนย์ ',
    ];

    // Check if index is valid

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const CloseForMaintenance(),
          //   ),
          // );
          // if (index == 0) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const ReservationTodayPage(
          //         title: 'การจองใช้งานวันนี้',
          //       ),
          //     ),
          //   );
          // } else if (index == 1) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const ReservationPage(
          //         title: 'จองใช้งาน',
          //       ),
          //     ),
          //   );
          // } else {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const ReportPage(),
          //     ),
          //   );
          // }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  bgList[index!],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 9,
              bottom: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.asset(iconList[index], height: 22, width: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleList[index],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: count,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: index != 2 ? ' คน' : ' เรื่อง',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x40F3D2FF),
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CenterSearchResultPage(
                            keySearch: _searchController.text,
                          ),
                    ),
                  ).then((_) {
                    setState(() {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();

                      // Clear the text field after search
                    });
                  });
                },
                decoration: CusInpuDecoration.base(
                  context,
                  hintText: 'ชื่อศูนย์ หมายเลขศูนย์ หรือเบอร์ติดต่อ',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CenterSearchResultPage(
                        keySearch: _searchController.text,
                      ),
                ),
              ).then((_) {
                setState(() {
                  _searchController
                      .clear(); // Clear the text field after search
                });
              });
            },
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8.75),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Image.asset('assets/images/search.png'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildService() {
    return <Widget>[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildItemService(
                image: 'assets/images/menu_report_icon.png',
                title: 'รายการปัญหา',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),
            Expanded(
              child: _buildItemService(
                image: 'assets/images/menu_reservation_icon.png',
                title: 'จองใช้งาน',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReservationCalendarPage(),
                    ),
                  );
                },
              ),
            ),

            // Expanded(
            //   child: _buildItemService(
            //     image: 'assets/images/menu_register_icon.png',
            //     title: 'ทะเบียนสมาชิก',
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => RegisterMenuPage(),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      // Container(
      //   height: 85,
      //   padding: const EdgeInsets.symmetric(horizontal: 16),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         child: _buildItemService(
      //           image: 'assets/images/menu_chat_icon.png',
      //           title: 'ข้อความ',
      //           onTap: () {
      //             widget.changePage!(3);
      //           },
      //         ),
      //       ),
      //       const SizedBox(width: 10),
      //       Expanded(
      //         child: _buildItemService(
      //           image: 'assets/images/menu_report_icon.png',
      //           title: 'แจ้งปัญหา',
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => const ReportPage(),
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    ];
  }

  Widget _buildItemService({
    required String image,
    required String title,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (title == 'ทะเบียนสมาชิก') {
          onTap();
        } else if (title == 'จองใช้งาน') {
          onTap();
        } else if (title == 'รายการปัญหา') {
          onTap();
        } else if (title == 'ข้อความ') {
          onTap();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CloseForMaintenance(),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Container(
            height: (MediaQuery.of(context).size.width + 50) * 0.19,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40F3D2FF),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Image.asset(image, height: 30, width: 30),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder:
            (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedImageWidget(
                imageUrl: mockBannerList[__],
                width: 220,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: mockBannerList.length,
      ),
    );
  }

  Widget _buildUseStatus() {
    return Container(
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x40F3D2FF),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'สถานะการใช้เครื่อง',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 26.36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/calendar.png',
                width: 19.2,
                height: 18.86,
              ),
              const SizedBox(width: 8.4),
              Text(
                dateThai(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 22),
              Container(height: 29, width: 1, color: const Color(0xFFDDDDDD)),
              const SizedBox(width: 22),
              Image.asset('assets/images/time.png', width: 19.2, height: 18.86),
              const SizedBox(width: 8.4),
              Text(
                _timeReservation,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            color: const Color(0xFFDDDDDD),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ว่าง',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF03BA0A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'กำลังใช้งาน',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2539ED),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'จองแล้ว',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            constraints: const BoxConstraints(maxWidth: 295),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Wrap(
              spacing: 6,
              runSpacing: 7,
              children: [
                for (var item in listDesktop)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isShowDesktop == true) {
                          if (desktopName == item['hostname']) {
                            isShowDesktop = false;
                          } else {
                            desktopName = item['hostname'];
                          }
                        } else {
                          isShowDesktop = true;
                          desktopName = item['hostname'];
                        }
                      });
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.only(
                        right: item['margin'] == true ? 15 : 0,
                      ),
                      padding: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            item['host_status'] == "Up"
                                ? const Color(0xFF03BA0A)
                                : item['host_status'] == "Down"
                                ? const Color(0xFFDDDDDD)
                                : const Color(0xFF2539ED),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item['hostname'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color:
                              item['host_status'] == ""
                                  ? const Color(0x80000000)
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          if (isShowDesktop)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Text(
                desktopName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const CloseForMaintenance(),
              //   ),
              // );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const ReservationTodayPage(title: 'ติดตามการจอง'),
                ),
              );
            },
            child: Container(
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              child: Text(
                'ข้อมูลการจอง',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNews() {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'ข่าวประชาสัมพันธ์',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsPage()),
                  ),
              child: const Text(
                'ดูทั้งหมด',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 178,
        child: FutureBuilder<dynamic>(
          future: _futureNews,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (_, __) => _buildItemNews(snapshot.data[__]),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: snapshot.data.length,
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    ];
  }

  Widget _buildItemNews(dynamic model) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailPage(model: model)),
        );
      },
      child: Container(
        height: 158,
        width: 180,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: CachedImageWidget(
                imageUrl: model['imageUrl'],
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: Center(
                  child: Image.asset('assets/images/logo.png', height: 110),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  model['title'],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _searchController = TextEditingController(text: '');
    _timeReservation = '${DateTime.now().hour}:${DateTime.now().minute} น.';
    _getProfileMe();
    _callRead();
    _notiCount();
    _readDesktop();
    _getCenter();
    _callReadUser();
    _getImageProfile();
    _GetDashBoardBooking();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _determinePosition();
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _notiCount() async {
    // var profile = await ManageStorage.readDynamic('profileMe');
    var accessToken = await ManageStorage.read('accessToken_122') ?? '';
    try {
      // Response response = await Dio().post(
      //   '$serverUrl/dcc-api/m/v2/notificationbooking/count',
      //   data: {'centerId': profile['centerId'].toString()},
      // );

      final response = await Dio().get(
        '$ondeURL/api/Notify/count/me?isPortal=false',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _notiCountTotal = response.data['data']['notRead'];
        });
      } else {
        logE('Error: ${response.statusCode} - ${response.data}');
      }
    } on DioError catch (e) {
      logE(e.toString());
    } catch (e) {
      logE(e);
    }
  }

  _readBookingToday() async {
    var profile = await ManageStorage.readDynamic('profileMe');
    try {
      if (profile['centerId'] != '') {
        Response response = await Dio().post(
          '$serverUrl/dcc-api/m/v2/notificationbooking/today/count',
          data: {'centerId': profile['centerId'].toString()},
        );
        setState(() {
          _bookingToday = response.data['objectData']['total'];
        });
      }
      // logWTF(_bookingToday);
    } on DioError catch (e) {
      logE(e);
    } catch (e) {
      logE(e);
    }
  }

  _GetDashBoardBooking() async {
    String token = await ManageStorage.read('accessToken_122') ?? '';

    try {
      Response response = await Dio().get(
        '$ondeURL/api/Booking/GetDashBoardBooking',
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          DashBoardBooking = response.data['data'];
        });
        // logWTF(response.data); // ดูข้อมูลที่ได้จาก API
      } else {
        logE('Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      logE('Exception: $e');
    }
  }

  _readUsedCount() async {
    try {
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/log/used/count',
        data: {},
      );
      setState(() {
        _usedToday = response.data?['objectData']?['total'] ?? 0;
      });
    } on DioError catch (e) {
      logE(e.toString());
    } catch (e) {
      logE(e);
    }
  }

  _callRead() async {
    _readNews();
    _readBookingToday();
    _readUsedCount();
  }

  _readNews() async {
    Dio dio = Dio();
    var response = await dio.post(
      '$serverUrl/dcc-api/m/eventcalendar/read',
      data: {'limit': 10},
    );
    setState(() {
      _futureNews = Future.value(response.data['objectData']);
    });
  }

  _readDesktop() async {
    profile = await ManageStorage.readDynamic('staffProfileData') ?? '';
    var result = await Dio().post(
      'https://desktopmgmt.dcc.onde.go.th/api/login/standard',
      data: {"Username": "admin_desk", "Password": "P@ssw0rd1234!"},
      options: Options(
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    dynamic param = jsonEncode({
      "length": 40,
      "DataSourceName": "desktop host",
      "Filter": [
        {
          "PropertyName": "Level3",
          "AreEqualText": "is",
          "Value": ["${profile['centerName']}"],
        },
      ],
    });
    String basicAuth = result.headers['authorizationtoken']
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');

    String basicCookie = result.headers['set-cookie']
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');
    var parts = basicCookie.split(';');
    var cookie = parts[0].trim();
    var url = Uri.parse(
      'https://desktopmgmt.dcc.onde.go.th/api/DashboardDefault/defaulttable',
    );
    var response = await http.post(
      url,
      body: param,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
        'Cookie': cookie,
      },
    );
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = json.decode(response.body);
    String minute = DateTime.now().minute.toString();
    if (DateTime.now().minute < 10) {
      minute = '0$minute';
    }
    setState(() {
      _timeReservation = '${DateTime.now().hour}:$minute น.';
      listDesktop = data['data'];
    });
  }

  // _callReadUser() async {
  //   var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
  //   var staffProfileData =
  //       await ManageStorage.readDynamic('staffProfileData') ?? '';

  //   // data from DCC
  //   profileMe['roleName'] = staffProfileData?['roleName'] ?? '';
  //   profileMe['centerName'] = staffProfileData?['centerName'] ?? '';
  //   if (profileMe == '') {
  //     if (!mounted) return;
  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(builder: (context) => const LoginPage()),
  //       (Route<dynamic> route) => false,
  //     );
  //   }
  //   setState(() async {
  //     _futureProfile = Future.value(profileMe);
  //   });
  // }
  _callReadUser() async {
    try {
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      var staffProfileData =
          await ManageStorage.readDynamic('staffProfileData') ?? '';

      // data from DCC
      if (profileMe != '') {
        profileMe['roleName'] = staffProfileData?['roleName'] ?? '';
        profileMe['centerName'] = staffProfileData?['centerName'] ?? '';
      }

      if (profileMe == '') {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        return; // เพิ่ม return เพื่อไม่ให้ทำงานต่อ
      }

      // แก้ไข: เอา async ออกจาก setState
      if (mounted) {
        setState(() {
          _futureProfile = Future.value(profileMe);
        });
      }
    } catch (e) {
      print('Error in _callReadUser: $e');
      if (mounted) {
        // จัดการ error case
        setState(() {
          _futureProfile = Future.error(e);
        });
      }
    }
  }

  _getImageProfile() async {
    try {
      // logWTF('_getImageProfile');
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      var responseCenter = await Dio().get(
        '$ondeURL/api/user/GetImageProfile/${profileMe['userid']}',
      );

      setState(() {
        _imageProfile = responseCenter.data;
      });
    } catch (e) {
      logE('_getImageProfile');
    }
  }

  _getCenter() async {
    var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
    try {
      // logWTF(profileMe);
      var responseCenter = await Dio().get(
        '$ondeURL/api/OfficeDigital/GetCenterByID/${profileMe['centerId']}',
      );

      // logWTF(profileMe['centerId']);
      _provinceCenterName =
          (responseCenter.data?['data']?['changwatT'] ?? '') != ''
              ? 'จ.${responseCenter.data?['data']?['changwatT']}'
              : '';
    } catch (e) {
      if (profileMe['centerId'] == null) {
        setState(() {
          _provinceCenterName = 'ไม่พบศูนย์กรุณาติดต่อเจ้าหน้าที่';
        });
      }
      logE('province center');
    }
  }

  void onRefresh() async {
    _getProfileMe();
    _getCenter();
    _readBookingToday();
    _notiCount();
    _callRead();
    _readDesktop();
    _determinePosition();
    _callReadUser();
    _getImageProfile();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  dateStringToDateSlashBuddhistShort(String date) {
    if (date.isEmpty) return '';
    var year = date.substring(0, 4);
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    var yearBuddhist = int.parse(year) + 543;
    var yearBuddhistString = yearBuddhist.toString();
    var yearBuddhistStringShort = yearBuddhistString.substring(2, 4);
    return '$day/$month/$yearBuddhistStringShort';
  }

  _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = 'เปิดการเข้าถึงตำแหน่งเพื่อใช้บริการ';
        });
        return Future.error('Location Not Available');
      }
    } else if (permission == LocationPermission.always) {
    } else if (permission == LocationPermission.whileInUse) {
    } else if (permission == LocationPermission.unableToDetermine) {
    } else {
      throw Exception('Error');
    }
    _getLocation();
    // return await Geolocator.getCurrentPosition();
  }

  // _getLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best,
  //     );
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );

  //     setState(() {
  //       latLng = LatLng(
  //         position.latitude as Angle,
  //         position.longitude as Angle,
  //       );
  //       currentLocation =
  //           (placemarks.first.subLocality ?? '') +
  //           ((placemarks.first.subLocality ?? '').isNotEmpty ? ', ' : '') +
  //           (placemarks.first.administrativeArea ?? '');
  //     });
  //   } catch (e) {
  //     logE('_getLocation');
  //     logE(e);
  //   }
  // }

  _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        // แก้ไข: ไม่ต้องทำการ cast เป็น Angle
        latLng = LatLng(position.latitude, position.longitude);
        currentLocation =
            (placemarks.first.subLocality ?? '') +
            ((placemarks.first.subLocality ?? '').isNotEmpty ? ', ' : '') +
            (placemarks.first.administrativeArea ?? '');
      });
    } catch (e) {
      logE('_getLocation');
      logE(e);
    }
  }

  dynamic _getProfileMe() async {
    try {
      String token = await ManageStorage.read('accessToken_122') ?? '';
      if (token.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }

      Response response = await Dio().get(
        '$ondeURL/api/user/ProfileMe',
        options: Options(
          validateStatus: (_) => true,
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
          headers: {
            'Content-type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        await ManageStorage.createSecureStorage(
          value: json.encode(response.data?['data']),
          key: 'profileMe',
        );
      } else if (response.statusCode == 500) {
        logE(response.data);
      } else {
        // return null;
      }
    } on DioError catch (e) {
      String err = e.error.toString();
      if (e.response != null) {
        err = e.response!.data['title'].toString();
      }
      return null;
    }
  }
}
