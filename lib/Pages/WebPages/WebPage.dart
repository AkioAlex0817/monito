import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/WidgetHelper.dart';

class WebPage extends StatefulWidget {
  final String url;

  WebPage({Key key, this.url}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  InAppWebViewController webViewController;
  String title = "";
  int isHttps = 0; //0: loading, 1: https, 2:http
  int webPageStatus = WidgetHelper.WEB_PAGE_LOADING;

  @override
  Widget build(BuildContext context) {
//    ScreenUtil.init(
//      context,
//      width: 750,
//      height: 1334,
//      allowFontScaling: true,
//    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Constants.StatusBarColor,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            this.webPageStatus == WidgetHelper.WEB_PAGE_LOADED ? Icon(Icons.lock_outline, size: 20) : Container(),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () async {
            if (this.webViewController == null) {
              Navigator.pop(context, false);
            } else {
              if (await this.webViewController.canGoBack()) {
                await this.webViewController.goBack();
              } else {
                Navigator.pop(context, false);
              }
            }
          },
        ),
        actions: [
          this.webPageStatus == WidgetHelper.WEB_PAGE_LOADING ? CupertinoTheme(data: CupertinoTheme.of(context).copyWith(brightness: Brightness.dark), child: CupertinoActivityIndicator(radius: 10)) : Container(),
          SizedBox(
            width: 5,
          ),
          InkWell(
            child: Icon(Icons.close),
            onTap: () {
              Navigator.pop(context, false);
            },
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialUrl: widget.url,
                onWebViewCreated: (InAppWebViewController controller) {
                  this.webViewController = controller;
                },
                onLoadError: (InAppWebViewController controller, String url, int code, String message) {
                  setState(() {
                    this.webPageStatus = WidgetHelper.WEB_PAGE_ERROR;
                  });
                },
                onLoadStop: (InAppWebViewController controller, String url) async {
                  setState(() {
                    this.webPageStatus = WidgetHelper.WEB_PAGE_LOADED;
                  });
                },
                onLoadStart: (InAppWebViewController controller, String url) {
                  RegExp regExp = new RegExp(r"^(http:|https:)//([^/]+)/.+$", caseSensitive: false);
                  String domain = "laaf2020.com";
                  if (regExp.hasMatch(url)) {
                    RegExpMatch match = regExp.firstMatch(url);
                    this.isHttps = match[1].toString() == "https:" ? 1 : 2;
                    domain = match[2].toString();
                  }
                  setState(() {
                    this.webPageStatus = WidgetHelper.WEB_PAGE_LOADING;
                    title = domain;
                  });
                },
              ),
            ),
            //WidgetHelper.buildWebStateWidget(this.webPageStatus),
          ],
        ),
      ),
    );
  }
}
