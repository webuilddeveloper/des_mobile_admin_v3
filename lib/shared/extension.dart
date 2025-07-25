// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';

enum ResponseStatus { success, fail, error, notMatch }

unfocus(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

connectInternet() async {
  try {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      logWTF('I am not connected to any network.');
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'ตรวจสอบการเชื่อมต่อ');
      return false;
    }
    return true;
  } catch (e) {
    logE('error Connectivity');
    logE(e);
    return true;
  }
}

currencyFormat(String param, {bool isDecimal = false}) {
  String def = "#,###";
  String decimal = "#,##0.00";
  if (isDecimal) {
    def = decimal;
  }
  final oCcy = NumberFormat(def, "en_US");
  return oCcy.format(double.parse(param));
}

dateThai(DateTime dateTime) {
  try {
    // String dateWithT = docDate;
    // DateTime dateTime = DateTime.parse(dateWithT);
    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
    String kcDate =
        DateFormat('dd MMMM พ.ศ. yyyy', 'th').format(dateTime).toString();
    String kcDateWithoutYear = kcDate.substring(0, kcDate.length - 4);
    String kcYear =
        (int.parse(kcDate.substring(kcDate.length - 4)) + 543).toString();
    return '$kcDateWithoutYear$kcYear';
  } catch (e) {
    return '';
  }
}

String getRandomString({int length = 10}) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ),
  );
}

moneyFormat(String price) {
  if (price.length > 2) {
    var value = price;
    value = value.replaceAll(RegExp(r'\D'), '');
    value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
    return value;
  }
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body!.text).documentElement!.text;

  return parsedString;
}

String checkSalary(start, end) {
  var formatCompact = NumberFormat.compact();
  if (start == end) {
    return formatCompact.format(start);
  } else {
    return '${formatCompact.format(start)} - ${formatCompact.format(end)}';
  }
}

String checkSalaryNoNumber(start, end) {
  if (start == end) {
    return start;
  } else {
    return start + ' - ' + end;
  }
}

dateTimeThai(DateTime date) {
  if (date == null) {
    return '-';
  } else {
    var formatThai = DateFormat('d MMMM', 'th').format(date);
    var dateResult = '$formatThai ${date.year + 543}';
    return dateResult;
  }
}

dateTimeThaiFormat(DateTime date) {
  if (date == null) {
    return '-';
  } else {
    var formatThai = DateFormat('d MMMM yyyy HH:mm:ss', 'th').format(date);
    // var dateResult = '$formatThai ${date.year + 543}';
    return formatThai;
  }
}

dateStringToDate(String date, {String separate = '-'}) {
  if (date == 'null') return '';
  if (date == '') {
    return '-';
  } else {
    var year = date.substring(0, 4);
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    // DateTime todayDate = DateTime.parse('$year-$month-$day');
    // var onlyBuddhistYear = todayDate.yearInBuddhistCalendar;
    // var formatter = DateFormat.yMMMMd();
    // var dateInBuddhistCalendarFormat =
    //     formatter.formatInBuddhistCalendarThai(todayDate);
    return day + separate + month + separate + year;
  }
}

dateStringToDateBirthDay(String date) {
  var year = date.substring(0, 4);
  var month = date.substring(4, 6);
  var day = date.substring(6, 8);
  DateTime todayDate = DateTime.parse('$year-$month-$day');

  return (todayDate);
}

dateStringToDateStringFormat(String date, {String type = '/'}) {
  String result = '';
  if (date != '') {
    String yearString = date.substring(0, 4);
    var yearInt = int.parse(yearString);
    var year = yearInt + 543;
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    result = day + type + month + type + year.toString();
  }

  return result;
}

dateStringToDateStringFormatDot(String date, {String type = '.'}) {
  String result = '';
  if (date != '') {
    String yearString = date.substring(0, 4);
    var yearInt = int.parse(yearString);
    var year = yearInt + 543;
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    result = day + type + month + type + year.toString();
  }

  return result;
}

differenceCurrentDate(String date) {
  String result = '';
  if (date != '') {
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(4, 6));
    int day = int.parse(date.substring(6, 8));
    final birthday = DateTime(year, month, day);
    final currentDate = DateTime.now();
    final difDate = currentDate.difference(birthday).inDays;

    if (difDate == 0) {
      result = 'วันนี้';
    } else if (difDate < 7) {
      result = '$difDate วันก่อน';
    } else if (difDate < 30) {
      result = '${(difDate / 7).round()} อาทิตย์ก่อน';
    } else if (difDate < 365) {
      result = '${(difDate / 30).round()} เดือนก่อน';
    } else {
      result = '${(difDate / 365).round()} ปีที่แล้ว';
    }
  }
  return result;
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

image64(param) {
  List<int> bytesList = base64.decode(param);
  return bytesList;
}

timeString(String time) {
  var hh = time.substring(0, 2);
  var mm = time.substring(3, 5);
  return '$hh.$mm';
}

formateDateTHShort(String date, {String type = ' '}) {
  String result = '';
  if (date != '') {
    String yearString = date.substring(0, 4);
    var yearInt = int.parse(yearString);
    var year = yearInt + 543;
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    var monthTH = "";
    if (month == "01") {
      monthTH = "ม.ค.";
    } else if (month == "02") {
      monthTH = "ก.พ.";
    } else if (month == "03") {
      monthTH = "มี.ค.";
    } else if (month == "04") {
      monthTH = "เม.ย.";
    } else if (month == "05") {
      monthTH = "พ.ค.";
    } else if (month == "06") {
      monthTH = "มิ.ย.";
    } else if (month == "07") {
      monthTH = "ก.ค.";
    } else if (month == "08") {
      monthTH = "ส.ค.";
    } else if (month == "09") {
      monthTH = "ก.ย.";
    } else if (month == "10") {
      monthTH = "ต.ค.";
    } else if (month == "11") {
      monthTH = "พ.ย.";
    } else if (month == "12") {
      monthTH = "ธ.ค.";
    }

    result = '$day$type$monthTH$type$year';
  }
  return result;
}

