// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'config.dart';

class PolicyWebPage extends StatefulWidget {
  const PolicyWebPage({super.key});

  @override
  _PolicyWebPageState createState() => _PolicyWebPageState();
}

class _PolicyWebPageState extends State<PolicyWebPage> {
  String faceScanUrl = "$serverUrl/privacy-policy/";
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 30,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(faceScanUrl)),
                //  URLRequest(url: Uri.parse(faceScanUrl)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    mediaPlaybackRequiresUserGesture: false,
                    // debuggingEnabled: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                androidOnPermissionRequest: (
                  InAppWebViewController controller,
                  String origin,
                  List<String> resources,
                ) async {
                  return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT,
                  );
                },
                onReceivedServerTrustAuthRequest: (
                  controller,
                  challenge,
                ) async {
                  return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context, false);
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(width: 1, color: const Color(0xFF707070)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x40F3D2FF),
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'ไม่ยอมรับการใช้งาน',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context, true);
              },
              child: Container(
                height: 45,
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
                  'ยอมรับการใช้งาน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
