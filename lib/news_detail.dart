import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'config.dart';
import 'shared/extension.dart';
import 'widget/cache_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key, this.model});
  final dynamic model;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late dynamic model;
  List<String> _gallery = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFCF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFFFCF9FF)),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 30,
            width: 30,
            color: const Color(0xFFFCF9FF),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              'assets/images/arrow_back.png',
              width: 10,
              height: 18,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => _callShare(model),
              child: Container(
                height: 27,
                width: 27,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 0),
                      blurRadius: 3,
                      color: Color(0x40A579B5),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/share.png'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: CachedImageWidget(
              imageUrl: model['imageUrl'],
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            model['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset(
                'assets/images/calendar.png',
                height: 20,
                width: 20,
                color: const Color(0xFFB3B3B3),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  dateStringToDateStringFormat(model['createDate']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB3B3B3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          HtmlWidget(
            model['description'],
            onTapUrl: (url) => Future.value(true),
          ),
          if (_gallery.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'ภาพประกอบ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 98,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, __) => _itemGallery(_gallery[__]),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _gallery.length,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _itemGallery(model) {
    return GestureDetector(
      onTap: () => setState(() {}),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedImageWidget(
          imageUrl: model,
          height: 98,
          width: 98,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  void initState() {
    model = widget.model;
    _galleryRead();
    super.initState();
  }

  void _galleryRead() async {
    Response<dynamic> response;
    try {
      response = await Dio().post(
        '$serverUrl/dcc-api/m/eventcalendar/gallery/read',
        data: {'code': widget.model['code']},
      );
    } catch (ex) {
      throw Exception();
    }
    var result = response.data;
    List<String> listImage = [];
    result['objectData'].map((e) => listImage.add(e['imageUrl'])).toList();
    setState(() {
      _gallery = listImage;
    });
  }

  Future<void> _callShare(param) async {
    final title = 'DES ดิจิทัลชุมชน';
    final text = '''ขอเชิญชวนร่วม คลาสเรียน
${param['title']}
${parseHtmlString(param['description']).substring(0, 100)}...

ดูเพิ่มเติม: ${param['imageUrl']}
''';

    await Share.share(text, subject: title);
  }
}
