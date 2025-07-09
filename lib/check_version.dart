// ignore_for_file: must_be_immutable, non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'package:des_mobile_admin_v3/menu.dart';
import 'package:des_mobile_admin_v3/shared/link_url_out.dart';
import 'package:des_mobile_admin_v3/themes/colors.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'shared/secure_storage.dart';

class CheckVersionPage extends StatefulWidget {
  CheckVersionPage({super.key, this.model});
  late dynamic model;
  @override
  State<CheckVersionPage> createState() => _CheckVersionPageState();
}

class _CheckVersionPageState extends State<CheckVersionPage>
    with TickerProviderStateMixin {
  late final AnimationController _controllerAnimation = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(6, 0),
    end: const Offset(-2.2, 0),
  ).animate(
    CurvedAnimation(parent: _controllerAnimation, curve: Curves.elasticOut),
  );

  late final AnimationController _controllerAnimationDialog =
      AnimationController(duration: const Duration(seconds: 1), vsync: this)
        ..repeat(reverse: true);
  late final Animation<double> _animationDialog = CurvedAnimation(
    parent: _controllerAnimationDialog,
    curve: Curves.elasticOut,
    reverseCurve: Curves.elasticOut,
  );

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      _controllerAnimation.stop();
      _controllerAnimationDialog.stop();
    });
    Future.delayed(const Duration(seconds: 0), () {
      _dialog();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerAnimation.dispose();
    _controllerAnimationDialog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Theme.of(context).primaryColor.withOpacity(0.66),
          // constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  _update_later() async {
    _controllerAnimation.reverse();
    _controllerAnimationDialog.reverse();
    String accessToken = await ManageStorage.read('accessToken_122');
    Future.delayed(const Duration(milliseconds: 1020), () {
      Navigator.pop(context);
      if (accessToken.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Menupage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  _update_now() {
    _controllerAnimation.reverse();
    _controllerAnimationDialog.reverse();
    Future.delayed(const Duration(milliseconds: 800), () {
      launchURL(checkIfUrlContainPrefixHttp(widget.model['url']));
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      _controllerAnimation.forward();
      _controllerAnimationDialog.forward();
    });
  }

  String checkIfUrlContainPrefixHttp(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    } else {
      return 'http://$url';
    }
  }

  _dialog() {
    showGeneralDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: const Color.fromARGB(
        255,
        35,
        67,
        61,
      ).withOpacity(0.66), // space around dialog
      transitionDuration: const Duration(milliseconds: 800),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: _animationDialog,
          child: Dialog(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 14,
                    right: 24,
                    child: SlideTransition(
                      position: _offsetAnimation,
                      child: Image.asset(
                        'assets/images/logo_dialog_chk_version.png',
                        height: 100,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 400,
                        minHeight: 200,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      width: double.infinity,
                      height: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'มีอัพเดตใหม่',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.model['title']} (v${widget.model['version']})',
                            style: const TextStyle(
                              // color: ThemeColor.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.model['description']}',
                            style: TextStyle(
                              color: ThemeColor.grey70,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _update_now();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(45),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: <Color>[
                                          Theme.of(context).primaryColor,
                                          Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.8),
                                        ],
                                        tileMode: TileMode.mirror,
                                      ),
                                    ),
                                    child: const Text(
                                      'อัพเดทตอนนี้',
                                      style: TextStyle(
                                        fontSize: 20,
                                        // fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                widget.model['isForce']
                                    ? GestureDetector(
                                      onTap: () {
                                        _update_later();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: 15,
                                        ),
                                        child: Text(
                                          'ภายหลัง',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
      pageBuilder: (
        BuildContext context,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Container();
      },
    );
  }
}
