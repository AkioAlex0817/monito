import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/LoginPage/LoginPage.dart';
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
      backgroundColor: Color.fromARGB(255, 57, 62, 70),
      body: Container(
        width: screenSize.width + screenSize.width * 0.4,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: screenSize.height * 0.15,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/app_launch_icon.png",
                    width: screenSize.width * 0.6,
                    fit: BoxFit.cover,
                  )
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
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _init() async {
    landingDescription = "設定同期中。。。";
    //MyApp.firebaseMessaging.deleteInstanceID();
    String newToken = await MyApp.firebaseMessaging.getToken();
    String oldToken = await MyApp.shareUtils.getString(Constants.DeviceToken);
    if (newToken != oldToken) {
      await MyApp.shareUtils.setString(Constants.DeviceToken, newToken);
    }
    deviceToken = newToken;
    Timer(Duration(seconds: 1), () => _nextPage());
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
    //Refresh Suppliers
    String supplier_url = Constants.URL + "api/suppliers";
    var supplier_response = await HttpHelper.get(null, supplier_url, {});
    if (mounted) {
      if (supplier_response != null) {
        var result = json.decode(supplier_response.body);
        if (result['result'] == "success") {
          for (var item in result['data']) {
            await _databaseProvider.insertOrUpdateSupplier(item['id'], item['name']);
          }
        }
      }
    }
  }

  Future _nextPage() async {
    await _initDB();
    String token = await MyApp.shareUtils.getString(Constants.SharePreferencesKey);
    if (token == null || token == "") {
      Navigator.pushAndRemoveUntil(context, PageTransition(child: LoginPage(), type: PageTransitionType.fade), (route) => false);
    } else {
      //update user info
      setState(() {
        landingDescription = "ユーザ情報取り込み中。。。";
      });
      String url = sprintf("%sapi/me?is_ios=%d&device_token=%s&save_token=%s", [Constants.URL, isIOS ? 1 : 0, deviceToken, isTest ? "0" : "1"]);
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
            //update user setting
            await _databaseProvider.insertOrUpdateSetting(data['profile']['id'], data['user_settings']['keepa_api_key'], data['user_settings']['price_archive_percent'], data['user_settings']['track_ranking'], data['user_settings']['low_ranking_range']);
          }
        }
        String type = await MyApp.shareUtils.getString(Constants.JumpPageOnLaunch);
        Widget result;
        if (type != null && type != "") {
          switch (type) {
            case "rankin":
              result = MainPage(initPage: Constants.RankInPage);
              break;
            case "achieve":
              result = MainPage(initPage: Constants.ConditionPage);
              break;
            default:
              result = MainPage();
              break;
          }
          await MyApp.shareUtils.setString(Constants.JumpPageOnLaunch, "");
        } else {
          result = MainPage();
        }
        Navigator.pushAndRemoveUntil(context, PageTransition(child: result, type: PageTransitionType.fade), (route) => false);
      }
    }
  }
}
