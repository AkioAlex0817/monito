import 'package:flutter/material.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Pages/SettingPage/SubPages/KeepaSetting.dart';
import 'package:monito/Pages/SettingPage/SubPages/SuppliersSetting.dart';
import 'package:monito/Pages/SettingPage/SubPages/TrackCategorySetting.dart';
import 'package:monito/Pages/SettingPage/SubPages/TrackRankingSetting.dart';
import 'package:monito/Pages/SettingPage/Widgets/SettingListItem.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';

import 'SubPages/TrackAchievePercentSetting.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("設定", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                isLogin
                    ? SettingListItem(
                        menuTitle: "Keepa設定",
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                child: KeepaSetting(),
                                type: PageTransitionType.rightToLeft,
                                duration: Duration(milliseconds: Constants.TransitionTime),
                                reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                                curve: Curves.easeIn,
                                ctx: context,
                                inheritTheme: true,
                              ));
                        },
                      )
                    : Container(),
                SettingListItem(
                  menuTitle: "カテゴリ",
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                          child: TrackCategorySetting(),
                          type: PageTransitionType.rightToLeft,
                          duration: Duration(milliseconds: Constants.TransitionTime),
                          reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                          curve: Curves.easeIn,
                          ctx: context,
                          inheritTheme: true,
                        ));
                  },
                ),
                SettingListItem(
                  menuTitle: "指定範囲",
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                          child: TrackRankingSetting(),
                          type: PageTransitionType.rightToLeft,
                          duration: Duration(milliseconds: Constants.TransitionTime),
                          reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                          curve: Curves.easeIn,
                          ctx: context,
                          inheritTheme: true,
                        ));
                  },
                ),
                isLogin
                    ? SettingListItem(
                        menuTitle: "上昇率",
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                child: TrackAchievePercentSetting(),
                                type: PageTransitionType.rightToLeft,
                                duration: Duration(milliseconds: Constants.TransitionTime),
                                reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                                curve: Curves.easeIn,
                                ctx: context,
                                inheritTheme: true,
                              ));
                        },
                      )
                    : Container(),
                isLogin
                    ? SettingListItem(
                        menuTitle: "仕入れ先リスト",
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                child: SuppliersSetting(),
                                type: PageTransitionType.rightToLeft,
                                duration: Duration(milliseconds: Constants.TransitionTime),
                                reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                                curve: Curves.easeIn,
                                ctx: context,
                                inheritTheme: true,
                              ));
                        })
                    : Container(),
                SettingListItem(
                  menuTitle: "アプリ情報",
                  icon: Text(
                    "(v${APP_VERSION})",
                    style: TextStyle(color: Colors.redAccent.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
