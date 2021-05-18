import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/RankInPage/Model/RankModel.dart';
import 'package:monito/Pages/RankInPage/SubPages/RankDetailPage.dart';
import 'package:monito/Pages/RankInPage/Widgets/RankListItem.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class RankInPage extends StatefulWidget {
  @override
  _RankInPageState createState() => _RankInPageState();
}

class _RankInPageState extends State<RankInPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  ScrollController _scrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isError = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isInit = false;
  bool _isLoading = false;
  List<RankModel> rankList = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, String>> popMenus = [
    {"key": "1", "value": "全て確認済み"}
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getRankInList();
      }
    });
    _init();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  _init() async {
    categories = await _databaseProvider.getAllCategories();
    _getRankInList();
  }

  _getRankInList() async {
    try {
      if (this._hasNextPage) {
        List<RankModel> lists = [];
        String url = Constants.URL + "api/rankin?p=" + _currentPage.toString();
        var response = await HttpHelper.authGet(context, null, url, {});
        if (mounted) {
          if (response != null) {
            var result = json.decode(response.body);
            if (result['result'] == "success") {
              _currentPage++;
              _hasNextPage = _currentPage <= result['data']['last_page'];
              for (var item in result['data']['data']) {
                item['category_name'] = categories.firstWhere((element) => element['cat_id'] == item['cat_id'].toString())['name'];
                lists.add(RankModel.fromJson(item));
              }
              if (!_isInit) {
                _isInit = true;
              }
              setState(() {
                rankList.addAll(lists);
              });
            } else {
              _errorHandler();
            }
          } else {
            _errorHandler();
          }
        }
      }
    } catch (error) {
      print("Error: $error");
      _errorHandler();
    }
  }

  _errorHandler() {
    if (mounted) {
      setState(() {
        _isError = true;
      });
    }
  }

  _popUpMenuClickHandler(String key) {
    switch (key) {
      case "1":
        _acknowledgeAll();
        break;
    }
  }

  _acknowledgeAll() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    String url = sprintf("%sapi/rankin/all/acknowledge", [Constants.URL]);
    var response = await HttpHelper.authPost(context, url, {}, {}, false);
    if (mounted) {
      if (response != null) {
        if (rankList.length > 0) {
          for (RankModel item in rankList) {
            item.acknowledged_at = "true";
          }
        }
      } else {
        Helper.showToast(LangHelper.FAILED, false);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("ランクイン履歴"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _popUpMenuClickHandler,
            itemBuilder: (context) {
              return popMenus.map((item) {
                return PopupMenuItem(
                  value: item['key'],
                  child: Text(item['value']),
                );
              }).toList();
            },
          )
        ],
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          color: Constants.BackgroundColor,
          child: Stack(
            children: [
              _isInit
                  ? rankList.length == 0
                      ? Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "該当データがありません。",
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Positioned.fill(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == rankList.length) {
                                return Container(
                                  height: _hasNextPage ? 40 : 0,
                                  child: _hasNextPage
                                      ? SpinKitDualRing(
                                          size: 15,
                                          lineWidth: 2,
                                          color: Colors.black,
                                        )
                                      : Container(),
                                );
                              }
                              return RankListItem(
                                  rankModel: rankList[index],
                                  onPressed: () {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: RankDetailPage(rankModel: rankList[index]), inheritTheme: true, curve: Curves.easeIn, ctx: context)).then((value) {
                                      setState(() {});
                                    });
                                  });
                            },
                            separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                            itemCount: rankList.length + 1,
                          ),
                        )
                  : Positioned.fill(
                      child: Container(color: Constants.BackgroundColor, child: Loading()),
                    ),
              _isLoading
                  ? Positioned.fill(
                      child: Container(color: Constants.BackgroundColor.withOpacity(0.3), child: Loading()),
                    )
                  : Container(),
              _isError
                  ? Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Center(
                          child: Text("エラー!", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
