import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/SettingPage/Model/Rank.dart';
import 'package:monito/Pages/SettingPage/Widgets/SettingListItem.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';

import 'SubPages/TrackCategorySetting.dart';

class OfflineSettingPage extends StatefulWidget {
  @override
  _OfflineSettingPageState createState() => _OfflineSettingPageState();
}

class _OfflineSettingPageState extends State<OfflineSettingPage> {
  bool _isLoading = false;
  int tracking = 0;
  List<Rank> ranks = [
    new Rank("", 0),
    new Rank("500", 1),
    new Rank("1000", 2),
    new Rank("1500", 3),
    new Rank("2000", 4),
    new Rank("2500", 5),
    new Rank("3000", 6),
  ];

  @override
  void initState() {
    super.initState();
    _getOfflineRank();
  }

  _getOfflineRank() async {
    setState(() {
      _isLoading = true;
    });
    int unAuthRanking = await MyApp.shareUtils.getInteger(Constants.UnAuthTrackRankingKey);
    if (unAuthRanking != null) {
      tracking = unAuthRanking;
    } else {
      tracking = 0;
    }
    setState(() {

    });
  }

  _saveRanking() async {
    await MyApp.shareUtils.setInteger(Constants.UnAuthTrackRankingKey, tracking);
    Helper.showToast(LangHelper.SUCCESS, true);
  }

  List<Widget> actionSheetButton() {
    List<Widget> result = [];
    for (Rank item in ranks) {
      if (item.value == 0) continue;
      result.add(CupertinoActionSheetAction(
        onPressed: () {
          setState(() {
            tracking = item.value;
          });
          _saveRanking();
          Navigator.pop(context);
        },
        child: Text(item.show),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final selectRankHandler = CupertinoActionSheet(
      actions: actionSheetButton(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("キャンセル"),
      ),
    );
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
                    showCupertinoModalPopup(context: context, builder: (BuildContext context) => selectRankHandler);
                  },
                  icon: Text(
                    ranks.firstWhere((element) => element.value == tracking).show,
                    style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
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
