import 'package:dio/dio.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationFormPage extends StatefulWidget {
  NotificationFormPage({
    Key? key,
    required this.title,
    required this.title2,
  }) : super(key: key);
  String title;
  String title2;
  @override
  State<NotificationFormPage> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationFormPage> {
  String selectedType = '0';
  String selectedCategoryDays = '';
  String selectedCategoryDaysName = '';
  int totalSelected = 0;
  final _controllerBuildCategory = ScrollController();
  final _controllerCardV2 = ScrollController();
  final _controller = ScrollController();
  Future<dynamic>? _futureModel;
  Future<dynamic>? _futureModelM;

  bool isCheckSelect = false;
  bool isNoActive = false;
  bool chkListCount = false;
  bool chkListActive = false;
  Dio dio = Dio();
  List<dynamic> listData = [];
  List<dynamic> listResultData = [];
  List<dynamic> listMData = [];
  List<dynamic> listMResultData = [];
  List<dynamic> listCategoryDays = [
    {
      'code': '1',
      'title': 'วันนี้',
    },
    {
      'code': '2',
      'title': 'เมื่อวาน',
    },
    {
      'code': '3',
      'title': '7 วันก่อน',
    },
    {
      'code': '4',
      'title': 'เก่ากว่า 7 วัน',
    },
    {
      'code': '5',
      'title': 'ยังไม่อ่าน',
    },
  ];
  List<dynamic> list = [
    {
      "category": "bookingPage",
      "title": "มีผู้ใช้งานรหัส 012345 จองใช้บริการศูนย์ฯวันนี้ ",
      "totalDays": 0,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
    {
      "category": "bookingPage",
      "title": "มีผู้ใช้งานรหัส 012345 จองใช้บริการศูนย์ฯวันนี้ ",
      "totalDays": 0,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
    {
      "category": "bookingPage",
      "title": "มีผู้ใช้งานรหัส 012345 จองใช้บริการศูนย์ฯวันนี้ ",
      "totalDays": 0,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
    {
      "category": "bookingPage",
      "title": "มีผู้ใช้งานรหัส 012345 จองใช้บริการศูนย์ฯวันนี้ ",
      "totalDays": 7,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
    {
      "category": "bookingPage",
      "title": "มีผู้ใช้งานรหัส 012345 จองใช้บริการศูนย์ฯวันนี้ ",
      "totalDays": 7,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
  ];

  List<dynamic> listM = [
    {
      "category": "สมาชิกหมายเลข 0012345",
      "title": "ส่งข้อความถึงคุณ",
      "totalDays": 0,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
    {
      "category": "สมาชิกหมายเลข 0012345",
      "title": "ส่งข้อความถึงคุณ",
      "totalDays": 0,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
    {
      "category": "สมาชิกหมายเลข 0012345",
      "title": "ส่งข้อความถึงคุณ",
      "totalDays": 0,
      "status": "N",
      "docTime": "09:31:00",
      "createDate": "20230210093100",
      "imageUrlCreateBy":
          "https://raot.we-builds.com/raot-document/images/member/member_234043642.png",
      "createBy": "admincms",
      "description":
          "<font face=\"Kanit\">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</font>",
    },
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _loading();
    _loadingM();
    super.initState();
  }

  void _loading() async {
    var listModel = [];
    setState(() {
      listModel = [...list];
      if (listModel.isNotEmpty) {
        for (var i = 0; i < listModel.length; i++) {
          var categoryDays = listModel[i]['totalDays'] == 0
              ? "1"
              : listModel[i]['totalDays'] == 1
                  ? "2"
                  : listModel[i]['totalDays'] <= 7 &&
                          listModel[i]['totalDays'] > 0
                      ? "3"
                      : listModel[i]['totalDays'] > 7
                          ? "4"
                          : "";
          listModel[i]['categoryDays'] = categoryDays;
          listModel[i]['isSelected'] = false;
          listData.add(listModel[i]);
        }
      }

      setState(() {
        listResultData = listData;
      });
      chkListCount = listResultData.isNotEmpty ? true : false;
      chkListActive =
          listData.where((x) => x['status'] != "A").toList().isNotEmpty
              ? true
              : false;
      totalSelected = 0;
      _futureModel = Future.value(listData);
    });
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _loadingM() async {
    var listModel = [];
    setState(() {
      listModel = [...listM];
      if (listModel.isNotEmpty) {
        for (var i = 0; i < listModel.length; i++) {
          var categoryDays = listModel[i]['totalDays'] == 0
              ? "1"
              : listModel[i]['totalDays'] == 1
                  ? "2"
                  : listModel[i]['totalDays'] <= 7 &&
                          listModel[i]['totalDays'] > 0
                      ? "3"
                      : listModel[i]['totalDays'] > 7
                          ? "4"
                          : "";
          listModel[i]['categoryDays'] = categoryDays;
          listModel[i]['isSelected'] = false;
          listMData.add(listModel[i]);
        }
      }

      setState(() {
        listMResultData = listMData;
      });
      chkListCount = listMResultData.isNotEmpty ? true : false;
      chkListActive =
          listMData.where((x) => x['status'] != "A").toList().isNotEmpty
              ? true
              : false;
      totalSelected = 0;
      _futureModelM = Future.value(listMData);
    });
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _clearSelected() {
    setState(() {
      isCheckSelect = false;
      for (int j = 0; j < listData.length; j++) {
        listData[j]['isSelected'] = false;
      }

      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  void _holdClick(dynamic model) {
    setState(() {
      if (!isCheckSelect) {
        isCheckSelect = true;
        for (int j = 0; j < listData.length; j++) {
          if (listData[j]['code'] == model['code']) {
            listData[j]['isSelected'] = !listData[j]['isSelected'];
          }
        }
      } else {
        for (int j = 0; j < listData.length; j++) {
          if (listData[j]['code'] == model['code']) {
            listData[j]['isSelected'] = !listData[j]['isSelected'];
          }
        }
      }
      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  void _singleClick(dynamic model) {
    setState(() {
      for (int j = 0; j < listData.length; j++) {
        if (listData[j]['code'] == model['code']) {
          listData[j]['isSelected'] = !listData[j]['isSelected'];
        }
      }

      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  textNotiEmpty(String categoryDay) {
    switch (categoryDay) {
      case '1':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือน\nสำหรับวันนี้";
        }
      case '2':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือน\nสำหรับเมื่อวาน";
        }
      case '3':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือน\nเมื่อ 7 วันก่อน";
        }
      case '4':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือน\nที่เก่ากว่า 7 วัน";
        }
      case '5':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือน\nที่ยังไม่อ่าน";
        }
      default:
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือน\nทั้งหมด";
        }
    }
  }

  checkNavigationPage(String page, dynamic model) {
    switch (page) {
      case 'mainPage':
        {}
        break;
      case 'bookingPage':
        {}
        break;
      default:
        {
          Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
        }
        break;
    }
  }

  checkCategoryName(String page, dynamic model) {
    switch (page) {
      case 'mainPage':
        {
          return "กำหนดเอง";
        }
      case 'bookingPage':
        {
          return "แจ้งเตือนระบบ";
        }
      default:
        {
          return "";
        }
    }
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHead(),
              const SizedBox(height: 20),
              _buildContent(),
              // _buildButtion(),
              // const SizedBox(height: 20),
              // selectedType == '0'
              //     ? _buildSelectedType0()
              //     : _buildSelectedType2(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHead() {
    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20, right: 20, left: 20),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              height: 30,
              width: 30,
              child: Center(
                child: Image.asset(
                  'assets/images/arrow_back.png',
                  height: 16,
                  width: 8,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'แจ้งเตือน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      margin: const EdgeInsets.only(right: 20, left: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.title2,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '25 เม.ย. 2566',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0x80000000),
            ),
          ),
        ],
      ),
    );
  }

//
}
