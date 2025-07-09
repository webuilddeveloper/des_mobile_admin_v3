import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:des_mobile_admin_v3/shared/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'widget/input_decoration.dart';

// ignore: must_be_immutable
class OperationalSearchResultPage extends StatefulWidget {
  OperationalSearchResultPage({super.key, this.keySearch});
  String? keySearch;

  @override
  State<OperationalSearchResultPage> createState() =>
      _OperationalSearchResultPageState();
}

class _OperationalSearchResultPageState
    extends State<OperationalSearchResultPage>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late TextEditingController _searchController;
  late List<dynamic> _model;

  @override
  void initState() {
    _model = [];
    _searchController = TextEditingController(text: widget.keySearch ?? '');
    _callRead();
    super.initState();
  }

  _callRead() async {
    setState(() {
      _model = OperationalMockData().mockSearch(_searchController.text);
    });
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
          title: const Text(
            'ค้นหาข้อมูลการลา',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          physics: const ClampingScrollPhysics(),
          children: [
            _buildSearch(),
            const SizedBox(height: 10),
            const Text(
              'ผลการค้นหา',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              '${_searchController.text} พบ ${_model.length} รายการ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _model.isNotEmpty ? _buildItemList() : _buildNotFound(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildNotFound() {
    return Container(
      alignment: Alignment.center,
      child: const Text('ไม่พบข้อมูล'),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.all(10),
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
            child: TextField(
              keyboardType: TextInputType.number,
              controller: _searchController,
              style: const TextStyle(fontSize: 14),
              decoration: CusInpuDecoration.base(
                context,
                hintText: 'วันที่ต้องการค้นหา',
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            _callRead();
          },
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8.75),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Image.asset('assets/images/search.png'),
          ),
        )
      ],
    );
  }

  Widget _buildItemList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (_, __) => _buildItem(_model[__]),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _model.length,
    );
  }

  Widget _buildItem(dynamic data) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF7209B7),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Container(
              padding: const EdgeInsets.all(11),
              child: Image.asset(
                data['imageUrl'].toString(),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title']),
                Text(data['date']),
              ],
            ),
          ),
          const Text(
            'อนุมัติ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF03BA0A),
            ),
          )
        ],
      ),
    );
  }
}
