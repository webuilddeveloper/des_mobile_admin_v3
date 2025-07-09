import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:des_mobile_admin_v3/widget/input_decoration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ChatPage extends StatefulWidget {
  ChatPage({
    Key? key,
    required this.code,
    required this.imageUrl,
  }) : super(key: key);
  String code;
  String imageUrl;

  @override
  State<ChatPage> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  final ScrollController _controllerBuildCategory = ScrollController();
  String categorySelected = '';
  String categoryTitleSelected = '';
  Future<dynamic>? _futureModel;
  TextEditingController txtController = TextEditingController();
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
      "title":
          "Lorem ipsum dolor sit amet consectetur. Eget tempor tincidunt ac maecenas mollis purus. Quisque aenean facilisi tempor porttitor.",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
      "type": "user",
    },
    {
      "code": "0012345",
      "title":
          "Lorem ipsum dolor sit amet consectetur. Eget tempor tincidunt ac maecenas mollis purus.",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/e731/1161/efb903a0d84c804da3ec736cde54eb51?Expires=1682899200&Signature=OX5aMBAYSDT0lGEFDD1XRzuKkkbjAP54ivMdILBkJcSikx7UKbaRBO7D0ZBFZRBy1wA1-xncnlUYUQ-KkYOjwSkHD4R4rg2NB29wMlhFSNa3Q7m-tfCzF7ppIPLVI~UNiZz6AXNFK5RwB20ic7tSjDfk8TTK9XfdFA~WaBhkQTc3-14QSRXqGjvQi4IzgA4TKn4LTYal7TJCbeTi2Jorey6zs5K6-SE8znK-Uh4t4EKcIq3eiApqkaBUeLyqyVOElsczlr4tUBjWZmaACd4Z2lpZ4dEx8lltozv0AF0UwShHTAdF3HYvHjoVQx9s3vd6Wn4Zxjqh6iqLhKqgLwkf4g__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
      "type": "user",
    },
    {
      "code": "0000000",
      "title":
          "Lorem ipsum dolor sit amet consectetur. Eget tempor tincidunt ac maecenas mollis purus.",
      "imageUrl":
          "https://s3-alpha-sig.figma.com/img/7e09/40ad/727a110143f942c98cf73fe59b878d49?Expires=1683504000&Signature=qs9f8O0NiixdWt7UTp3~BERPqIHleFzYumi6TTAOdMWUAqimjt0W4P7HcP~qSdXYOoCCjAIpTU-N~JA0Z4gcy8f1j618pMvBY-~3siuI5z0vB5eulP-YuCLvM2Uk~lyP3L1t5G9yODsr4ozrYnzJq1N2vTyBZoURdDYmqYWai7thYAyyIG9b-m-6xA658r35SYYAS9BPg~ishJsEXfZvPeVVlp6gwT52fUkPhyK6~N-0~m58fvXAttaTPmT7p6dKn2fzdgaDuwaC2AJf52Zh9AJ3rt3jQG7IQuKUZwIymg-tvTIvf4i9eyFiY2TlyqOjMlNYK~aKLbhNZ-PwoG9Y8Q__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
      "type": "admin",
    },
  ];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    txtController = TextEditingController(text: '');
    _loading();
    super.initState();
  }

  void _loading() async {
    _futureModel = Future.value(list);
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _MaxScroll() {
    return SchedulerBinding.instance.addPostFrameCallback((_) {
      _controllerBuildCategory.animateTo(
        _controllerBuildCategory.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    });
  }

  void addChat() async {
    if (txtController.text != '') {
      setState(() {
        list.add({
          "code": '0000000',
          "title": txtController.text,
          "imageUrl":
              "https://s3-alpha-sig.figma.com/img/7e09/40ad/727a110143f942c98cf73fe59b878d49?Expires=1683504000&Signature=qs9f8O0NiixdWt7UTp3~BERPqIHleFzYumi6TTAOdMWUAqimjt0W4P7HcP~qSdXYOoCCjAIpTU-N~JA0Z4gcy8f1j618pMvBY-~3siuI5z0vB5eulP-YuCLvM2Uk~lyP3L1t5G9yODsr4ozrYnzJq1N2vTyBZoURdDYmqYWai7thYAyyIG9b-m-6xA658r35SYYAS9BPg~ishJsEXfZvPeVVlp6gwT52fUkPhyK6~N-0~m58fvXAttaTPmT7p6dKn2fzdgaDuwaC2AJf52Zh9AJ3rt3jQG7IQuKUZwIymg-tvTIvf4i9eyFiY2TlyqOjMlNYK~aKLbhNZ-PwoG9Y8Q__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
          "type": "admin",
        });
      });
      _loading();
      FocusScope.of(context).requestFocus(FocusNode());
      _MaxScroll();
    } else {
      print('flase ${txtController.text}');
    }
    setState(() {
      txtController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9FF),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(105),
        child: _buildAppBar(),
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 21, right: 21, bottom: 10),
                child: _build(),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
        // child: Stack(
        //   children: [
        //     Positioned.fill(
        //       child: Container(
        //         color: Colors.red,
        //         child: ListView(
        //           // reverse: true,
        //           padding:
        //               const EdgeInsets.only(left: 21, right: 21, bottom: 120),
        //           children: [
        //             Container(
        //               color: Colors.yellow,
        //               child: _build(),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Positioned(
        //         bottom: 0, left: 0, right: 0, child: _buildBottomNavBar()),
        //   ],
        // ),
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
            top: MediaQuery.of(context).padding.top, left: 11, right: 21),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'กล่องข้อความ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'สมาชิก ${widget.code}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedImageWidget(
                imageUrl: widget.imageUrl,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x40F3D2FF),
            blurRadius: 4,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/add_chat.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 15),
          Image.asset(
            'assets/images/gallery_chat.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 17),
          Expanded(
            child: labelTextFormField(),
          ),
        ],
      ),
    );
  }

  Widget labelTextFormField() {
    return Container(
      // alignment: Alignment.center,
      // padding: const EdgeInsets.symmetric(vertical: 10),
      // height: 37,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E5EB),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              style: const TextStyle(
                color: Color(0x7D000000),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              controller: txtController,
              decoration: ChatInputDecoration.base(
                context,
                hintText: 'ส่งข้อความที่นี่',
              ),
              onTap: () => _MaxScroll(),
            ),
          ),
          InkWell(
            onTap: () {
              addChat();
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'assets/images/send_chat.png',
                width: 31,
                height: 31,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build() {
    return FutureBuilder(
      future: _futureModel,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: (MediaQuery.of(context).size.width),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ไม่พบข้อมูล',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF707070).withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                if (snapshot.data[index]['type'] == 'admin') {
                  return _buildAdminContent(snapshot.data[index]);
                }
                {
                  return _buildContent(snapshot.data[index]);
                }
              },
              shrinkWrap: true,
              controller: _controllerBuildCategory,
              physics: const ClampingScrollPhysics(), // 2nd
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
    );
  }

  Widget _buildContent(model) {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedImageWidget(
              imageUrl: model['imageUrl'],
              height: 30,
              width: 30,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 210,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
              decoration: const BoxDecoration(
                color: Color(0xFFFBE8FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                '${model['title']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminContent(model) {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 210,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
              decoration: const BoxDecoration(
                color: Color(0xFFE4EDFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Text(
                '${model['title']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedImageWidget(
              imageUrl: model['imageUrl'],
              height: 30,
              width: 30,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
//
}
