import 'dart:async';
import 'package:des_mobile_admin_v3/report_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class ReportDetailsPage extends StatefulWidget {
  ReportDetailsPage({super.key, this.model, this.mode});
  dynamic model;
  int? mode = 1;

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();

  // getState() => homeCentralPageState;
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  late DateTime currentBackPressTime;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  dynamic profile;
  String now = DateFormat('dd/MM/yyyy').format(DateTime.now());

  TextEditingController txtReport = TextEditingController();

  int selectedMenuIndex = 0;
  String selectProvince = "1";
  String selectDistrict = "1";
  String selectSubDistrict = "1";

  dynamic reportModel = {
    "problemListCount": 64,
    "inProgressCount": 30,
    "completeCount": 34,
  };

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
          title: Text(
            widget.mode == 2 ? 'รายการปัญหา' : 'ติดตามปัญหา',
            style: const TextStyle(
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(11)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF3D2FF).withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 12,
          left: 20,
          right: 25,
        ),
        width: double.infinity,
        // height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'หัวข้อปัญหา',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                widget.mode == 2
                    ? const SizedBox()
                    : Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7209B7),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/calendar.png",
                            fit: BoxFit.contain,
                            color: Colors.white,
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'วันที่คาดว่าจะเสร็จ\n13/04/2566',
                            style: TextStyle(fontSize: 8, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
            Text(
              // '${widget.model['title']}',
              '${widget.model['ticketName']}',
              // '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 40),
            const Text(
              'รายละเอียดปัญหา',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${model['description'] ?? "-"}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 40),
            const Text(
              'ภาพประกอบ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            // _buildImage(model['image']),
            const SizedBox(height: 40),
            widget.mode == 2
                ? Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/images/add.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        "assets/images/gallery.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Expanded(
                    //   flex: 7,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius:
                    //           const BorderRadius.all(Radius.circular(15)),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color:
                    //               const Color(0xFFF3D2FF).withOpacity(0.25),
                    //           blurRadius: 10,
                    //           offset: const Offset(0, 5),
                    //         )
                    //       ],
                    //     ),
                    //     child: Container(
                    //       constraints: const BoxConstraints(minHeight: 45),
                    //       width: double.infinity,
                    //       // height: 45,
                    //       decoration: const BoxDecoration(
                    //         color: Color(0xFFE4E5EB),
                    //         borderRadius:
                    //             BorderRadius.all(Radius.circular(28)),
                    //       ),
                    //       child: ConstrainedBox(
                    //         constraints: BoxConstraints(
                    //           maxHeight: MediaQuery.of(context)
                    //               .size
                    //               .height, //when it reach the max it will use scroll
                    //           maxWidth: MediaQuery.of(context).size.width,
                    //         ),
                    //         child: Row(
                    //           mainAxisAlignment:
                    //               MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Expanded(
                    //               child: TextField(
                    //                 maxLength: 120,
                    //                 keyboardType: TextInputType.multiline,
                    //                 maxLines: null,
                    //                 style: const TextStyle(
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.w400,
                    //                 ),
                    //                 controller: txtReport,
                    //                 // cursorHeight: double.infinity,
                    //                 maxLengthEnforcement: MaxLengthEnforcement
                    //                     .truncateAfterCompositionEnds,
                    //                 decoration: InputDecoration(
                    //                   counter: const SizedBox.shrink(),
                    //                   contentPadding: const EdgeInsets.only(
                    //                       left: 19, right: 15, top: 10),
                    //                   hintText: "ส่งข้อความที่นี่",
                    //                   labelStyle: const TextStyle(
                    //                       fontSize: 15, color: Colors.black),
                    //                   floatingLabelStyle: TextStyle(
                    //                       fontSize: 15,
                    //                       color:
                    //                           Colors.black.withOpacity(0.24)),
                    //                   enabledBorder:
                    //                       const UnderlineInputBorder(
                    //                     borderSide: BorderSide(
                    //                         color: Color(0xFFE4E5EB),
                    //                         width: 0,
                    //                         style: BorderStyle.none),
                    //                   ),
                    //                   focusedBorder:
                    //                       const UnderlineInputBorder(
                    //                     borderSide: BorderSide(
                    //                         color: Color(0xFFE4E5EB),
                    //                         width: 0,
                    //                         style: BorderStyle.none),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.all(5.0),
                    //               child: InkWell(
                    //                 onTap: () {
                    //                   txtReport.text = '';
                    //                 },
                    //                 child: Container(
                    //                   width: 45,
                    //                   height: 45,
                    //                   padding: const EdgeInsets.all(8),
                    //                   decoration: const BoxDecoration(
                    //                       shape: BoxShape.circle,
                    //                       color: Color(0xFF7209B7)),
                    //                   child: Image.asset(
                    //                     "assets/images/send_button.png",
                    //                     fit: BoxFit.contain,
                    //                   ),
                    //                 ),
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                )
                : const SizedBox(),
            const SizedBox(height: 40),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (contex) => ReportFormPage(model: model),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                // height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF7209B7),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SizedBox(
                  // height: 60,
                  child: Text(
                    widget.mode == 2 ? 'ถัดไป' : 'แก้ไข',
                    style: const TextStyle(
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
    );
  }

  Widget _buildImage(model) {
    // return SizedBox();
    return SizedBox(
      height: 80.0,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: model.length,
        // separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder:
            (_, index) => Container(
              // width: 74,
              width: MediaQuery.of(context).size.width / 4.5,
              height: 74,
              decoration: BoxDecoration(
                // color: Colors.amber,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                  image: AssetImage(model[index]['imageUrl'].toString() ?? ""),
                ),
              ),
            ),
      ),
    );
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
