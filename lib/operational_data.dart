import 'package:des_mobile_admin_v3/operational_search_result.dart';
import 'package:des_mobile_admin_v3/shared/event_utils.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui' as ui show ImageFilter;
import 'config.dart';
import 'login.dart';
import 'operational_detail.dart';
import 'shared/extension.dart';
import 'shared/secure_storage.dart';
import 'widget/no_data.dart';

// ignore: must_be_immutable
class OperationalDataPage extends StatefulWidget {
  OperationalDataPage({super.key, this.changePage});
  late _OperationalDataPageState homeCentralPageState;
  Function? changePage;

  @override
  State<OperationalDataPage> createState() => _OperationalDataPageState();

  getState() => homeCentralPageState;
}

class _OperationalDataPageState extends State<OperationalDataPage>
    with SingleTickerProviderStateMixin {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  // late TextEditingController _searchYearController;
  // late TextEditingController _searchMonthController;
  late CalendarFormat _calendarFormat;
  DateTime _focusedDay = DateTime.now();
  late ValueNotifier<List<dynamic>> _selectedEvents;
  late DateTime _selectedDay;
  int month = 0;
  int year = 0;

  Map<String, dynamic>? myProcessModel;
  bool isLoading = true;

  // late Future<dynamic> _futureProfile;
  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtIdCard = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtUserName = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  int selectedMenuIndex = 0;
  final _selectedColor = const Color(0xFF7209B7);
  final _unselectedColor = Colors.black.withOpacity(0.31);
  late TabController _tabController;

  List<dynamic> menu = [
    {"id": 0, "code": "", "title": "ทั้งหมด"},
    {"id": 1, "code": "leave", "title": "การลา"},
    {"id": 2, "code": "work", "title": "การทำงาน"},
  ];

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    _callRead();
    _onDaySelected;
    DateTime _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    // myProcessModel = OperationalMockData().mockData;
    // _tabController = TabController(length: 3, vsync: this);
    // setState(() {
    //   txtFirstName.text = "";
    // });
    // ดึงค่าปีและเดือนปัจจุบัน
    // _calendarFormat = CalendarFormat.month;
    // String currentYear = _focusedDay.year.toString();
    // String currentMonth = _focusedDay.month
    //     .toString()
    //     .padLeft(2, '0'); // เพิ่มเลข 0 ข้างหน้า ถ้าเป็นเลขหลักเดียว
    // // กำหนดค่าให้กับ TextEditingController
    // _searchYearController = TextEditingController(text: currentYear);
    // _searchMonthController = TextEditingController(text: currentMonth);
    super.initState();
  }

  @override
  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _callRead() async {
    setState(() {
      isLoading = true; // ตั้งสถานะเป็นกำลังโหลดเมื่อเริ่มดึงข้อมูล
    });
    String token = await ManageStorage.read('accessToken_122') ?? '';

    int month = _selectedDay.month;
    int year = _selectedDay.year;

    if (token.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    // print ยาว
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(token).forEach((match) => print(match.group(0)));
    Response response = await Dio().get(
      '$ondeURL/api/StaffCalendar/GetStaffCalenderWorkday?month=${_selectedDay.month}&year=${_selectedDay.year}&isPagination=false&key=false&direction=true&isGetPrvious_Next_Data=true',
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
    print('------token------->>> ${token}');

    print('yyyyyyyyyyyyyyyyyyyyyyyyyyyyy 11 $_selectedDay');

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['data'];
      logE(data);
      // print(
      //   'yyyyyyyyyyyyyyyyyyyyyyyyyyyyy 22 ${data[0]['workdate'].toString()}',
      // );

      var selectedWorkData = data.firstWhere((item) {
        DateTime workdate = DateTime.parse(item['workdate']);
        DateTime selectedDay = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        );
        DateTime workdateOnly = DateTime(
          workdate.year,
          workdate.month,
          workdate.day,
        );

        return isSameDay(workdateOnly, selectedDay);
      }, orElse: () => null);

      print('---------selectedWorkData-------->>>  $selectedWorkData');

      if (selectedWorkData != null) {
        setState(() {
          myProcessModel = selectedWorkData;
          logWTF(myProcessModel);
        });
      } else {
        setState(() {
          myProcessModel = null;
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  _checkOldDay() {
    DateTime now = DateTime.now();
    DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);

    if (_selectedDay.compareTo(nowWithoutTime) <= 0) {
      return true;
    }
    return false;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    DateTime now = DateTime.now();
    DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);

    // เช็คว่าห้ามเลือกวันเสาร์, อาทิตย์, หรือวันที่เกินจากวันปัจจุบัน
    if (selectedDay.weekday == DateTime.saturday ||
        selectedDay.weekday == DateTime.sunday ||
        selectedDay.isAfter(nowWithoutTime)) {
      return; // ไม่ทำอะไรถ้าหากเลือกวันเสาร์, อาทิตย์ หรือวันที่เกินปัจจุบัน
    }

    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        month = selectedDay.month;
        year = selectedDay.year;
      });

      _callRead();
    }
  }

  _convertDate(String date) {
    DateTime parsedDate = DateTime.parse(date); // แปลง String เป็น DateTime
    var thaiYear = parsedDate.year + 543;
    // กำหนด locale เป็นภาษาไทยและแปลงวันที่เป็นเดือนภาษาไทย
    var formattedDate = DateFormat('dd MMMM', 'th_TH').format(parsedDate);
    // ส่งวันที่ที่แปลงเป็น xx ตุลาคม 2567
    return '$formattedDate $thaiYear';
  }

  _converTime(String time) {
    DateTime checkinTime = DateTime.parse(time);
    String formattedTime = DateFormat('HH:mm').format(checkinTime);
    return '$formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    print(myProcessModel.toString());
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
            'ข้อมูลการปฏิบัติงาน',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: ListView(
          children: [
            __buildTable(),
            Center(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF7209B7)),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  _convertDate(myProcessModel!['workdate']),
                                  style: const TextStyle(
                                    // color: Theme.of(context).primaryColor,
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (myProcessModel!['checkin'] != null)
                                Text(
                                  'เข้า : ${_converTime(myProcessModel!['checkin'])}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (myProcessModel!['checkout'] != null)
                                Text(
                                  'ออก : ${_converTime(myProcessModel!['checkout'])} ',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (myProcessModel!['leave_Text'] != null &&
                                  myProcessModel!['leave_Text'] != '')
                                Text(
                                  'สถานะ : ${myProcessModel!['leave_Text']}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (myProcessModel!['leave_Code'] != null &&
                                  myProcessModel!['leave_Code'] != '')
                                Text(
                                  'สถานะ : ${myProcessModel!['leave_Code']}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (myProcessModel!['checkin'] == null &&
                                  myProcessModel!['checkout'] == null &&
                                  (myProcessModel!['leave_Text'] == null ||
                                      myProcessModel!['leave_Text'] == '') &&
                                  (myProcessModel!['leave_Code'] == null ||
                                      myProcessModel!['leave_Code'] == ''))
                                const Center(
                                  child: Text(
                                    "ไม่พบข้อมูลสำหรับวันนี้",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
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

        // SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       // _buildMyProcess(),
        //       const Divider(
        //         height: 50,
        //         thickness: 1,
        //         indent: 20,
        //         endIndent: 20,
        //         color: Color(0xFFD4D4D4),
        //       ),
        //       _buildSearch(),
        //       ListView.builder(
        //         shrinkWrap: true,
        //         physics:
        //             NeverScrollableScrollPhysics(), // ป้องกันการเลื่อนของ ListView ภายใน
        //         itemCount: myProcessModel.length, // จำนวนของ items ใน List
        //         itemBuilder: (context, index) {
        //           // ข้อมูลแต่ละ item ใน myProcessModel
        //           var process = myProcessModel[index];
        //           return ListTile(
        //             leading: Container(
        //               // width: double.infinity,
        //               // height: double.infinity,
        //               decoration: const BoxDecoration(
        //                 color: Color(0xFF7209B7),
        //                 borderRadius: BorderRadius.all(Radius.circular(9)),
        //               ),
        //               child: Container(
        //                 padding: const EdgeInsets.all(11),
        //                 child: Image.asset(
        //                   "assets/images/เวลาปฏิบัติงาน.png",
        //                   fit: BoxFit.contain,
        //                 ),
        //               ),
        //             ),
        //             title: Text(
        //                 process['workdate'].substring(0, 10) ?? 'No title'),
        //             subtitle: Text((process['leave_Text'] ?? '') +
        //                 ' ' +
        //                 (process['checkin'] ?? '') +
        //                 ' ' +
        //                 (process['checkout'] ?? '')),
        //           );
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget __buildTable() {
    DateTime now = DateTime.now();
    DateTime firstDayOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    DateTime lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

    return TableCalendar(
      firstDay: firstDayOfPreviousMonth,
      lastDay: lastDayOfCurrentMonth,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.all,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18,
        ),
        formatButtonVisible: false,
        titleTextFormatter: (date, locale) {
          var year = date.year + 543;
          return '${DateFormat('MMMM', 'th').format(date)} พ.ศ. $year';
        },
      ),
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.all(10),
        outsideDaysVisible: true,
        weekendDecoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFA06CD5)),
          borderRadius: BorderRadius.circular(10),
        ),
        weekendTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
        defaultDecoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFA06CD5)),
          borderRadius: BorderRadius.circular(10),
        ),
        defaultTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFA06CD5),
        ),
        markerDecoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFA06CD5)),
          borderRadius: BorderRadius.circular(10),
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(color: Color(0xFFA06CD5)),
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFA06CD5),
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        todayTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        disabledDecoration: BoxDecoration(
          border: Border.all(color: Color(0xFFB3B3B3)),
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledTextStyle: const TextStyle(
          color: Color(0xFFB3B3B3),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      enabledDayPredicate: (day) {
        DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);

        return day.weekday != DateTime.saturday &&
            day.weekday != DateTime.sunday &&
            day.isBefore(nowWithoutTime.add(Duration(days: 1)));
      },
      onDaySelected: _onDaySelected,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  // Widget __buildTable() {
  //   return TableCalendar(
  //     firstDay: kFirstDay,
  //     lastDay: kLastDay,
  //     focusedDay: _focusedDay,
  //     selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
  //     calendarFormat: _calendarFormat,
  //     availableGestures: AvailableGestures.all,
  //     startingDayOfWeek: StartingDayOfWeek.sunday,
  //     headerStyle: HeaderStyle(
  //       titleCentered: true,
  //       titleTextStyle: TextStyle(
  //         color: Theme.of(context).primaryColor,
  //         fontSize: 18,
  //       ),
  //       formatButtonVisible: false,
  //       titleTextFormatter: (date, locale) {
  //         // Format เดือนและปีใหม่
  //         var year = date.year + 543;
  //         return '${DateFormat('MMMM', 'th').format(date)} พ.ศ. $year';
  //       },
  //     ),
  //     calendarStyle: CalendarStyle(
  //       cellMargin: const EdgeInsets.all(10),
  //       outsideDaysVisible: true,
  //       weekendDecoration: BoxDecoration(
  //         border: Border.all(
  //           color: const Color(0xFFA06CD5),
  //         ),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       weekendTextStyle: const TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.w400,
  //         color: Colors.grey, // เปลี่ยนสีของวันเสาร์-อาทิตย์เป็นสีเทา
  //       ),
  //       defaultDecoration: BoxDecoration(
  //         border: Border.all(
  //           color: const Color(0xFFA06CD5),
  //         ),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       defaultTextStyle: const TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.w400,
  //         color: Color(0xFFA06CD5),
  //       ),
  //       markerDecoration: BoxDecoration(
  //         border: Border.all(
  //           color: const Color(0xFFA06CD5),
  //         ),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       selectedDecoration: BoxDecoration(
  //         border: Border.all(
  //           color: Color(0xFFA06CD5),
  //         ),
  //         borderRadius: BorderRadius.circular(10),
  //         color: Color(0xFFA06CD5),
  //       ),
  //       todayDecoration: BoxDecoration(
  //         color: Theme.of(context).primaryColor,
  //         border: Border.all(
  //           color: Theme.of(context).primaryColor,
  //         ),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       todayTextStyle: const TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.w400,
  //         color: Colors.white,
  //       ),
  //       disabledDecoration: BoxDecoration(
  //         border: Border.all(color: Color(0xFFB3B3B3)),
  //         color: const Color(0xFFD9D9D9),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       disabledTextStyle: const TextStyle(
  //         color: Color(0xFFB3B3B3),
  //         fontSize: 16,
  //         fontWeight: FontWeight.w400,
  //       ),
  //     ),
  //     enabledDayPredicate: (day) {
  //       DateTime now = DateTime.now();
  //       DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);

  //       return day.weekday != DateTime.saturday &&
  //           day.weekday != DateTime.sunday &&
  //           day.isBefore(nowWithoutTime.add(Duration(days: 1)));
  //     },
  //     onDaySelected: _onDaySelected,
  //     onPageChanged: (focusedDay) {
  //       setState(() {
  //         _focusedDay = focusedDay; // ใช้ setState เพื่ออัปเดต UI
  //       });
  //     },
  //   );
  // }

  // Widget _buildSearch() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 height: 40,
  //                 padding: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(7),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       blurRadius: 4,
  //                       color: Color(0x40F3D2FF),
  //                       offset: Offset(0, 4),
  //                     )
  //                   ],
  //                 ),
  //                 child: TextField(
  //                   keyboardType: TextInputType.number,
  //                   controller: _searchYearController,
  //                   style: const TextStyle(fontSize: 14),
  //                   decoration: CusInpuDecoration.base(
  //                     context,
  //                     hintText: 'ปี',
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             InkWell(
  //               onTap: () {
  //                 // if (_searchYearController.text.length > 2 ||
  //                 //     _searchYearController.text.isEmpty ||
  //                 //     int.parse(_searchYearController.text) > 31) {
  //                 //   Fluttertoast.showToast(msg: 'กรอกวันที่ต้องการค้นหา');
  //                 //   return;
  //                 // }
  //                 // Navigator.push(
  //                 //   context,
  //                 //   MaterialPageRoute(
  //                 //     builder: (contex) => OperationalSearchResultPage(
  //                 //       keySearch: _searchYearController.text,
  //                 //     ),
  //                 //   ),
  //                 // );
  //                 _callRead();
  //               },
  //               child: Container(
  //                 width: 40,
  //                 height: 40,
  //                 padding: const EdgeInsets.all(8.75),
  //                 decoration: BoxDecoration(
  //                   color: Theme.of(context).primaryColor,
  //                   borderRadius: BorderRadius.circular(7),
  //                 ),
  //                 child: Image.asset('assets/images/search.png'),
  //               ),
  //             )
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 height: 40,
  //                 padding: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(7),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       blurRadius: 4,
  //                       color: Color(0x40F3D2FF),
  //                       offset: Offset(0, 4),
  //                     )
  //                   ],
  //                 ),
  //                 child: TextField(
  //                   keyboardType: TextInputType.number,
  //                   controller: _searchMonthController,
  //                   style: const TextStyle(fontSize: 14),
  //                   decoration: CusInpuDecoration.base(
  //                     context,
  //                     hintText: 'เดือน',
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             InkWell(
  //               onTap: () {
  //                 // if (_searchMonthController.text.length > 2 ||
  //                 //     _searchMonthController.text.isEmpty ||
  //                 //     int.parse(_searchMonthController.text) > 31) {
  //                 //   Fluttertoast.showToast(msg: 'กรอกวันที่ต้องการค้นหา');
  //                 //   return;
  //                 // }
  //                 // Navigator.push(
  //                 //   context,
  //                 //   MaterialPageRoute(
  //                 //     builder: (contex) => OperationalSearchResultPage(
  //                 //       keySearch: _searchMonthController.text,
  //                 //     ),
  //                 //   ),
  //                 // );
  //                 _callRead();
  //               },
  //               child: Container(
  //                 width: 40,
  //                 height: 40,
  //                 padding: const EdgeInsets.all(8.75),
  //                 decoration: BoxDecoration(
  //                   color: Theme.of(context).primaryColor,
  //                   borderRadius: BorderRadius.circular(7),
  //                 ),
  //                 child: Image.asset('assets/images/search.png'),
  //               ),
  //             )
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMyProcess() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'การทำงานของฉัน',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'เริ่มงานตั้งแต่',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF767676),
                      ),
                    ),
                    Text(
                      '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ระยะเวลา',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF767676),
                      ),
                    ),
                    Text(
                      '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        // width: double.infinity,
                        // height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7209B7),
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(11),
                          child: Image.asset(
                            "assets/images/เวลาปฏิบัติงาน.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(flex: 1, child: SizedBox()),
                    Flexible(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'เวลาปฏิบัติงาน',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF767676),
                            ),
                          ),
                          Text(
                            '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        // width: double.infinity,
                        // height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7209B7),
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/images/วันลาคงเหลือ.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(flex: 1, child: SizedBox()),
                    Flexible(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'วันลาคงเหลือ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF767676),
                            ),
                          ),
                          Text(
                            '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _buildTabChange() {
  //   switch (selectedMenuIndex) {
  //     case 0:
  //       {
  //         return _buildInformations();
  //       }
  //     case 1:
  //       {
  //         return _buildHistory();
  //       }
  //     case 2:
  //       {
  //         return _buildMore();
  //       }
  //   }
  // }

  // Widget _buildLeaveHistory() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // TabBar(
  //         //   controller: _tabController,
  //         //   tabs: [
  //         //     Tab(
  //         //       child: Column(
  //         //         crossAxisAlignment: CrossAxisAlignment.center,
  //         //         mainAxisAlignment: MainAxisAlignment.center,
  //         //         children: [
  //         //           const Text(
  //         //             'ข้อมูลส่วนตัว',
  //         //             style: TextStyle(
  //         //                 // color: Colors.black.withOpacity(0.31),
  //         //                 fontSize: 14,
  //         //                 fontWeight: FontWeight.w400),
  //         //           ),
  //         //           Container(
  //         //             width: 5,
  //         //             height: 5,
  //         //             decoration: BoxDecoration(
  //         //               shape: BoxShape.circle,
  //         //               color: selectedMenuIndex == 0
  //         //                   ? const Color(0xFF7209B7)
  //         //                   : const Color(0xFFfdf9ff),
  //         //             ),
  //         //           )
  //         //         ],
  //         //       ),
  //         //     ),
  //         //     Tab(
  //         //       child: Column(
  //         //         crossAxisAlignment: CrossAxisAlignment.center,
  //         //         mainAxisAlignment: MainAxisAlignment.center,
  //         //         children: [
  //         //           const Text(
  //         //             'ประวัติการใช้งาน',
  //         //             style: TextStyle(
  //         //                 // color: Colors.black.withOpacity(0.31),
  //         //                 fontSize: 14,
  //         //                 fontWeight: FontWeight.w400),
  //         //           ),
  //         //           Container(
  //         //             width: 5,
  //         //             height: 5,
  //         //             decoration: BoxDecoration(
  //         //               shape: BoxShape.circle,
  //         //               color: selectedMenuIndex == 1
  //         //                   ? const Color(0xFF7209B7)
  //         //                   : const Color(0xFFfdf9ff),
  //         //             ),
  //         //           )
  //         //         ],
  //         //       ),
  //         //     ),
  //         //     Tab(
  //         //       child: Column(
  //         //         crossAxisAlignment: CrossAxisAlignment.center,
  //         //         mainAxisAlignment: MainAxisAlignment.center,
  //         //         children: [
  //         //           const Text(
  //         //             'อื่นๆ',
  //         //             style: TextStyle(
  //         //                 // color: Colors.black.withOpacity(0.31),
  //         //                 fontSize: 14,
  //         //                 fontWeight: FontWeight.w400),
  //         //           ),
  //         //           Container(
  //         //             width: 5,
  //         //             height: 5,
  //         //             decoration: BoxDecoration(
  //         //               shape: BoxShape.circle,
  //         //               color: selectedMenuIndex == 2
  //         //                   ? const Color(0xFF7209B7)
  //         //                   : const Color(0xFFfdf9ff),
  //         //             ),
  //         //           )
  //         //         ],
  //         //       ),
  //         //     ),
  //         //   ],
  //         //   indicatorWeight: 0,
  //         //   isScrollable: true,
  //         //   overlayColor: MaterialStateColor.resolveWith(
  //         //       (states) => const Color(0xFFfdf9ff)),
  //         //   unselectedLabelColor: _unselectedColor,
  //         //   dividerColor: const Color(0xFFfdf9ff),
  //         //   labelPadding: const EdgeInsets.only(right: 30),
  //         //   labelColor: _selectedColor,
  //         //   dragStartBehavior: DragStartBehavior.start,
  //         //   indicator: BoxDecoration(
  //         //     borderRadius: BorderRadius.circular(0.0),
  //         //     // color: _selectedColor.withOpacity(0.2),
  //         //   ),
  //         //   onTap: (value) {
  //         //     setState(() {
  //         //       selectedMenuIndex = value;
  //         //     });
  //         //   },
  //         // ),
  //         // SizedBox(
  //         //   height: 40,
  //         //   child: ListView.builder(
  //         //     scrollDirection: Axis.horizontal,
  //         //     itemCount: menu.length,
  //         //     itemBuilder: (BuildContext context, int index) {
  //         //       return GestureDetector(
  //         //         onTap: () {
  //         //           // FocusScope.of(context).unfocus();
  //         //           // var status;
  //         //           setState(() {
  //         //             selectedMenuIndex = index;
  //         //           });
  //         //         },
  //         //         child: Container(
  //         //           alignment: Alignment.center,
  //         //           margin: const EdgeInsets.only(right: 10),
  //         //           // decoration: new BoxDecoration(
  //         //           //   boxShadow: [
  //         //           //     BoxShadow(
  //         //           //       color: Colors.grey.withOpacity(0.2),
  //         //           //       spreadRadius: 0,
  //         //           //       blurRadius: 1,
  //         //           //       offset: Offset(0, 1), // changes position of shadow
  //         //           //     ),
  //         //           //   ],
  //         //           //   borderRadius: new BorderRadius.circular(12.5),
  //         //           //   color: index == selectedIndexCategory
  //         //           //       ? Theme.of(context).accentColor
  //         //           //       : Color(0xFFFFFFFF),
  //         //           // ),
  //         //           padding: const EdgeInsets.symmetric(
  //         //             horizontal: 7.0,
  //         //           ),
  //         //           // child: SizedBox(),
  //         //           child: Column(
  //         //             crossAxisAlignment: CrossAxisAlignment.center,
  //         //             children: [
  //         //               Text(
  //         //                 menu[index]['title'],
  //         //                 style: TextStyle(
  //         //                   color: index == selectedMenuIndex
  //         //                       ? Color(0xFF7209B7)
  //         //                       : Colors.black,
  //         //                   fontSize: 15.0,
  //         //                   fontWeight: FontWeight.w400,
  //         //                   // letterSpacing: 1.2,
  //         //                 ),
  //         //               ),
  //         //               index == selectedMenuIndex
  //         //                   ? Container(
  //         //                       width: 5,
  //         //                       height: 5,
  //         //                       decoration: const BoxDecoration(
  //         //                           shape: BoxShape.circle,
  //         //                           color: Color(0xFF7209B7)),
  //         //                     )
  //         //                   : const SizedBox()
  //         //             ],
  //         //           ),
  //         //         ),
  //         //       );
  //         //     },
  //         //   ),
  //         // ),
  //         // const NoDataWidget(),
  //         // if ((myProcessModel?['activityAll']?.length ?? 0) > 0)
  //         //   for (var i = 0; i < myProcessModel?['activityAll'].length; i++)
  //         //     GestureDetector(
  //         //       onTap: () => Navigator.push(
  //         //         context,
  //         //         MaterialPageRoute(
  //         //           builder: (_) => OperationalDetailPage(
  //         //             title: myProcessModel?['activityAll']?[i]?['title'] ?? '',
  //         //             model: myProcessModel?['activityAll']?[i] ?? '',
  //         //           ),
  //         //         ),
  //         //       ),
  //         //       child: Container(
  //         //         margin: const EdgeInsets.only(bottom: 20),
  //         //         child: Row(
  //         //           children: [
  //         //             Expanded(
  //         //               child: Row(
  //         //                 children: [
  //         //                   Expanded(
  //         //                     flex: 4,
  //         //                     child: Container(
  //         //                       decoration: const BoxDecoration(
  //         //                         color: Color(0xFF7209B7),
  //         //                         borderRadius:
  //         //                             BorderRadius.all(Radius.circular(12)),
  //         //                       ),
  //         //                       child: Container(
  //         //                         padding: const EdgeInsets.all(11),
  //         //                         child: Image.asset(
  //         //                           myProcessModel?['activityAll']?[i]
  //         //                                   ?['imageUrl'] ??
  //         //                               '',
  //         //                           fit: BoxFit.contain,
  //         //                         ),
  //         //                       ),
  //         //                     ),
  //         //                   ),
  //         //                   const Expanded(flex: 1, child: SizedBox()),
  //         //                   Flexible(
  //         //                     flex: 10,
  //         //                     child: Column(
  //         //                       crossAxisAlignment: CrossAxisAlignment.start,
  //         //                       children: [
  //         //                         Text(
  //         //                           myProcessModel?['activityAll']?[i]
  //         //                                   ?['title'] ??
  //         //                               '',
  //         //                           style: const TextStyle(
  //         //                               fontSize: 14,
  //         //                               fontWeight: FontWeight.w400,
  //         //                               color: Color(0xFF000000)),
  //         //                         ),
  //         //                         Text(
  //         //                           'ล่าสุด ${myProcessModel?['activityAll']?[i]?['activityLatest'] ?? ''}',
  //         //                           style: const TextStyle(
  //         //                               fontSize: 12,
  //         //                               fontWeight: FontWeight.w400,
  //         //                               color: Color(0xFF767676)),
  //         //                         ),
  //         //                       ],
  //         //                     ),
  //         //                   )
  //         //                 ],
  //         //               ),
  //         //             ),
  //         //             Expanded(
  //         //               child: Container(
  //         //                 alignment: Alignment.centerRight,
  //         //                 child: Text(
  //         //                   '${myProcessModel?['activityAll'][i]['count'] ?? ''} วัน',
  //         //                   style: const TextStyle(
  //         //                       fontSize: 14, fontWeight: FontWeight.w400),
  //         //                 ),
  //         //               ),
  //         //             )
  //         //           ],
  //         //         ),
  //         //       ),
  //         //     ),
  //         // SizedBox(
  //         //   height: MediaQuery.of(context).size.height,
  //         //   child:
  //         //   // ListView.separated(
  //         //   //   scrollDirection: Axis.vertical,
  //         //   //   separatorBuilder: (context, index) => const SizedBox(height: 20),
  //         //   //   itemCount: myProcessModel?['activityAll'].length,
  //         //   //   itemBuilder: (BuildContext context, int index) {
  //         //   //     return
  //         //   //     Row(
  //         //   //       children: [
  //         //   //         Expanded(
  //         //   //           child: Row(
  //         //   //             children: [
  //         //   //               Expanded(
  //         //   //                 flex: 4,
  //         //   //                 child: Container(
  //         //   //                   decoration: const BoxDecoration(
  //         //   //                     color: Color(0xFF7209B7),
  //         //   //                     borderRadius:
  //         //   //                         BorderRadius.all(Radius.circular(12)),
  //         //   //                   ),
  //         //   //                   child: Container(
  //         //   //                     padding: const EdgeInsets.all(11),
  //         //   //                     child: Image.asset(
  //         //   //                       myProcessModel?['activityAll'][index]['imageUrl'].toString(),
  //         //   //                       fit: BoxFit.contain,
  //         //   //                     ),
  //         //   //                   ),
  //         //   //                 ),
  //         //   //               ),
  //         //   //               const Expanded(flex: 1, child: SizedBox()),
  //         //   //               Flexible(
  //         //   //                 flex: 10,
  //         //   //                 child: Column(
  //         //   //                   crossAxisAlignment: CrossAxisAlignment.start,
  //         //   //                   children: [
  //         //   //                      Text(
  //         //   //                       myProcessModel?['activityAll'][index]['title'],
  //         //   //                       style: const TextStyle(
  //         //   //                           fontSize: 14,
  //         //   //                           fontWeight: FontWeight.w400,
  //         //   //                           color: Color(0xFF000000)),
  //         //   //                     ),
  //         //   //                     Text(
  //         //   //                       myProcessModel?['activityAll'][index]['activityLatest'],
  //         //   //                       style: const TextStyle(
  //         //   //                           fontSize: 12,
  //         //   //                           fontWeight: FontWeight.w400,
  //         //   //                           color: Color(0xFF767676)),
  //         //   //                     ),
  //         //   //                   ],
  //         //   //                 ),
  //         //   //               )
  //         //   //             ],
  //         //   //           ),
  //         //   //         ),
  //         //   //         Expanded(
  //         //   //           child: Container(
  //         //   //             alignment: Alignment.centerRight,
  //         //   //             child: const Text(
  //         //   //               '2 วัน',
  //         //   //               style: TextStyle(
  //         //   //                 fontSize: 14,
  //         //   //                 fontWeight: FontWeight.w400
  //         //   //               ),
  //         //   //             ),
  //         //   //           ),
  //         //   //         )
  //         //   //       ],
  //         //   //     );
  //         //   //     // Column(
  //         //   //     //   // crossAxisAlignment: CrossAxisAlignment.center,
  //         //   //     //   children: [
  //         //   //     //     Text(
  //         //   //     //       menu[index]['title'],
  //         //   //     //       style: TextStyle(
  //         //   //     //         color: index == selectedMenuIndex
  //         //   //     //             ? Color(0xFF7209B7)
  //         //   //     //             : Colors.black,
  //         //   //     //         fontSize: 15.0,
  //         //   //     //         fontWeight: FontWeight.w400,
  //         //   //     //         // letterSpacing: 1.2,
  //         //   //     //       ),
  //         //   //     //     ),
  //         //   //     //     index == selectedMenuIndex
  //         //   //     //         ? Container(
  //         //   //     //             width: 5,
  //         //   //     //             height: 5,
  //         //   //     //             decoration: const BoxDecoration(
  //         //   //     //                 shape: BoxShape.circle,
  //         //   //     //                 color: Color(0xFF7209B7)),
  //         //   //     //           )
  //         //   //     //         : const SizedBox()
  //         //   //     //   ],
  //         //   //     // ),
  //         //   //   },
  //         //   // ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  labelTextFormField(String label, TextEditingController txtController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 249, 233, 255),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                // height: 60,
                child: TextFormField(
                  style: const TextStyle(fontSize: 14),
                  controller: txtController,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              child: Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF000000).withOpacity(.24),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
