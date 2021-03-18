import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/MainPage/MainPage.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  String landingDescription = "設定同期中。。。";

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Constants.BackgroundColor,
      body: Container(
        width: screenSize.width + screenSize.width * 0.4,
        child: Stack(
          children: <Widget>[
            //Image.asset(splash_bg, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, fit: BoxFit.cover),
            Positioned(
              top: -screenSize.width * 0.2,
              left: -screenSize.width * 0.2,
              child: Container(
                width: screenSize.width * 0.65,
                height: screenSize.width * 0.65,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            Positioned(
              top: screenSize.height * 0.2,
              left: screenSize.width / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/splash_icon.png",
                    width: screenSize.width * 0.5,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: screenSize.height * 0.2,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                alignment: Alignment.center,
                child: Text(
                  landingDescription,
                  style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: -screenSize.width * 0.2,
                    right: -screenSize.width * 0.2,
                    child: Container(
                      width: screenSize.width * 0.65,
                      height: screenSize.width * 0.65,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _init() async {
    deviceToken = await MyApp.firebaseMessaging.getToken();
    print("alex");
    print(deviceToken);
    Timer(Duration(seconds: 3), () => _nextPage());
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _init();
  }

  _initDB() async {
    setState(() {
      landingDescription = "初期化中です。。。";
    });
    await DatabaseProvider.db.createDatabase();
    //Refresh Category List
    String url = Constants.URL + "api/categories";
    var response = await HttpHelper.get(null, url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          for (var item in result['data']) {
            await _databaseProvider.insertOrUpdateCategory(item['cat_id'].toString(), item['name'], item['context_free_name']);
          }
        }
      }
    }
  }

  Future _nextPage() async {
    await _initDB();
    String token = await MyApp.shareUtils.getString(Constants.SharePreferencesKey);
    if (token == null || token == "") {
      isLogin = false;
      //reset user info
      Helper.setMemberInfo(null, null, null, null, 1, 5, 0, 0, 0, 0, false);
      Navigator.pushAndRemoveUntil(context, PageTransition(child: MainPage(), type: PageTransitionType.fade), (route) => false);
    } else {
      isLogin = true;
      //update user info
      setState(() {
        landingDescription = "ユーザ情報取り込み中。。。";
      });
      String url = sprintf("%sapi/me?is_ios=%d&device_token=%s&is_test=%s", [Constants.URL, isIOS ? 1 : 0, deviceToken, isTest ? "1" : "0"]);
      var response = await HttpHelper.authGet(context, null, url, {});
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            var data = result['data'];
            //init user limitation
            Helper.setMemberInfo(
              data['current_plan'],
              data['profile']['id'],
              data['profile']['name'],
              data['profile']['email'],
              data['limitation']['tracker'] is int ? data['limitation']['tracker'] : 0,
              data['limitation']['deals'] is int ? data['limitation']['deals'] : 0,
              data['limitation']['achievelist'] is int ? data['limitation']['achievelist'] : 0,
              data['limitation']['wishlist'] is int ? data['limitation']['wishlist'] : 0,
              data['limitation']['purchasinglist'] is int ? data['limitation']['purchasinglist'] : 0,
              data['limitation']['purchasedlist'] is int ? data['limitation']['purchasedlist'] : 0,
              data['limitation']['rdb'],
            );
            //sync suppliers name
            for (var item in data['suppliers']) {
              await _databaseProvider.insertOrUpdateSupplier(item['id'], item['name']);
            }
            //update user setting
            await _databaseProvider.insertOrUpdateSetting(memberId, data['user_settings']['keepa_api_key'], data['user_settings']['price_archive_percent'], data['user_settings']['track_ranking']);
          }
        }
        Navigator.pushAndRemoveUntil(context, PageTransition(child: MainPage(), type: PageTransitionType.fade), (route) => false);
      }
    }
  }
}
