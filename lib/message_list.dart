import 'package:des_mobile_admin_v3/chat.dart';
import 'package:des_mobile_admin_v3/widget/tab_category.dart';
import 'package:dio/dio.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'menu.dart';
import 'widget/no_data.dart';

class MessageListPage extends StatefulWidget {
  MessageListPage({
    super.key,
    this.changePage,
  });
  late _MessageListState messageListState;
  Function? changePage;

  @override
  State<MessageListPage> createState() => _MessageListState();

  getState() => messageListState;
}

class _MessageListState extends State<MessageListPage> {
  final _controllerBuildCategory = ScrollController();
  String categorySelected = '';
  String categoryTitleSelected = '';
  Future<dynamic>? _futureModel;
  bool isSwitched = false;
  Dio dio = Dio();
  List<dynamic> model = [
    {'code': '0', 'title': 'ล่าสุด'},
    {'code': '1', 'title': 'ยังไม่อ่าน'},
    {'code': '2', 'title': 'ข้อความใหม่'},
    {'code': '3', 'title': 'แจ้งปัญหา'},
  ];
  List<dynamic> list = [
    {
      "code": "0012345",
      "title": "ส่งข้อความถึงคุณ",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
    },
    {
      "code": "0012345",
      "title": "ส่งข้อความถึงคุณ",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
    },
    {
      "code": "0012345",
      "title": "ส่งข้อความถึงคุณ",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
    },
  ];
  List<dynamic> list3 = [
    {
      "code": "0012345",
      "title":
          "แจ้งปัญหาคอมพิวเตอร์A3 ศูนย์ดิจิทัลสายไหม มีปัญหาไม่สามารถใช้งานได้",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
    },
    {
      "code": "0012345",
      "title":
          "แจ้งปัญหาคอมพิวเตอร์A3 ศูนย์ดิจิทัลสายไหม มีปัญหาไม่สามารถใช้งานได้",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
    },
    {
      "code": "0012345",
      "title":
          "แจ้งปัญหาคอมพิวเตอร์A3 ศูนย์ดิจิทัลสายไหม มีปัญหาไม่สามารถใช้งานได้",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
    },
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // _loading();
    _futureModel = Future.value([]);
    super.initState();
  }

  void _loading() async {
    _futureModel = Future.value([]);
    // if (categorySelected != '3') {
    //   _futureModel = Future.value(list);
    // } else {
    //   _futureModel = Future.value(list3);
    // }
    // await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: _buildAppBar(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            _buildSearch(),
            const SizedBox(height: 30),
            categorySelected != '3'
                ? _buildCategorySelected()
                : _buildCategorySelected3(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0XFFFCF9FF),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0X40F3D2FF),
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20, left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const Menupage(),
                    ),
                    (Route<dynamic> route) => false,
                  ),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'กล่องข้อความ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
                      print('${isSwitched}');
                    },
                    activeTrackColor: const Color(0x80E5BDFF),
                    activeColor: const Color(0xFF7209B7),
                  ),
                ),
                // const SizedBox(width: 30),
              ],
            ),
            const SizedBox(height: 10),
            CategorySelector(
              onChange: (String val, String valTitle) {
                setState(
                  () => {
                    categorySelected = val,
                    categoryTitleSelected = valTitle,
                  },
                );
                _loading();
              },
              model: model,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 41,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: const Color(0xFFFFFFFF),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  color: Color(0X40F3D2FF),
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'ค้นหาข้อความหรือชื่อผู้ใช้งาน',
              style: TextStyle(
                color: Color(0x617209B7),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'assets/images/search_message_list.png',
          width: 40,
          height: 40,
        ),
      ],
    );
  }

  Widget _buildRowCategory() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          categorySelected != '3' ? 'กล่องข้อความ' : 'รายการปัญหา',
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const Text(
          'ดูทั้งหมด',
          style: TextStyle(
            color: Color(0xFF7209B7),
            fontWeight: FontWeight.w400,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelected() {
    return Column(
      children: [
        _buildRowCategory(),
        const SizedBox(height: 10),
        FutureBuilder(
          future: _futureModel,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const NoDataWidget();
              } else {
                return FadingEdgeScrollView.fromScrollView(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return _buildContent(snapshot.data[index]);
                    },
                    shrinkWrap: true,
                    controller: _controllerBuildCategory,
                    physics: const ClampingScrollPhysics(), // 2nd
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Container(
                alignment: Alignment.center,
                height: 200,
                width: double.infinity,
                child: const Text(
                  'Network ขัดข้อง',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelected3() {
    return Column(
      children: [
        _buildRowCategory(),
        const SizedBox(height: 10),
        FutureBuilder(
          future: _futureModel,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const NoDataWidget();
              } else {
                return FadingEdgeScrollView.fromScrollView(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return _buildContent(snapshot.data[index]);
                    },
                    shrinkWrap: true,
                    controller: _controllerBuildCategory,
                    physics: const ClampingScrollPhysics(), // 2nd
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Container(
                alignment: Alignment.center,
                height: 200,
                width: double.infinity,
                child: const Text(
                  'Network ขัดข้อง',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildContent(dynamic model) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            code: model['code'],
            imageUrl: model['imageUrl'],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        margin: const EdgeInsets.only(bottom: 10),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7209B7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'สมาชิกหมายเลข ${model['code']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              margin: const EdgeInsets.only(left: 14),
              child: Text(
                model['title'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
//
}
