import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  await Permission.microphone.request();

  runApp(FaceAuthenticateWebPage());
}

class FaceAuthenticateWebPage extends StatefulWidget {
  const FaceAuthenticateWebPage({super.key, this.idCard, this.type});
  final String? idCard;
  final String? type;
  @override
  _FaceAuthenticateWebPageState createState() =>
      new _FaceAuthenticateWebPageState();
}

class _FaceAuthenticateWebPageState extends State<FaceAuthenticateWebPage> {
  String faceScanUrl = "";
  @override
  Widget build(BuildContext context) {
    if (widget.type == "checkIn") {
      faceScanUrl =
          "https://uis.dcc.onde.go.th/staff/check-in?id=${widget.idCard}&start=1";
    } else if (widget.type == "checkOut") {
      faceScanUrl =
          "https://uis.dcc.onde.go.th/staff/check-out?id=${widget.idCard}&start=1";
    }
    return MaterialApp(home: InAppWebViewPage(scanFaceWeb: faceScanUrl));
  }
}

class InAppWebViewPage extends StatefulWidget {
  InAppWebViewPage({this.scanFaceWeb});
  String? scanFaceWeb;

  @override
  _InAppWebViewPageState createState() =>
      new _InAppWebViewPageState(scanFaceWeb: scanFaceWeb);
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  _InAppWebViewPageState({this.scanFaceWeb});
  String? scanFaceWeb;
  late InAppWebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(scanFaceWeb!)),
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
            ),
          ],
        ),
      ),
    );
  }
}
