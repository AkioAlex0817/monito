import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/AchievePage/Model/AchieveModel.dart';
import 'package:monito/Pages/AchievePage/SubPages/AchieveDetailPage.dart';
import 'package:monito/Pages/AchievePage/Widgets/AchieveListItem.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:page_transition/page_transition.dart';

class AchievePage extends StatefulWidget {
  @override
  _AchievePageState createState() => _AchievePageState();
}

class _AchievePageState extends State<AchievePage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  ScrollController _scrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isError = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isInit = false;
  List<AchieveModel> achieveList = [];
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getAchieveList();
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
    _getAchieveList();
  }

  _getAchieveList() async {
    try {
      if (this._hasNextPage) {
        List<AchieveModel> lists = [];
        String url = Constants.URL + "api/achievelist?p=" + _currentPage.toString();
        var response = await HttpHelper.authGet(context, null, url, {});
        if (mounted) {
          if (response != null) {
            var result = json.decode(response.body);
            if (result['result'] == "success") {
              _currentPage++;
              _hasNextPage = _currentPage <= result['data']['last_page'];
              for (var item in result['data']['data']) {
                var category = categories.firstWhere((element) => element['cat_id'] == item['cat_id'].toString(), orElse: () => null);
                if (category != null) {
                  item['category_name'] = category['name'];
                } else {
                  item['category_name'] = "--";
                }
                lists.add(AchieveModel.fromJson(item));
              }
              if (!_isInit) {
                _isInit = true;
              }
              setState(() {
                achieveList.addAll(lists);
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
        title: Text("????????????"),
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              _isInit
                  ? achieveList.length == 0
                      ? Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "????????????????????????????????????",
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Positioned.fill(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == achieveList.length) {
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
                              return AchieveListItem(
                                  achieveModel: achieveList[index],
                                  onPressed: () {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: AchieveDetailPage(achieveModel: achieveList[index]), inheritTheme: true, curve: Curves.easeIn, ctx: context));
                                  });
                            },
                            separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                            itemCount: achieveList.length + 1,
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
                          child: Text("?????????!", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
