import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/PurchasedPage/Model/PurchasedModel.dart';
import 'package:monito/Pages/PurchasedPage/Widgets/PurchasedListItem.dart';
import 'package:monito/Widgets/Loading.dart';

class PurchasedPage extends StatefulWidget {
  @override
  _PurchasedPageState createState() => _PurchasedPageState();
}

class _PurchasedPageState extends State<PurchasedPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  ScrollController _scrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isError = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isInit = false;
  List<PurchasedModel> purchasedList = [];
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getPurchasedList();
      }
    });
    _init();
  }

  _init() async {
    categories = await _databaseProvider.getAllCategories();
    _getPurchasedList();
  }

  _getPurchasedList() async {
    try {
      if (_hasNextPage) {
        List<PurchasedModel> lists = [];
        String url = Constants.URL + "api/purchased?p=" + _currentPage.toString();
        var response = await HttpHelper.authGet(context, null, url, {});
        if (mounted) {
          if (response != null) {
            var result = json.decode(response.body);
            if (result['result'] == "success") {
              _currentPage++;
              _hasNextPage = _currentPage <= result['data']['last_page'];
              for (var item in result['data']['data']) {
                item['category_name'] = categories.firstWhere((element) => element['cat_id'] == item['cat_id'].toString())['name'];
                lists.add(PurchasedModel.fromJson(item));
              }
              if (!_isInit) {
                _isInit = true;
              }
              setState(() {
                purchasedList.addAll(lists);
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("仕入れ済みリスト", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          child: Stack(children: [
            _isInit
                ? purchasedList.length == 0
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
                            if (index == purchasedList.length) {
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
                            return PurchasedListItem(
                                purchasedModel: purchasedList[index],
                                onPressed: () {
                                  //Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: PurchasingDetailPage(purchasingModel: purchasingList[index]), inheritTheme: true, curve: Curves.easeIn, ctx: context));
                                });
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                          itemCount: purchasedList.length + 1,
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
          ]),
        ),
      ),
    );
  }
}
