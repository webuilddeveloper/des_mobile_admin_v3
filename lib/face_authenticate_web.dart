import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FaceAuthenticateWebPage extends StatefulWidget {
  const FaceAuthenticateWebPage({super.key, this.idCard, this.type});
  final String? idCard;
  final String? type;
  @override
  State<FaceAuthenticateWebPage> createState() =>
      _FaceAuthenticateWebPageState();
}

class _FaceAuthenticateWebPageState extends State<FaceAuthenticateWebPage> {
  String faceScanUrl = "";
  @override
  Widget build(BuildContext context) {
    if (widget.type == "checkIn") {
      faceScanUrl =
          "https://uis.dcc.bde.go.th/staff/check-in?id=${widget.idCard}&start=1";
    } else if (widget.type == "checkOut") {
      faceScanUrl =
          "https://uis.dcc.bde.go.th/staff/check-out?id=${widget.idCard}&start=1";
    }
    return InAppWebViewPage(scanFaceWeb: faceScanUrl);
  }
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({super.key, this.scanFaceWeb});
  final String? scanFaceWeb;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  @override
  Widget build(BuildContext context) {
    final scanFaceWeb = widget.scanFaceWeb;

    return Scaffold(
      body:
          scanFaceWeb == null || scanFaceWeb.isEmpty
              ? const Center(child: Text('ไม่พบลิงก์สำหรับสแกนใบหน้า'))
              : InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(scanFaceWeb)),
                initialSettings: InAppWebViewSettings(
                  mediaPlaybackRequiresUserGesture: false,
                  // debuggingEnabled: true,
                ),
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
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
    );
  }
}
