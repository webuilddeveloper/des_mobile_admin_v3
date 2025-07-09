import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config.dart';
import 'shared/extension.dart';
import 'widget/input_decoration.dart';

class MemberEditPage extends StatefulWidget {
  const MemberEditPage({super.key, this.model});

  final dynamic model;

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  late TextEditingController _phoneController;
  late String _phoneStringValidate;
  late bool _loadingSubmit;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _loadingSubmit = false;
    _phoneController =
        TextEditingController(text: widget.model?['phone'] ?? '');
    _phoneStringValidate = '';
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  _save() async {
    try {
      setState(() => _loadingSubmit = true);
      logWTF('save');
      Response response = await Dio().post(
        '$serverUrl/dcc-api/m/register/member/update',
        data: {
          'code': widget.model['code'],
          'phone': _phoneController.text,
        },
      );
      setState(() => _loadingSubmit = false);
      Fluttertoast.showToast(msg: 'สำเร็จ');
      if (!mounted) return;
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loadingSubmit = false);
      logE(e);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
            'แก้ไขข้อมูลสมาชิก',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildFeild(
                    controller:
                        TextEditingController(text: widget.model['firstName']),
                    hint: 'ชื่อ',
                    keyboardType: TextInputType.number,
                    validateString: _phoneStringValidate,
                    inputFormatters: InputFormatTemple.phone(),
                    readOnly: true,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      var result = ValidateForm.phone(value!);
                      setState(() {
                        _phoneStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeild(
                    controller:
                        TextEditingController(text: widget.model['lastName']),
                    hint: 'นามสกุล',
                    keyboardType: TextInputType.number,
                    validateString: _phoneStringValidate,
                    inputFormatters: InputFormatTemple.phone(),
                    readOnly: true,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      var result = ValidateForm.phone(value!);
                      setState(() {
                        _phoneStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeild(
                    controller:
                        TextEditingController(text: widget.model['ageRange']),
                    hint: 'ช่วงอายุ',
                    keyboardType: TextInputType.number,
                    validateString: _phoneStringValidate,
                    inputFormatters: InputFormatTemple.phone(),
                    readOnly: true,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      var result = ValidateForm.phone(value!);
                      setState(() {
                        _phoneStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeild(
                    controller:
                        TextEditingController(text: widget.model['email']),
                    hint: 'E-mail',
                    keyboardType: TextInputType.number,
                    validateString: _phoneStringValidate,
                    inputFormatters: InputFormatTemple.phone(),
                    readOnly: true,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      var result = ValidateForm.phone(value!);
                      setState(() {
                        _phoneStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeild(
                    controller: _phoneController,
                    hint: 'หมายเลขโทรศัพท์',
                    keyboardType: TextInputType.number,
                    validateString: _phoneStringValidate,
                    inputFormatters: InputFormatTemple.phone(),
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      var result = ValidateForm.phone(value!);
                      setState(() {
                        _phoneStringValidate = result ?? '';
                      });
                      return result == null ? null : '';
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final form = _formKey.currentState;
                    if (form!.validate() && !_loadingSubmit) {
                      form.save();
                      _save();
                      try {} catch (e) {
                        setState(() => _loadingSubmit = false);
                        Fluttertoast.showToast(msg: 'error');
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x40F3D2FF),
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Text(
                          'บันทึก',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        if (_loadingSubmit)
                          const Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeild({
    Key? key,
    FocusNode? focusNode,
    required TextEditingController controller,
    String hint = '',
    bool readOnly = false,
    Function(String?)? validator,
    Function(String?)? onChanged,
    Function(String?)? onFieldSubmitted,
    Function()? onEditingComplete,
    String validateString = '',
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.only(top: 12),
              alignment: Alignment.centerLeft,
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
              child: TextFormField(
                key: key,
                focusNode: focusNode,
                readOnly: readOnly,
                onEditingComplete: () => onEditingComplete!(),
                controller: controller,
                keyboardType: keyboardType,
                onChanged: (val) => onChanged!(val),
                onFieldSubmitted: (val) => onFieldSubmitted!(val),
                style: const TextStyle(fontSize: 14),
                decoration: CusInpuDecoration.base(
                  context,
                  hintText: hint,
                ),
                inputFormatters: inputFormatters,
                validator: (String? value) => validator!(value),
              ),
            ),
            if (readOnly)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF909090).withOpacity(0.3),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              )
          ],
        ),
        if (validateString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 3),
            child: Text(
              validateString,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
              ),
            ),
          )
      ],
    );
  }
}
