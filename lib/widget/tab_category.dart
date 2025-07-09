import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({
    super.key,
    required this.onChange,
    this.path = '',
    this.code = '',
    this.model,
  });
  final Function(String, String) onChange;
  final String code;
  final String path;
  final dynamic model;

  @override
  CategorySelectorState createState() => CategorySelectorState();
}

class CategorySelectorState extends State<CategorySelector> {
  dynamic res;
  String selectedIndex = '';
  String selectedTitleIndex = '';

  @override
  void initState() {
    if (widget.model != null) {
      selectedIndex = '0';
      res = Future.value(widget.model);
    } else {
      // res = postDioCategoryWeMart(widget.path, {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: res, // function where you call your api\
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: snapshot.data
                .map<Widget>(
                  (c) => GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      widget.onChange(c['code'], c['title']);
                      setState(() {
                        selectedIndex = c['code'];
                        selectedTitleIndex = c['title'];
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Column(
                        children: [
                          Text(
                            c['title'],
                            style: TextStyle(
                              color: c['code'] == selectedIndex
                                  ? const Color(0xFF7209B7)
                                  : const Color(0x4F000000),
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1.2,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          c['code'] == selectedIndex
                              ? Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7209B7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        } else {
          return Container(
            height: 25.0,
            // padding: EdgeInsets.only(left: 5.0, right: 5.0),
            // margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
