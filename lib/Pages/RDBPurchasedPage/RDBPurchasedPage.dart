import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/RDBPurchasedPage/Model/RDBPurchasedModel.dart';
import 'package:monito/Pages/RDBPurchasedPage/SubPages/RDBPurchasedDetailPage.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

import 'Widgets/RDBPurchasedListItem.dart';

class RDBPurchasedPage extends StatefulWidget {
  @override
  _RDBPurchasedPageState createState() => _RDBPurchasedPageState();
}

class _RDBPurchasedPageState extends State<RDBPurchasedPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  ScrollController _scrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isError = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isInit = false;
  String currentOrder = "purchasing";

  List<RDBPurchasedModel> rdbPurchasedList = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> sortOrders = [
    {'label': '登録件数', 'value': 'purchasing'},
    {'label': '価格', 'value': 'cart_price'},
    {'label': 'ランキング', 'value': 'sales_rank'},
    {'label': '新着', 'value': 'created_at'}
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getRDBPurchasedList();
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
    _getRDBPurchasedList();
  }

  _sortOrderHandler(String value) {
    if (currentOrder == value) return;
    currentOrder = value;
    rdbPurchasedList.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _isInit = false;
    setState(() {});
    _getRDBPurchasedList();
  }

  _getRDBPurchasedList() async {
    try {
      if (this._hasNextPage) {
        List<RDBPurchasedModel> lists = [];
        String url = sprintf("%sapi/rdb/purchased?p=%s&sort=%s", [Constants.URL, _currentPage.toString(), currentOrder]);
        var response = await HttpHelper.authGet(context, null, url, {});
        if (mounted) {
          if (response != null) {
            var result = json.decode(response.body);
            if (result['result'] == "success") {
              _currentPage++;
              _hasNextPage = _currentPage <= result['data']['last_page'];
              for (var item in result['data']['data']) {
                item['category_name'] = categories.firstWhere((element) => element['cat_id'] == item['cat_id'].toString())['name'];
                lists.add(RDBPurchasedModel.fromJson(item));
              }
              if (!_isInit) {
                _isInit = true;
              }
              setState(() {
                rdbPurchasedList.addAll(lists);
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
        title: Text("仕入れ済みRDB"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortOrderHandler,
            itemBuilder: (BuildContext context) {
              return sortOrders.map((choice) {
                return PopupMenuItem<String>(
                  value: choice['value'],
                  child: Text(choice['label']),
                  textStyle: TextStyle(color: choice['value'] == currentOrder ? Colors.blue : Colors.black),
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          color: Constants.BackgroundColor,
          child: Stack(
            children: [
              _isInit
                  ? rdbPurchasedList.length == 0
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
                              if (index == rdbPurchasedList.length) {
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
                              return RDBPurchasedListItem(
                                  rdbPurchasedModel: rdbPurchasedList[index],
                                  onPressed: () {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: RDBPurchasedDetailPage(rdbPurchasedModel: rdbPurchasedList[index]), inheritTheme: true, curve: Curves.easeIn, ctx: context));
                                  });
                            },
                            separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                            itemCount: rdbPurchasedList.length + 1,
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
