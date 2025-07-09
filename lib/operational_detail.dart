import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OperationalDetailPage extends StatefulWidget {
  OperationalDetailPage({super.key, this.title, required this.model});
  String? title;
  dynamic model;

  @override
  State<OperationalDetailPage> createState() => _OperationalDetailPageState();
}

class _OperationalDetailPageState extends State<OperationalDetailPage> {
  late dynamic _model;

  @override
  void initState() {
    _model = widget.model;
    _callRead();
    super.initState();
  }

  _callRead() async {
    // Dio dio = Dio();
    // var response = await dio.post(
    //     '$serverUrl/dcc-api/m/register/read/admin',
    //     data: {'code': _profileData['code']});
    // return Future.value(response.data['objectData']);
  }

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
          // backgroundColor: Color(0xFF9A1120),
          centerTitle: true,
          title: Text(
            'ข้อมูลการ${widget.title}',
            style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const ClampingScrollPhysics(),
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ข้อมูลการลากิจปีนี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7209B7),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(11),
                          child: Image.asset(
                            _model['imageUrl'].toString(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'จำนวนการลา',
                            style: TextStyle(
                              color: Color(0xFF767676),
                            ),
                          ),
                          Text(
                            '${_model['count']} วัน',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFF767676).withOpacity(0.6),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'จำนวนการลาคงเหลือ',
                            style: TextStyle(
                              color: Color(0xFF767676),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${_model['remaining']} วัน',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ประวัติการ${widget.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildItemList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (_, __) => _buildItem(_model['list'][__]),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _model['list'].length,
    );
  }

  Widget _buildItem(dynamic data) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['date']),
                    Text('หมายเหตุ : ${data['remark']}'),
                  ],
                ),
              ),
              Text(
                data['isActive'] ? 'อนุมัติ' : 'ไม่อนุมัติ',
                style: TextStyle(
                  fontSize: 12,
                  color: data['isActive']
                      ? const Color(0xFF03BA0A)
                      : const Color(0xFFD84130),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey,
        ),
      ],
    );
  }
}
