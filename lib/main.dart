import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:monito/Pages/SplashPage/SplashPage.dart';
import 'package:package_info/package_info.dart';
import 'Helper/Helper.dart';
import 'Helper/SharePreferenceUtil.dart';

bool isIOS;
bool isTest = false;
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
String deviceToken = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isIOS = Platform.isIOS;
  deviceToken = "Test_device Token";
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  APP_VERSION = packageInfo.version;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static SharePreferenceUtil shareUtils;
  static Locale kLocale = const Locale("ja", "jp");
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  @override
  Widget build(BuildContext context) {
    androidInitializationSettings = AndroidInitializationSettings('icon');
    iosInitializationSettings = IOSInitializationSettings();
    initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    shareUtils = new SharePreferenceUtil();
    shareUtils.instance();
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) async {
      print(message);
      String title = "";
      String body = "";
      String image = "";
      if (isIOS) {
        final notification = message['aps'];
        title = notification['alert']['title'];
        body = notification['alert']['body'];
        image = message['image'] != null && message['image'] != "" ? message['image'] : null;
        IOSNotificationDetails iosNotificationDetails = new IOSNotificationDetails();
        NotificationDetails notificationDetails = new NotificationDetails(iOS: iosNotificationDetails);
        await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
      } else {
        final data = message['data'];
        title = data['title'];
        body = data['body'];
        image = data['image'] != null && data['image'] != "" ? data['image'] : null;
        final String largeIconPath = await Helper.downloadAndSaveFile(image, 'largeIcon');
        AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          "default",
          'default',
          'default',
          priority: Priority.max,
          importance: Importance.defaultImportance,
          icon: "icon",
          channelShowBadge: true,
          largeIcon: FilePathAndroidBitmap(largeIconPath),
        );
        NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
        flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
    }, onResume: (Map<String, dynamic> message) async {
      print(message);
    });
    if (isIOS) {
      firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    }

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
