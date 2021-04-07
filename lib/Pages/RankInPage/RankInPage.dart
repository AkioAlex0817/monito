import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/RankInPage/Model/RankModel.dart';
import 'package:monito/Pages/RankInPage/SubPages/RankDetailPage.dart';
import 'package:monito/Pages/RankInPage/Widgets/RankListItem.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';

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
  List<RankModel> rankList = [];
  List<Map<String, dynamic>> categories = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("ランクイン履歴"),
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