extension CustomEmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }
}

logD(dynamic model) {
  var logger = Logger(printer: PrettyPrinter());
  return logger.d(model);
}

logE(dynamic model) {
  var logger = Logger(printer: PrettyPrinter());
  return logger.e(model);
}

logWTF(dynamic model) {
  var logger = Logger(printer: PrettyPrinter());
  return logger.wtf(model);
}

// List<Identity> toListModel(List<dynamic> model) {
//   var list = new List<Identity>();
//   model.forEach((element) {
//     var m = new Identity();
//     m.code = element['code'] != null ? element['code'] : '';
//     m.title = element['title'] != null ? element['title'] : '';
//     m.description =
//         element['description'] != null ? element['description'] : '';
//     m.imageUrl = element['imageUrl'] != null ? element['imageUrl'] : '';
//     m.createBy = element['createBy'] != null ? element['createBy'] : '';
//     m.createDate = element['createDate'] != null ? element['createDate'] : '';
//     m.imageUrlCreateBy = element['imageUrlCreateBy'] != null ? element['imageUrlCreateBy'] : '';
//     list.add(m);
//   });

//   return list;
// }

// Identity toModel(dynamic model) {
//   var m = new Identity();
//   m.code = model['code'] != null ? model['code'] : '';
//   m.title = model['title'] != null ? model['title'] : '';
//   m.description = model['description'] != null ? model['description'] : '';
//   m.imageUrl = model['imageUrl'] != null ? model['imageUrl'] : '';
//   m.createBy = model['createBy'] != null ? model['createBy'] : '';
//   m.createDate = model['createDate'] != null ? model['createDate'] : '';
//   m.imageUrlCreateBy = model['imageUrlCreateBy'] != null ? model['imageUrlCreateBy'] : '';

//   return m;
// }

class ValidateForm {
  static const emptyText = '**ช่องนี้ไม่สามารถเว้นว่างได้';
  static empty(String value) {
    if (value.isEmpty) {
      return 'กรุณากรอกข้อมูล ';
    }

    if (value.length < 3) {
      return 'short ';
    } else {
      return null;
    }
  }

  static firstName(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static lastName(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static phone(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static email(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    if (!value.isValidEmail()) {
      return '**ตรวจสอบรูปแบบอีเมล';
    }
    // try {
    //   var s = value.split('.');
    //   List<String> dm = ['com', 'th', 'net', 'org', 'info', 'us'];
    //   if (!dm.any((e) => s[s.length - 1] == e)) {
    //     return '**ตรวจสอบรูปแบบอีเมลให้ถูกต้อง';
    //   }
    // } catch (e) {}
    return null;
  }

  static username(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static password(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    if (value.length < 6) {
      return '**รหัสผ่านต้องเป็นตัวอักษร a-z, A-Z, 0-9 หรืออักขระ ความยาวขั้นต่ำ 6 ตัวอักษร';
    }
    return null;
  }

  dateTimeToDateStringFormat(String param, {String type = '/'}) {
    DateTime date = DateTime.parse(param);
    String result = '';
    if (date != '') {
      result =
          date.day.toString() +
          type +
          date.month.toString() +
          type +
          date.year.toString();
    }

    return result;
  }

  static confirmPassword(String value, String password) {
    if (value.isEmpty) {
      return emptyText;
    }
    if (value != password) {
      return '**รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  static occupation(int value) {
    if (value == 0 || value == null) {
      return '**กรุณาเลือกอาชีพ';
    }
    return null;
  }

  static String idcard(String? value) {
    if (value!.isEmpty) {
      return 'กรุณากรอกเลขที่บัตรประชาชน.';
    }

    String pattern = r'(^[0-9]\d{12}$)';
    RegExp regex = RegExp(pattern);

    if (regex.hasMatch(value)) {
      if (value.length != 13) {
        return 'กรุณากรอกรูปแบบเลขบัตรประชาชนให้ถูกต้อง';
      } else {
        var sum = 0.0;
        for (var i = 0; i < 12; i++) {
          sum += double.parse(value[i]) * (13 - i);
        }
        if ((11 - (sum % 11)) % 10 != double.parse(value[12])) {
          return 'กรุณากรอกเลขบัตรประชาชนให้ถูกต้อง';
        } else {
          return '';
        }
      }
    }
    return 'กรุณากรอกรูปแบบเลขบัตรประชาชนให้ถูกต้อง';
  }
}

class InputFormatTemple {
  static username() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z.]')),
  ];
  static name() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z .]')),
  ];
  static password() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z@!#$%?*~^<>._.-]')),
    // LengthLimitingTextInputFormatter(20),
  ];
  static phone() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    LengthLimitingTextInputFormatter(10),
  ];

  static otp() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    LengthLimitingTextInputFormatter(1),
  ];
  static email() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z@!#$%?*~^<>._.-]')),
  ];
  static idcard() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    LengthLimitingTextInputFormatter(13),
  ];
  static laserid() => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]')),
    LengthLimitingTextInputFormatter(12),
  ];
}

const emptyText = '**ช่องนี้ไม่สามารถเว้นว่างได้';
