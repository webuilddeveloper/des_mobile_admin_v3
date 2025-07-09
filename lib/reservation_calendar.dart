import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'config.dart';
import 'reservation_add.dart';
import 'shared/event_utils.dart';
import 'shared/extension.dart';

class ReservationCalendarPage extends StatefulWidget {
  const ReservationCalendarPage({super.key});

  @override
  State<ReservationCalendarPage> createState() =>
      _ReservationCalendarPageState();
}

class _ReservationCalendarPageState extends State<ReservationCalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ValueNotifier<List<dynamic>> _selectedEvents;
  Map<DateTime, List>? _events;
  late CalendarFormat _calendarFormat;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<DateTime, List<dynamic>>? itemevent;
  late LinkedHashMap<DateTime, List<dynamic>> model;
  var markData = [];

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _otherController;
  String _emailStringValidate = '';
  String _phoneStringValidate = '';
  late bool _loadingSubmit;
  late bool _loadingPeriod;

  late List<dynamic> _timeData;
  late String _rangeTimeStr;
  late String _hoursAmountStr;
  late FToast fToast;
  late List<dynamic> _deviceList;
  late List<dynamic> _modelType;
  late List<dynamic> _modelBookingCategory;

  bool _loadingDropdownType = false;

  String _typeSelected = '';
  @override
  void initState() {
    _loadingSubmit = false;
    _loadingPeriod = true;

    _modelType = [
      {
        "recordId": 99999,
        "typeName": "โปรดเลือกประเภทการจอง",
        "remark": null,
        "refNo": ""
      }
    ];
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
    getMarkerEvent();
    _emailController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _otherController = TextEditingController(text: '');
    _calendarFormat = CalendarFormat.month;
    model = kEvents;
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _timeData = [];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    _setData();
    _callReadType();
    _callReadBookingCategory();
  }

  _setData() async {
    _rangeTimeStr = '-';
    _hoursAmountStr = '-';

    String dateStr = DateFormat('yyyyMMdd000000').format(DateTime.now());
    _callReadPeriod(dateStr);
  }

  _callReadType() async {
    try {
      setState(() => _loadingDropdownType = true);
      Response response =
          await Dio().get('$ondeURL/api/masterdata/book/slotType');

      setState(() => _loadingDropdownType = false);
      setState(() {
        _modelType = [
          {
            "recordId": 99999,
            "typeName": "โปรดเลือกประเภทการจอง",
            "remark": null,
            "refNo": ""
          },
          ...response.data
        ];
      });
      logWTF(_modelType);
    } catch (e) {
      logE(e);
      setState(() => _loadingDropdownType = false);
    }
  }

  _callReadBookingCategory() async {
    try {
      setState(() => _loadingDropdownType = true);
      Response response =
          await Dio().get('$ondeURL/api/masterdata/bookingcategories');

      setState(() => _loadingDropdownType = false);
      setState(() {
        _modelBookingCategory = response.data;

        _modelBookingCategory.forEach((e) {
          e['selected'] = false;
        });
      });
      logWTF(_modelBookingCategory);
    } catch (e) {
      logE(e);
      setState(() => _loadingDropdownType = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Color(0xFFfdf9ff)),
          ),
          centerTitle: true,
          title: const Text(
            'รายละเอียด',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
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
        ),
        body: ListView(
          children: [
            _buildTable(),
            _buildToggle(),
            _buildValueListenable(),
          ],
        ),
      ),
    );
  }

  _checkOldDay() {
    DateTime now = DateTime.now();
    DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);

    if (_selectedDay.compareTo(nowWithoutTime) <= 0) {
      return true;
    }
    return false;
  }

  _buildTable() {
    return Container(
      color: const Color(0xFFFCFAFF),
      child: TableCalendar<dynamic>(
        firstDay: kFirstDay,

        lastDay: kLastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
        availableGestures: AvailableGestures.all,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18,
          ),
          formatButtonVisible: false,
          titleTextFormatter: (date, locale) {
            var year = date.year + 543;
            return DateFormat('MMMM พ.ศ. $year').format(date);
          },
        ),

        calendarStyle: CalendarStyle(
          cellMargin: const EdgeInsets.all(10),
          outsideDaysVisible: true,
          weekendDecoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFA06CD5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          weekendTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).primaryColor,
          ),
          defaultDecoration: BoxDecoration(
            // ขอบวันทำงาน
            border: Border.all(
              color: const Color(0xFFA06CD5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          defaultTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFA06CD5), //ตัวเลขวัน
          ),
          markerDecoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFA06CD5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          selectedDecoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFA06CD5),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          todayTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        onDaySelected: _onDaySelected,
        // onRangeSelected: _onRangeSelected,
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.all(10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFA06CD5),
                border: Border.all(
                  color: const Color(0xFFA06CD5),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: const TextStyle().copyWith(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
          defaultBuilder: (context, date, _) {
            // Check if the date is before today
            bool isPast = date.isBefore(DateTime.now());

            return Container(
              margin: const EdgeInsets.all(10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPast
                    ? const Color(0xFFD9D9D9)
                    : Colors.white, // Set grey for past dates
                border: Border.all(
                  color: isPast
                      ? const Color(0xFFB3B3B3)
                      : const Color(0xFFA06CD5),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isPast
                      ? const Color(0xFFB3B3B3)
                      : const Color(
                          0xFFA06CD5), // Set text color for past dates
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildToggle() {
    return Stack(
      children: [
        const SizedBox(
          height: 106,
          width: double.infinity,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 86,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAFF),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.1),
                  // spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 1,
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA06CD5),
                          border: Border.all(
                            color: const Color(0xFFA06CD5),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'วันที่กำลังเลือก',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 25),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFA06CD5),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'วันที่จองได้',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() {
                _calendarFormat == CalendarFormat.week
                    ? _calendarFormat = CalendarFormat.month
                    : _calendarFormat = CalendarFormat.week;
              }),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: _calendarFormat == CalendarFormat.week
                    ? const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildValueListenable() {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'เวลาเริ่ม - เวลาเลิก',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 15),
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        runSpacing: 12,
                        children: _timeData
                            .asMap()
                            .map((i, e) => MapEntry(i, _buildTimeItem(e, i)))
                            .values
                            .toList(),
                      ),
                    ),
                    if (_loadingPeriod)
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5)),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_timeData.any((element) => element['selected']))
                  ..._widgetList(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _widgetList() {
    return <Widget>[
      Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'ช่วงเวลาที่เลือก: $_rangeTimeStr น.\n รวมทั้งหมด ',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF7209B7),
              fontFamily: 'Kanit',
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' $_hoursAmountStr ชั่วโมง',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF7209B7),
                  fontFamily: 'Kanit',
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 30),
      const Text(
        'เลือกประเภทการจอง',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 5),
      _dropdown(
        data: _modelType,
        value: _typeSelected,
        onChanged: (String value) {
          setState(() {
            _typeSelected = value;
          });
        },
      ),
      const SizedBox(height: 15),
      const Text(
        'ข้อมูลสมาชิก',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      _buildFeild(
        controller: _emailController,
        hint: 'อีเมล เจ้าหน้าที่ศูนย์ หรือสมาชิก',
        keyboardType: TextInputType.emailAddress,
        validateString: _emailStringValidate,
        inputFormatters: InputFormatTemple.email(),
        validator: (value) {
          var result = ValidateForm.email(value!);
          setState(() {
            _emailStringValidate = result ?? '';
          });
          return result == null ? null : '';
        },
      ),
      const SizedBox(height: 10),
      _buildFeild(
        controller: _phoneController,
        hint: 'เบอร์โทรศัพท์ เจ้าหน้าที่ศูนย์ หรือสมาชิก',
        keyboardType: TextInputType.phone,
        validateString: _phoneStringValidate,
        inputFormatters: InputFormatTemple.phone(),
        validator: (value) {
          var result = ValidateForm.phone(value!);
          setState(() {
            _phoneStringValidate = result ?? '';
          });
          return result == null ? null : '';
        },
      ),
      const SizedBox(height: 15),
      const Text(
        'หมวดหมู่การใช้งาน',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: 10),
      _buildBookingCategory(),
      const SizedBox(height: 33),
      GestureDetector(
        onTap: () async {
          if (_typeSelected == '0') {
            _showToast('เลือกรูปแบบการจอง');
            return;
          }
          if (_emailController.text.isEmpty) {
            _showToast('กรอกอีเมล');
            return;
          }
          if (_phoneController.text.isEmpty) {
            _showToast('กรอกเบอร์โทรศัพท์');
            return;
          }

          setState(() {
            _loadingSubmit = true;
          });

          try {
            var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';

            var tempDate = DateFormat('yyyy-MM-ddT00:00:00')
                .format(_selectedDay)
                .toString();

            var bookingCategory = '';
            _modelBookingCategory.forEach((e) {
              if (e['selected']) {
                if (bookingCategory.isEmpty) {
                  bookingCategory =
                      bookingCategory + e['bookingCatId'].toString();
                } else {
                  bookingCategory =
                      bookingCategory + ',' + e['bookingCatId'].toString();
                }
              }
            });
            var data = {
              "bookingDate": tempDate,
              "bookingSlotType": _modelType
                  .firstWhere((e) => e['refNo'] == _typeSelected)['recordId'],
              "centerId": profileMe?['centerId'].toString() ?? '',
              "startTime": _rangeTimeStr.split('-')[0].trim(),
              "endTime": _rangeTimeStr.split('-')[1].trim(),
              "userEmail": _emailController.text,
              "userid": 0, // for test = 0; waiting API.
              "phone": _phoneController.text,
              "desc": '', //_hoursAmountStr
              "remark": bookingCategory,
              "otherCategoryRemark": _otherController.text,
              'bookingSlotTypeName': _modelType
                  .firstWhere((e) => e['refNo'] == _typeSelected)['typeName'],
              'hours': _hoursAmountStr,
              'date': _selectedDay,
            };

            logWTF(data);
            setState(() => _loadingSubmit = false);
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationAddPage(
                  model: data,
                ),
              ),
            );
            setState(() => _loadingSubmit = false);
          } on DioError catch (e) {
            setState(() => _loadingSubmit = false);
            var err = e.response!.data['message'];
            Fluttertoast.showToast(msg: err);
          }
        },
        child: Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _loadingSubmit
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x40F3D2FF),
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              const Text(
                'จองเลย',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              if (_loadingSubmit)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  _dropdown(
      {required List<dynamic> data,
      required String value,
      Function(String)? onChanged}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x40F3D2FF),
            offset: Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonFormField(
        icon: Image.asset(
          'assets/images/arrow_down.png',
          width: 16,
          height: 8,
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0x807209B7),
        ),
        decoration: CusInpuDecoration.base(context),
        value: value,
        // validator: (value) =>
        //     value == '' || value == null ? 'กรุณาเลือก' : null,
        onChanged: (dynamic newValue) {
          onChanged!(newValue);
        },
        items: data.map((item) {
          return DropdownMenuItem(
            value: item['refNo'],
            child: Text(
              '${item['typeName']}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0x807209B7),
                fontFamily: 'Kanit',
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeild({
    required TextEditingController controller,
    String hint = '',
    Function(String?)? validator,
    String validateString = '',
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x40F3D2FF),
                offset: Offset(0, 4),
              )
            ],
          ),
          child: TextFormField(
            // obscureText: true,
            keyboardType: keyboardType,
            controller: controller,
            style: const TextStyle(fontSize: 14),
            inputFormatters: inputFormatters,
            decoration: CusInpuDecoration.base(
              context,
              hintText: hint,
            ),
            validator: (String? value) => validator!(value),
          ),
        ),
        if (validateString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 3),
            child: Text(
              validateString,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildTimeItem(dynamic e, int i) {
    DateTime selectedDay = _selectedDay; // ค่า selectedDay ที่คุณใช้
    DateTime currentDay = DateTime.now();

    // เช็คว่า selectedDay เป็นวันเดียวกับวันที่ปัจจุบัน
    bool isToday = isSameDay(selectedDay, currentDay);

    // แปลงเวลาในรูปแบบ String เป็น DateTime
    DateTime startTime = DateTime.parse(
        '${DateTime.now().toString().split(' ')[0]} ${e['start']}:00');
    DateTime currentTime = DateTime.now();

    // เช็คเฉพาะเวลาที่ผ่านในวันปัจจุบัน
    bool isPast = isToday && currentTime.isAfter(startTime);

    return GestureDetector(
      onTap: () {
        if (!isPast) {
          try {
            var current = _timeData[i]['selected'];
            var previous = i == 0 ? false : _timeData[i - 1]['selected'];
            var next = i == _timeData.length - 1
                ? false
                : _timeData[i + 1]['selected'];
            var result = false;
            if (!previous && !next) {
              bool hasItem = _timeData.any((e) => e['selected']);
              int lenghtSelected =
                  _timeData.where((e) => e['selected'] == true).length;
              if (!hasItem && !current) {
                result = true;
              } else if (lenghtSelected == 1 && current) {
                result = true;
              }
            } else if (previous && next) {
              result = false;
            } else {
              result = true;
            }

            setState(() {
              if (result) {
                _timeData[i]['selected'] = !_timeData[i]['selected'];
              } else {
                _showToast('โปรดเลือกช่วงเวลาที่ติดกันเท่านั้น');
                // Fluttertoast.showToast(
                //   msg: 'โปรดเลือกช่วงเวลาที่ติดกันเท่านั้น',
                // );
              }

              List<dynamic> listSelected =
                  _timeData.where((element) => element['selected']).toList();
              if (listSelected.isNotEmpty) {
                int amount =
                    _timeData.where((element) => element['selected']).length;
                String first = listSelected[0]['start'];
                String last = listSelected[listSelected.length - 1]['end'];
                String minute = (amount % 2) == 1 ? '.30' : '';
                _hoursAmountStr = '${(amount / 2).floor().toString()}$minute';
                _rangeTimeStr = '$first - $last';
              } else {
                _hoursAmountStr = '-';
                _rangeTimeStr = '-';
              }
            });
            // _fDeviceList();
          } catch (e) {
            Fluttertoast.showToast(
              msg: 'เกิดข้อผิดพลาด',
            );
          }
        }
      },
      child: Container(
        height: 40,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: e['selected']
              ? const Color(0xFFA06CD5)
              : isPast
                  ? const Color(0xFFD9D9D9)
                  : Colors.white,
          border: Border.all(
            color: isPast ? Color(0xFFB3B3B3) : const Color(0xFFA06CD5),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          e['title'],
          style: TextStyle(
            fontSize: 13,
            color: e['selected']
                ? Colors.white
                : isPast
                    ? Color(0xFFB3B3B3)
                    : const Color(0xFFA06CD5),
            fontWeight: e['selected'] ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  getMarkerEvent() async {
    var objectData = [];
    // var value = await storage.read(key: 'dataUserLoginKSP');
    // var data = json.decode(value);
    final response = await Dio()
        .post('$serverUrl/dcc-api/m/eventCalendar/mark/read2', data: {
      "year": DateTime.now().year - 1,
      "organization": [],
    });
    var result = response.data;
    if (result['status'] == 'S') {
      objectData = result['objectData'];

      _events = {};

      for (int i = 0; i < objectData.length; i++) {
        if (objectData[i]['items'].length > 0) {
          markData.add(objectData[i]);
        }
      }

      itemevent = Map.fromIterable(
        markData,
        key: (item) => DateTime.parse(item['date']),
        value: (item) => item['items'],
      );

      var mainEvent = LinkedHashMap<DateTime, List<dynamic>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(itemevent!);
      setState(() {
        model = mainEvent;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Implementation example
    // print('kEvents ---> $kEvents');

    // return kEvents[day] ?? [];
    return model[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    DateTime now = DateTime.now();
    DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);
    if (selectedDay.compareTo(nowWithoutTime) <= 0) {
      return;
    }
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // _rangeStart = null; // Important to clean those
        // _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);

      String dateStr = DateFormat('yyyyMMdd000000').format(_selectedDay);
      _callReadPeriod(dateStr);
    }
  }

  Widget _buildEventsMarker(List events) {
    return const SizedBox();
  }

  Widget _buildBookingCategory() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: ClampingScrollPhysics(),
      itemCount: _modelBookingCategory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => GestureDetector(
        onTap: () {
          setState(() {
            _modelBookingCategory[__]['selected'] =
                !_modelBookingCategory[__]['selected'];
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Color(0xFFA06CD5),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: _modelBookingCategory[__]['selected']
                              ? Color(0xFFA06CD5)
                              : Color(0xFFFFFFFF)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_modelBookingCategory[__]['catNameTh']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFA06CD5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_modelBookingCategory[__]['bookingCatId'] == 8 &&
                  _modelBookingCategory[__]['selected']) ...[
                const SizedBox(height: 10),
                _buildFeild(
                  controller: _otherController,
                  hint: 'กรอกข้อมูลเพิ่มเติม',
                  keyboardType: TextInputType.emailAddress,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  _fDeviceList() async {
    var lessDevices = [];
    int lengthData = 0;
    List<String> nonDuplicate = [];
    List<dynamic> duplicate = [];
    List<String> mergeList = [];

    List<dynamic> dataSelected = _timeData.where((e) => e['selected']).toList();
    dataSelected.map((e) => lessDevices.addAll(e['deviceList'])).toList();

    lengthData = dataSelected.length;

    lessDevices.map((u) {
      if (nonDuplicate.contains(u)) {
        int index = duplicate.indexWhere((item) => item["value"] == u);
        duplicate[index]['amount'] += 1;
      } else {
        nonDuplicate.add(u);
        duplicate.add({'value': u, 'amount': 1});
      }
    }).toList();

    // var lessSetList = lessDevices.toSet().toList();

    if (duplicate.isEmpty) {
      mergeList = nonDuplicate;
    } else {
      duplicate.map((e) {
        if (e['amount'] == lengthData) {
          mergeList.add(e['value']);
        }
      }).toList();
    }

    // logWTF('mergeList $mergeList');

    var result = mergeList
        .map((e) => {'code': e, 'title': 'เครื่องคอมพิวเตอร์ $e'})
        .toList();

    result = [
      {'code': '0', 'title': 'เลือกเครื่องคอมพิวเตอร์'},
      ...result
    ];
    setState(() {
      _deviceList = result;
    });
  }

  // _callReadPeriod(date) async {
  //   setState(() {
  //     _loadingPeriod = true;
  //   });
  //   Dio dio = Dio();
  //   try {
  //     var data = [
  //       // {
  //       //   "code": "0",
  //       //   "title": "08:00 - 08:30",
  //       //   "start": "08:00",
  //       //   "end": "08:30",
  //       //   "selected": false
  //       // },
  //       {
  //         "code": "0",
  //         "title": "08:30 - 09:00",
  //         "start": "08:30",
  //         "end": "09:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "1",
  //         "title": "09:00 - 09:30",
  //         "start": "09:00",
  //         "end": "09:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "2",
  //         "title": "09:30 - 10:00",
  //         "start": "09:30",
  //         "end": "10:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "3",
  //         "title": "10:00 - 10:30",
  //         "start": "10:00",
  //         "end": "10:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "4",
  //         "title": "10:30 - 11:00",
  //         "start": "10:30",
  //         "end": "11:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "5",
  //         "title": "11:00 - 11:30",
  //         "start": "11:00",
  //         "end": "11:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "6",
  //         "title": "11:30 - 12:00",
  //         "start": "11:30",
  //         "end": "12:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "7",
  //         "title": "12:00 - 12:30",
  //         "start": "12:00",
  //         "end": "12:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "8",
  //         "title": "12:30 - 13:00",
  //         "start": "12:30",
  //         "end": "13:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "9",
  //         "title": "13:00 - 13:30",
  //         "start": "13:00",
  //         "end": "13:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "10",
  //         "title": "13:30 - 14:00",
  //         "start": "13:30",
  //         "end": "14:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "11",
  //         "title": "14:00 - 14:30",
  //         "start": "14:00",
  //         "end": "14:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "12",
  //         "title": "14:30 - 15:00",
  //         "start": "14:30",
  //         "end": "15:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "13",
  //         "title": "15:00 - 15:30",
  //         "start": "15:00",
  //         "end": "15:30",
  //         "selected": false
  //       },
  //       {
  //         "code": "14",
  //         "title": "15:30 - 16:00",
  //         "start": "15:30",
  //         "end": "16:00",
  //         "selected": false
  //       },
  //       {
  //         "code": "15",
  //         "title": "16:00 - 16:30",
  //         "start": "16:00",
  //         "end": "16:30",
  //         "selected": false
  //       }
  //     ];
  //     // Response response = await dio.post('$serverUrl/dcc-api/m/reservation/period/read',
  //     //     data: {'date': date});
  //     setState(() {
  //       _timeData = data;
  //       _loadingPeriod = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _loadingPeriod = false;
  //     });
  //   }
  // }

  _callReadPeriod(String date) async {
    setState(() {
      _loadingPeriod = true;
    });

    Dio dio = Dio();
    try {
      // เรียกข้อมูลจาก API
      var profileMe = await ManageStorage.readDynamic('profileMe') ?? '';
      Response centerResponse = await dio.get(
        'https://dcc.onde.go.th/dcc-api/api/OfficeDigital/GetCenterByID/${profileMe['centerId']}',
      );

      if (centerResponse.statusCode == 200) {
        logWTF(centerResponse.data);
        logE(centerResponse.data['data']['firstStartTime']);
        logE(centerResponse.data['data']['secondEndTime']);

        // รับค่า firstStartTime และ  secondEndTime จาก API
        String startTime = centerResponse.data['data']['firstStartTime'];
        String endTime = centerResponse.data['data']['secondEndTime'];

        // String startTime = "08:30:00";
        // String endTime = "16:30:00";
        // Print ตรวจสอบค่าเวลาเริ่มต้นและสิ้นสุด
        print(
            " ============1============> Start Time from API:      $startTime");
        print(" ==============2==========> End Time from API:        $endTime");

        // แปลงเวลาเริ่มต้นและสิ้นสุดเป็น DateTime
        DateTime start = DateFormat("HH:mm:ss").parse(startTime);
        DateTime end = DateFormat("HH:mm:ss").parse(endTime);

        print("========3================> Start Time DateFormat: $start");
        print(" ==============4==========> End Time DateFormat: $end");

        List<Map<String, dynamic>> data = [];
        int code = 0;

        // สร้างช่วงเวลาครึ่งชั่วโมง
        while (start.isBefore(end)) {
          DateTime nextTime = start.add(Duration(minutes: 30));
          data.add({
            "code": "$code",
            "title":
                "${DateFormat("HH:mm").format(start)} - ${DateFormat("HH:mm").format(nextTime)}",
            "start": DateFormat("HH:mm").format(start),
            "end": DateFormat("HH:mm").format(nextTime),
            "selected": false,
          });

          // Print ดูช่วงเวลาที่สร้างแต่ละช่วง
          print("Code: $code, Title: ${data.last['title']}");

          start = nextTime;
          code++;
        }

        setState(() {
          _timeData = data;
          _loadingPeriod = false;
        });

        // Print ตรวจสอบ data ที่ได้ทั้งหมด
        print("Generated Time Periods: $data");
      } else {
        setState(() {
          _loadingPeriod = false;
        });
      }
    } catch (e) {
      print("Error: $e"); // Print ข้อผิดพลาดในกรณีเกิด error
      setState(() {
        _loadingPeriod = false;
      });
    }
  }

  _showToast(String title) {
    Widget toast = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xFFFFF1C0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/warning_icon.png', height: 21, width: 21),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFDD9200),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
