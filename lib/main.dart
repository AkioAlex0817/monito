import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monito/Pages/SplashPage/SplashPage.dart';
import 'package:package_info/package_info.dart';

import 'Helper/SharePreferenceUtil.dart';

bool isIOS;
String APP_VERSION;
final currency = new NumberFormat("#,##0", "ja-JP");
bool isLogin = false;
String currentPlan = null; //null: unauth, free: freePlan, std: Standard Plan, pro: Pro Plan
int memberId = null;
String memberName = null;
String memberEmail = null;

int maxTracker = 1;
int maxDeals = 5;
int allowAchieveList = 0;
int allowWishList = 0;
int allowPurchasingList = 0;
int allowPurchasedList = 0;
bool allowRDB = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isIOS = Platform.isIOS;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  APP_VERSION = packageInfo.version;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static SharePreferenceUtil shareUtils;
  static Locale kLocale = const Locale("ja", "jp");

  @override
  Widget build(BuildContext context) {
    shareUtils = new SharePreferenceUtil();
    shareUtils.instance();
    return MaterialApp(
      title: 'MONITO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "NotoSansJP"),
      routes: <String, WidgetBuilder>{
        "/": (BuildContext context) => SplashPage(),
      },
      initialRoute: "/",
      builder: (BuildContext context, Widget child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(data: data.copyWith(textScaleFactor: 1), child: child);
      },
    );
  }
}
