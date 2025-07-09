import 'package:des_mobile_admin_v3/widget/cache_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'config.dart';
import 'news_detail.dart';
import 'shared/extension.dart';
import 'widget/shimmer_loading.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late int _limit;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  late List<dynamic> _model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFCF9FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Color(0xFFFCF9FF)),
          ),
          centerTitle: true,
          title: const Text(
            'ข่าวประชาสัมพันธ์',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          onRefresh: onRefresh,
          onLoading: _onLoading,
          child: FutureBuilder<List<dynamic>>(
            future: Future.value(_model),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (_, __) {
                    if (__ == 0) {
                      return _firstItem(snapshot.data![__]);
                    } else {
                      return _item(snapshot.data![__]);
                    }
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return ShimmerLoading(
                  isLoading: true,
                  child: Container(height: 200),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _firstItem(dynamic model) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewsDetailPage(model: model)),
          ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 4,
              color: Color(0x40F3D2FF),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: CachedImageWidget(
                imageUrl: model['imageUrl'],
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      GestureDetector(
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

  Widget _item(dynamic model) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewsDetailPage(model: model)),
          ),
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFDDDDDD),
                ),
                child: CachedImageWidget(
                  imageUrl: model['imageUrl'],
                  height: 80,
                  width: 110,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    height: 80,
                    width: 110,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFDDDDDD),
                    ),
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
                  Expanded(
                    child: Text(
                      model['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/calendar.png',
                        height: 20,
                        width: 20,
                        color: const Color(0xFFB3B3B3),
                      ),
                      const SizedBox(width: 2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _limit = 10;
    _model = [];
    _readNews();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _readNews() async {
    Dio dio = Dio();
    Response<dynamic> response;
    try {
      response = await dio.post(
        '$serverUrl/dcc-api/m/eventcalendar/read',
        data: {'skip': 0, 'limit': _limit},
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 'S') {
          setState(() {
            _model = response.data['objectData'];
          });
        }
      }
    } catch (e) {
      logE(e);
    }
  }

  void onRefresh() async {
    _readNews();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {});
    _readNews();
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
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
