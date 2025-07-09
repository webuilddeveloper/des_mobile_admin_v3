import 'dart:async';
import 'dart:convert';

import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class ReportFormPage extends StatefulWidget {
  ReportFormPage({super.key, this.model, this.mode});
  dynamic model;
  int? mode = 1;

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();

  // getState() => homeCentralPageState;
}

class _ReportFormPageState extends State<ReportFormPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile;
  String now = DateFormat('dd-MM-yyyy').format(DateTime.now());

  TextEditingController txtUndertaker = TextEditingController();
  TextEditingController txtContactInformation = TextEditingController();
  String petitionType = '0';

  late String startDate = widget.model['startDate'] ?? '00';
  late String finishDate = widget.model['finishDate'] ?? '00';
  late String timeNew;

  List<dynamic> petitionTypeModel = [
    {"value": "0", "title": "ปัญหาการจากใช้งาน"},
    {"value": "1", "title": "อุปกรณ์ชำรุด หรือมีปัญหา"},
    {"value": "3", "title": "ระบบเครือข่ายมีปัญหา ใช้งานไม่ได้"},
    {"value": "4", "title": "อื่นๆ"},
  ];

  Future<dynamic>? get _futureProblemModel => Future.value(widget.model);

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
            'แก้ไขรายการปัญหา',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: FutureBuilder<dynamic>(
          future: _futureProblemModel,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const Center(child: Text('ไม่พบข้อมูล'));
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'ผู้ใช้งาน ${snapshot.data['memberId'] ?? "-"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: _buildProblemDetails(snapshot.data)),
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return Container();
            } else {
              return const Center(
                heightFactor: 15,
                child: CircularProgressIndicator(),
              );
            }
          },
          // ),
        ),
      ),
    );
  }

  Widget _buildProblemDetails(dynamic model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 25),
      width: double.infinity,
      // height: 60,
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(11)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'วันที่คาดว่าจะเสร็จ',
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        // setState(() {

                        // });
                        _selectDate(model['startDate']).then(
                          (value) => {
                            setState(() {
                              startDate = value;
                            }),
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 11),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(13),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF3D2FF).withOpacity(0.25),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 15,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(13)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  finishDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Image.asset(
                                  "assets/images/calendar.png",
                                  width: 23,
                                  height: 23,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'วันที่คาดว่าจะเสร็จ',
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        _selectDate(model['finishDate']).then(
                          (value) => {
                            setState(() {
                              finishDate = value;
                            }),
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 11),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(13),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF3D2FF).withOpacity(0.25),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 15,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(13)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  finishDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Image.asset(
                                  "assets/images/calendar.png",
                                  width: 23,
                                  height: 23,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'ผู้รับผิดชอบ',
            style: TextStyle(overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 8),
          labelTextFormField('ผู้รับผิดชอบ', txtUndertaker),
          const SizedBox(height: 17),
          const Text(
            'ข้อมูลการติดต่อ',
            style: TextStyle(overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 8),
          labelTextFormField('ข้อมูลการติดต่อ', txtContactInformation),
          const SizedBox(height: 17),
          const Text(
            'ประเภทคำร้อง',
            style: TextStyle(overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 8),
          DropdownCustom(petitionTypeModel, "ช่วงอายุ", (value) {
            setState(() {
              petitionType = value;
            });
          }, petitionType),
          const SizedBox(height: 40),
          Container(
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
                'บันทึก',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownCustom(
    List<dynamic> itemModel,
    String label,
    Function onChanged,
    String valueDropdown,
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
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        width: double.infinity,
        // height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: SizedBox(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: const Icon(
                Icons.expand_circle_down_outlined,
                color: Colors.black,
                size: 30,
              ),
              items:
                  itemModel.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem(
                      value: value['value'].toString(),
                      child: Text(
                        value['title'].toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) => onChanged(value),
              hint: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: valueDropdown,
            ),
          ),
        ),
      ),
    );
  }

  labelTextFormField(String hint, TextEditingController txtController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(13)),
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
        // height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(13)),
        ),
        child: SizedBox(
          child: TextFormField(
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            controller: txtController,
            decoration: InputDecoration(
              hintText: hint,
              // labelStyle: const TextStyle(color: Colors.black),
              floatingLabelStyle: TextStyle(
                color: Colors.black.withOpacity(0.24),
              ),
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

  _selectDate(String time) async {
    dynamic timeSplit = time.split('-');
    DateTime dateForm = DateTime.utc(
      int.parse(timeSplit[2]) - 543,
      int.parse(timeSplit[1]),
      int.parse(timeSplit[0]),
    );
    DateTime? newDate = await showDatePicker(
      context: context,
      currentDate: dateForm,
      firstDate: DateTime(2020),
      initialDate: dateForm,
      lastDate: DateTime(2050),
    );
    dynamic a = (DateFormat("dd-MM-yyyy").format(newDate!)).toString();

    final day = newDate.day.toString().padLeft(2, '0');
    final month = newDate.month.toString().padLeft(2, '0');
    return '$day-$month-${newDate.year + 543}';
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onRefresh() async {
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
