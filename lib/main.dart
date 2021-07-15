import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/SplashPage/SplashPage.dart';
import 'package:package_info/package_info.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';
import 'Database/DatabaseProvider.dart';
import 'Helper/Helper.dart';
import 'Helper/SharePreferenceUtil.dart';
import 'Pages/MainPage/MainPage.dart';

bool isIOS;
bool isTest = false;
String APP_VERSION;
final currency = new NumberFormat("#,##0", "ja-JP");
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

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  bool timeout = task.timeout;
  if (timeout) {
    BackgroundFetch.finish(taskId);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isIOS = Platform.isIOS;
  deviceToken = "";
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  APP_VERSION = packageInfo.version;
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static SharePreferenceUtil shareUtils;
  static Locale kLocale = const Locale("ja", "jp");
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  Future<void> showNotification(String title, String body, String image, String type) async {
    if (isIOS) {
      IOSNotificationDetails iosNotificationDetails = new IOSNotificationDetails();
      NotificationDetails notificationDetails = new NotificationDetails(iOS: iosNotificationDetails);
      int notificationId = Helper.getRandomId();
      int expiredAt = DateTime.now().millisecondsSinceEpoch;
      _databaseProvider.insertNotification({'id': notificationId.toString(), 'expired_at': expiredAt});
      await flutterLocalNotificationsPlugin.show(notificationId, title, body, notificationDetails, payload: type);
    } else {
      final String largeIconPath = image == null ? null : await Helper.downloadAndSaveFile(image, 'largeIcon');
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        "default",
        "default",
        "default",
        priority: Priority.max,
        importance: Importance.high,
        icon: "icon",
        channelShowBadge: true,
        largeIcon: largeIconPath == null ? null : FilePathAndroidBitmap(largeIconPath),
      );
      int notificationId = Helper.getRandomId();
      int expiredAt = DateTime.now().millisecondsSinceEpoch;
      await _databaseProvider.insertNotification({'id': notificationId.toString(), 'expired_at': expiredAt});
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(notificationId, title, body, notificationDetails, payload: type);
    }
  }

  Future<dynamic> onSelectNotification(String payload) async {
    switch (payload) {
      case "subscription":
        if (navigatorKey != null) {
          Navigator.pushAndRemoveUntil(navigatorKey.currentContext, PageTransition(child: SplashPage(), type: PageTransitionType.fade), (route) => false);
        }
        break;
      case "rankin":
        if (await Helper.isSignIn()) {
          if (navigatorKey != null) {
            Navigator.pushAndRemoveUntil(navigatorKey.currentContext, PageTransition(child: MainPage(initPage: Constants.RankInPage), type: PageTransitionType.fade), (route) => false);
          }
        } else {
          if (navigatorKey != null) {
            Navigator.pushAndRemoveUntil(navigatorKey.currentContext, PageTransition(child: SplashPage(), type: PageTransitionType.fade), (route) => false);
          }
        }
        break;
      case "achieve":
        if (await Helper.isSignIn()) {
          if (navigatorKey != null) {
            Navigator.pushAndRemoveUntil(navigatorKey.currentContext, PageTransition(child: MainPage(initPage: Constants.ConditionPage), type: PageTransitionType.fade), (route) => false);
          }
        } else {
          if (navigatorKey != null) {
            Navigator.pushAndRemoveUntil(navigatorKey.currentContext, PageTransition(child: SplashPage(), type: PageTransitionType.fade), (route) => false);
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    androidInitializationSettings = AndroidInitializationSettings('icon');
    iosInitializationSettings = IOSInitializationSettings();
    initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    shareUtils = new SharePreferenceUtil();
    shareUtils.instance();
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) async {
      print("On Message");
      String title = "";
      String body = "";
      String image = "";
      String type = "";
      if (isIOS) {
        final notification = message['aps'];
        type = notification['alert']['type'];
        title = notification['alert']['title'];
        body = notification['alert']['body'];
      } else {
        final data = message['data'];
        title = data['title'];
        body = data['body'];
        type = data['type'];
        image = data['image'] != null && data['image'] != "" ? data['image'] : null;
      }
      showNotification(title, body, image, type);
    }, onLaunch: (Map<String, dynamic> message) async {
      String type = "";
      if (isIOS) {
        final notification = message['aps'];
        type = notification['alert']['type'];
      } else {
        final data = message['data'];
        type = data['type'];
      }
      switch (type) {
        case "rankin":
          MyApp.shareUtils.setString(Constants.JumpPageOnLaunch, "rankin");
          break;
        case "achieve":
          MyApp.shareUtils.setString(Constants.JumpPageOnLaunch, "achieve");
          break;
      }
    }, onResume: (Map<String, dynamic> message) async {
      print('OnResume');
      String type = "";
      if (isIOS) {
        final notification = message['aps'];
        type = notification['alert']['type'];
      } else {
        final data = message['data'];
        type = data['type'];
      }
      onSelectNotification(type);
    });
    if (Platform.isIOS) {
      firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    }
    firebaseMessaging.onTokenRefresh.listen((token) async {
      print("Firebase DeviceToken Refreshed. Token=$token");
      String oldToken = await MyApp.shareUtils.getString(Constants.DeviceToken);
      if (token != oldToken) {
        await MyApp.shareUtils.setString(Constants.DeviceToken, token);
        deviceToken = token;
        if (await Helper.isSignIn()) {
          String url = sprintf("%sapi/me?is_ios=%d&device_token=%s&save_token=%s", [Constants.URL, isIOS ? 1 : 0, token, isTest ? "0" : "1"]);
          await HttpHelper.authGet(context, null, url, {});
        }
      }
    });

    return MaterialApp(
      title: 'MONITO',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity, fontFamily: "NotoSansJP"),
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
