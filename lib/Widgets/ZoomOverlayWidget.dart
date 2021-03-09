
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:monito/Helper/Constants.dart';

import 'Loading.dart';

class ZoomOverlayWidget extends StatefulWidget {
  final String asin;

  ZoomOverlayWidget({Key key, this.asin}) : super(key: key);

  @override
  _ZoomOverlayWidgetState createState() => _ZoomOverlayWidgetState();
}

class _ZoomOverlayWidgetState extends State<ZoomOverlayWidget> {
  InAppWebViewController webViewController;
  bool _isLoading = true;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(border: Border.all(color: Colors.black, )),
      child: Stack(
        children: [
          _isError
              ? Positioned.fill(
                  child: Center(
                    child: Text("エラー", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                )
              : Positioned.fill(
                  child: InAppWebView(
                    initialUrl: Constants.KeepaURL + widget.asin,
                    initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(debuggingEnabled: true, cacheEnabled: true, )),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webViewController = controller;
                    },
                    onLoadError: (InAppWebViewController controller, String url, int code, String message) {
                      setState(() {
                        _isError = true;
                      });
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  ),
                ),
          _isLoading
              ? Positioned.fill(
                  child: Loading(),
                )
              : Container(),
        ],
      ),
    );
  }
}
