import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/SettingPage/Model/Rank.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';

class TrackRankingSetting extends StatefulWidget {
  @override
  _TrackRankingSettingState createState() => _TrackRankingSettingState();
}

class _TrackRankingSettingState extends State<TrackRankingSetting> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  bool _isError = false;
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Timer(Duration(milliseconds: Constants.TransitionTime), () => _getUserRankInfo());
  }

  _getUserRankInfo() async {
    if (isLogin) {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      String url = Constants.URL + "api/setting";
      var response = await HttpHelper.authGet(context, null, url, {});
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            await _databaseProvider.insertOrUpdateSetting(memberId, result['data']['keepa_api_key'], result['data']['price_archive_percent'], result['data']['track_ranking']);
            tracking = result['data']['track_ranking'];
            setState(() {
              _isLoading = false;
            });
          } else {
            _errorHandler();
          }
        } else {
          _errorHandler();
        }
      }
    } else {
      int unAuthRanking = await MyApp.shareUtils.getInteger(Constants.UnAuthTrackRankingKey);
      if (unAuthRanking != null) {
        tracking = unAuthRanking;
      } else {
        tracking = 0;
      }
      setState(() {});
    }
  }

  _errorHandler() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  _saveRanking() async {
    if (_isLoading) return;
    if (tracking == 0) return;
    if(isLogin){
      setState(() {
        _isLoading = true;
      });
      String url = Constants.URL + "api/setting/track_ranking";
      var response = await HttpHelper.authPost(context, url, {'value': tracking.toString()}, {}, false);
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            await _databaseProvider.updateUserSetting(memberId, {'track_ranking': tracking});
            Helper.showToast(LangHelper.SUCCESS, true);
          } else {
            Helper.showToast(LangHelper.FAILED, false);
          }
        } else {
          Helper.showToast(LangHelper.FAILED, false);
        }
        setState(() {
          _isError = false;
          _isLoading = false;
        });
      }
    }else{
      await MyApp.shareUtils.setInteger(Constants.UnAuthTrackRankingKey, tracking);
      Helper.showToast(LangHelper.SUCCESS, true);
    }
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
      appBar: AppBar(centerTitle: true, backgroundColor: Constants.StatusBarColor, title: Text("指定範囲", style: TextStyle(color: Colors.white)), actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            onPressed: tracking == 0
                ? null
                : () {
                    _saveRanking();
                  },
            color: Colors.amber,
            disabledColor: Colors.amber.withOpacity(0.2),
            child: Text(
              "保存",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ]),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              _isError
                  ? Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("エラー!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : Positioned.fill(
                      child: Column(
                        children: [
                          Material(
                            child: InkWell(
                              onTap: () {
                                showCupertinoModalPopup(context: context, builder: (BuildContext context) => selectRankHandler);
                              },
                              child: Container(
                                height: 50,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "指定範囲",
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ranks.firstWhere((element) => element.value == tracking).show,
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              _isLoading ? Positioned.fill(child: Loading()) : Container()
            ],
          ),
        ),
      ),
    );
  }
}
