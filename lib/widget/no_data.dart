import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key, this.title = ''});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      constraints: const BoxConstraints(maxHeight: 200),
      child: Text(
        title != '' ? title : 'ไม่พบข้อมูล',
        textAlign: TextAlign.center,
      ),
    );
  }
}
