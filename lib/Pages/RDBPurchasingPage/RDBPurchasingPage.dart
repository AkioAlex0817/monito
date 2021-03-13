import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/RDBPurchasingPage/Model/RDBPurchasingModel.dart';
import 'package:monito/Pages/RDBPurchasingPage/Widgets/RDBPurchasingListItem.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:page_transition/page_transition.dart';

class RDBPurchasingPage extends StatefulWidget {
  @override
  _RDBPurchasingPageState createState() => _RDBPurchasingPageState();
}

class _RDBPurchasingPageState extends State<RDBPurchasingPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  ScrollController _scrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isError = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isInit = false;

  List<RDBPurchasingModel> rdbPurchasingList = [];
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getRDBPurchasingList();
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
    _getRDBPurchasingList();
  }

  _getRDBPurchasingList() async {
    try {
      if (this._hasNextPage) {
        List<RDBPurchasingModel> lists = [];
        String url = Constants.URL + "api/rdb/purchasing?=" + _currentPage.toString();
        var response = await HttpHelper.authGet(context, null, url, {});
        if (mounted) {
          if (response != null) {
            var result = json.decode(response.body);
            if (result['result'] == "success") {
              _currentPage++;
              _hasNextPage = _currentPage <= result['data']['last_page'];
              for (var item in result['data']['data']) {
                //item['category_name'] = categories.firstWhere((element) => element['cat_id'] == item['cat_id'].toString())['name'];
                item['category_name'] = '';
                lists.add(RDBPurchasingModel.fromJson(item));
              }
              if (!_isInit) {
                _isInit = true;
              }
              setState(() {
                rdbPurchasingList.addAll(lists);
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
        title: Text("仕入れ予定RDB"),
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          color: Constants.BackgroundColor,
          child: Stack(
            children: [
              _isInit
                  ? rdbPurchasingList.length == 0
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
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == rdbPurchasingList.length) {
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
                              return RDBPurchasingListItem(
                                  rdbPurchasingModel: rdbPurchasingList[index],
                                  onPressed: () {
                                    //Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: RDBPu(rankModel: rankList[index]), inheritTheme: true, curve: Curves.easeIn, ctx: context));
                                  });
                            },
                            separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                            itemCount: rdbPurchasingList.length + 1,
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
