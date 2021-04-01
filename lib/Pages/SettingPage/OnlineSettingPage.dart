import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/SettingPage/Model/LowRankingRange.dart';
import 'package:monito/Pages/SettingPage/Widgets/TrackArchivePercentDialog.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';

import 'Model/Rank.dart';
import 'SubPages/KeepaSetting.dart';
import 'SubPages/TrackCategorySetting.dart';
import 'Widgets/SettingListItem.dart';

class OnlineSettingPage extends StatefulWidget {
  @override
  _OnlineSettingPageState createState() => _OnlineSettingPageState();
}

class _OnlineSettingPageState extends State<OnlineSettingPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  bool _isLoading = false;
  bool _isError = false;
  bool _saveRankingLoading = false;
  bool _saveLowRankingRangeLoading = false;
  int lowRankingRange = 0;
  int achievePercent = 0;
  int tracking = 0;
  String keepaToken = "";
  List<String> selectedCategory = [];

  List<Rank> ranks = [
    new Rank("", 0),
    new Rank("500", 1),
    new Rank("1000", 2),
    new Rank("1500", 3),
    new Rank("2000", 4),
    new Rank("2500", 5),
    new Rank("3000", 6),
  ];

  List<LowRankingRange> rankingRanges = [
    new LowRankingRange("指定なし", 0),
  ];

  @override
  void initState() {
    super.initState();
    _initRankingRange();
    _getUserSetting();
  }

  _initRankingRange() {
    int price = 1000;
    while (price <= 100000) {
      rankingRanges.add(new LowRankingRange("$price以下", price));
      if (price < 10000) {
        price = price + 1000;
        continue;
      }

      if (price < 50000) {
        price = price + 5000;
        continue;
      }

      if (price <= 100000) {
        price = price + 10000;
      }
    }
  }

  _getUserSetting() async {
    if (_isLoading) return;
    try {
      setState(() {
        _isLoading = true;
      });
      String url = Constants.URL + "api/setting";
      var response = await HttpHelper.authGet(context, null, url, {});
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            await _databaseProvider.insertOrUpdateSetting(memberId, result['data']['keepa_api_key'], result['data']['price_archive_percent'], result['data']['track_ranking'], result['data']['low_ranking_range']);
            achievePercent = result['data']['price_archive_percent'];
            tracking = result['data']['track_ranking'];
            lowRankingRange = result['data']['low_ranking_range'];
            keepaToken = result['data']['keepa_api_key'] == null ? "" : result['data']['keepa_api_key'];
            for (var item in result['data']['track_categories']) {
              selectedCategory.add(item);
            }
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
    } catch (error) {
      _errorHandler();
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
    if (_saveRankingLoading) return;
    if (tracking == 0) return;
    setState(() {
      _saveRankingLoading = true;
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
        _saveRankingLoading = false;
      });
    }
  }

  _saveLowRankingRange() async {
    if (_saveLowRankingRangeLoading) return;
    setState(() {
      _saveLowRankingRangeLoading = true;
    });

    String url = Constants.URL + "api/setting/low_ranking_range";
    var response = await HttpHelper.authPost(context, url, {'value': lowRankingRange.toString()}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          await _databaseProvider.updateUserSetting(memberId, {'low_ranking_range': lowRankingRange});
          Helper.showToast(LangHelper.SUCCESS, true);
        } else {
          Helper.showToast(LangHelper.FAILED, false);
        }
      } else {
        Helper.showToast(LangHelper.FAILED, false);
      }
      setState(() {
        _saveLowRankingRangeLoading = false;
      });
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
          _saveRanking();
          Navigator.pop(context);
        },
        child: Text(item.show),
      ));
    }
    return result;
  }

  List<Widget> lowRankingRangeSheetButton() {
    List<Widget> result = [];
    for (LowRankingRange item in rankingRanges) {
      result.add(InkWell(
        onTap: () {
          setState(() {
            lowRankingRange = item.value;
          });
          _saveLowRankingRange();
          Navigator.pop(context);
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
          child: Text(item.show, style: TextStyle(color: Colors.blue, fontSize: 15)),
        ),
      ));
    }
    List<Widget> res = [];
    res.add(Material(
      child: SizedBox(
        height: 350,
        child: SingleChildScrollView(
          child: Column(
            children: result,
          ),
        ),
      ),
    ));
    return res;
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
    final selectLowRankingRangeHandler = CupertinoActionSheet(
      actions: lowRankingRangeSheetButton(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("キャンセル", style: TextStyle(color: Colors.blue, fontSize: 15)),
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SettingListItem(
                              menuTitle: "Keepa設定",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      child: KeepaSetting(
                                        keepaApiKey: keepaToken,
                                      ),
                                      type: PageTransitionType.rightToLeft,
                                      duration: Duration(milliseconds: Constants.TransitionTime),
                                      reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                                      curve: Curves.easeIn,
                                      ctx: context,
                                      inheritTheme: true),
                                ).then((value) {
                                  if (mounted) {
                                    if (value != null && value != "") {
                                      setState(() {
                                        this.keepaToken = value;
                                      });
                                    }
                                  }
                                });
                              },
                              icon: SizedBox(
                                width: 100,
                                child: Text(
                                  keepaToken == "" ? "未設定" : keepaToken,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SettingListItem(
                              menuTitle: "カテゴリ",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      child: TrackCategorySetting(), type: PageTransitionType.rightToLeft, duration: Duration(milliseconds: Constants.TransitionTime), reverseDuration: Duration(milliseconds: Constants.TransitionTime), curve: Curves.easeIn, ctx: context, inheritTheme: true),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  }
                                });
                              },
                              icon: Text(
                                selectedCategory.length == 0 ? "未設定" : "${selectedCategory.length}件",
                                style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SettingListItem(
                              menuTitle: "指定範囲",
                              onPressed: () {
                                showCupertinoModalPopup(context: context, builder: (BuildContext context) => selectRankHandler);
                              },
                              icon: _saveRankingLoading
                                  ? SpinKitDualRing(color: Colors.black, size: 20, lineWidth: 2)
                                  : Text(
                                      ranks.firstWhere((element) => element.value == tracking).show,
                                      style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            SettingListItem(
                              menuTitle: "下位ランキング範囲",
                              onPressed: () {
                                showCupertinoModalPopup(context: context, builder: (BuildContext context) => selectLowRankingRangeHandler);
                              },
                              icon: _saveLowRankingRangeLoading
                                  ? SpinKitDualRing(color: Colors.black, size: 20, lineWidth: 2)
                                  : Text(
                                      rankingRanges.firstWhere((element) => element.value == lowRankingRange).show,
                                      style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            SettingListItem(
                              menuTitle: "上昇率(%)",
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => TrackArchivePercentDialog(
                                    archivePercent: achievePercent,
                                  ),
                                ).then((percent) async {
                                  if (percent != null) {
                                    setState(() {
                                      achievePercent = int.parse(percent);
                                    });
                                    await _databaseProvider.updateUserSetting(memberId, {'price_archive_percent': int.parse(percent)});
                                  }
                                });
                              },
                              icon: Text(
                                achievePercent.toString() + "%",
                                style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
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
              _isLoading
                  ? Positioned.fill(
                      child: Loading(
                      opacity: 1,
                      background: Colors.white,
                    ))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
