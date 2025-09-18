import 'dart:convert';
import 'dart:typed_data';
import 'package:des_mobile_admin_v3/shared/extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'config.dart';
import 'menu.dart';
import 'widget/cache_image.dart';
import 'package:flutter_face_api/flutter_face_api.dart' as regula;

class FaceAuthenticatePage extends StatefulWidget {
  const FaceAuthenticatePage({super.key, this.image});
  final dynamic image;

  @override
  State<FaceAuthenticatePage> createState() => _FaceAuthenticatePageState();
}

class _FaceAuthenticatePageState extends State<FaceAuthenticatePage> {
  dynamic _profileData;
  // face recognition start
  // var image1 = regula.MatchFacesImage();
  // var image2 = regula.MatchFacesImage();
  regula.MatchFacesImage? mfImage1;
  regula.MatchFacesImage? mfImage2;

  bool _loading = false;
  late bool _loadingSubmit;
  bool _success = true;

  @override
  void initState() {
    _loadingSubmit = false;
    matchFaces();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  matchFaces() async {
    setState(() => _loading = true);

    // ✅ ดึงภาพจาก widget.image และสร้าง MatchFacesImage (LIVE)

    final faceResponse = regula.FaceCaptureResponse.fromJson(
      json.decode(widget.image),
    );
    if (faceResponse!.image == null || faceResponse.image!.image.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final mfImage1 = regula.MatchFacesImage(
      faceResponse.image!.image,
      faceResponse.image!.imageType,
    );

    Dio dio = Dio();
    dynamic result;
    final response = await dio.post(
      '$serverUrl/dcc-api/m/register/read/adminAll',
      data: {},
    );
    debugPrint('-------------------');

    var data = response.data['objectData'];
    for (var i in data) {
      bool isCheck = false;

      // ✅ ดึงภาพจาก URL แล้วแปลงเป็น Uint8List
      Uint8List imageBytes = await networkImageToBytes(i['imageUrl']);
      print('===================>>> imageUrl');
      print(imageBytes);
      // ✅ สร้าง MatchFacesImage (PRINTED)
      final mfImage2 = regula.MatchFacesImage(
        imageBytes,
        regula.ImageType.PRINTED,
      );

      // ✅ เปรียบเทียบใบหน้า
      final request = regula.MatchFacesRequest([mfImage1, mfImage2]);
      final response = await regula.FaceSDK.instance.matchFaces(request);

      final split = await regula.FaceSDK.instance.splitComparedFaces(
        response.results,
        0.75,
      );

      if (split.matchedFaces.isNotEmpty) {
        final similarity = split.matchedFaces[0].similarity * 100;
        debugPrint('Similarity: $similarity');
        isCheck = similarity >= 95;
      }

      if (isCheck) {
        result = i;
        break;
      }
    }

    if (result != null) {
      setState(() {
        _profileData = result;
      });
    } else {
      setState(() {
        _success = false;
      });
    }

    setState(() => _loading = false);
  }

  Future<Uint8List> networkImageToBytes(String imageUrl) async {
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4FF),
      body: Center(
        child: Container(
          height: 490,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
          ),
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _success
                  ? _buildSuccess()
                  : _buildFail(),
        ),
      ),
    );
  }

  _buildSuccess() {
    return Column(
      children: [
        Text(
          'ยินดีต้อนรับ!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 23),
        ClipRRect(
          borderRadius: BorderRadius.circular(75),
          child: CachedImageWidget(
            imageUrl: _profileData['imageUrl'] ?? '',
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${_profileData['firstName'] ?? ''} ${_profileData['lastName'] ?? ''}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          'เวลาเข้างาน ${dateTimeThaiFormat(DateTime.now())}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Container(height: 1, color: const Color(0x1A7209B7)),
        const SizedBox(height: 15),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Image.asset(
        //       'assets/images/calendar.png',
        //       height: 20,
        //       width: 20,
        //     ),
        //     const SizedBox(width: 6),
        //     Expanded(
        //       child: Text(
        //         '${dateStringToDateStringFormatDot(_profileData['reserveDate'], type: '/')}',
        //         style: const TextStyle(
        //           fontSize: 13,
        //           fontWeight: FontWeight.w400,
        //         ),
        //       ),
        //     ),
        //     Image.asset(
        //       'assets/images/time.png',
        //       height: 20,
        //       width: 20,
        //     ),
        //     const SizedBox(width: 6),
        //     Text(
        //       '${_profileData['startTime']}  -  ${_profileData['endTime']}',
        //       style: const TextStyle(
        //         fontSize: 13,
        //         fontWeight: FontWeight.w400,
        //       ),
        //       textAlign: TextAlign.center,
        //     ),
        //   ],
        // ),
        const Expanded(child: SizedBox()),
        Stack(
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  _loadingSubmit = true;
                });
                try {
                  // await Dio().post(
                  //     '$serverUrl/dcc-api/m/reservation/delete',
                  //     data: {'code': _profileData['code']});
                  await Dio().post(
                    '$serverUrl/dcc-api/m/register/checkin/admin',
                    data: {'code': _profileData['code']},
                  );

                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Menupage()),
                  );
                } catch (e) {
                  setState(() {
                    _loadingSubmit = false;
                  });
                  Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาด');
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
                    ),
                  ],
                ),
                child: const Text(
                  'เสร็จสิ้น',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (_loadingSubmit)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  _buildFail() {
    return Column(
      children: [
        Image.asset('assets/images/not_found.png', height: 150, width: 150),
        Text(
          'ไม่พบข้อมูลของท่าน',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'โปรดลงทะเบียนเจ้าหน้าที่ก่อน \nเพื่อให้ท่านสามารถลงเวลาปฏิบัติงานได้',
          // 'โปรดลงทะเบียนสมาชิกก่อน เพื่อให้ท่าน\nสามารถเข้าใช้บริการศูนย์ดิจิทัลชุมชนได้',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () async {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const Menupage(),
              //   ),
              // );

              // setState(() {
              //   _loading = false;
              //   _loadingSubmit = false;
              //   matchFaces();
              // });

              Navigator.pop(context, "Again");
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
                  ),
                ],
              ),
              child: const Text(
                'สแกนใบหน้าอีกครั้ง',
                // 'ลงทะเบียนสมาชิก',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Menupage()),
              );
            },
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(7),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x40F3D2FF),
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'เข้าสู่หน้าหลัก',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
