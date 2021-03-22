import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/PurchasedPage/Model/PurchasedModel.dart';
import 'package:monito/Pages/PurchasedPage/Widgets/PurchasedListItem.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:page_transition/page_transition.dart';

import 'SubPages/PurchasedDetailPage.dart';

class PurchasedPage extends StatefulWidget {
  @override
  _PurchasedPageState createState() => _PurchasedPageState();
}

class _PurchasedPageState extends State<PurchasedPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  ScrollController _scrollController = new ScrollController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isError = false;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isInit = false;
  List<PurchasedModel> purchasedList = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> suppliers = [];

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
    suppliers = await _databaseProvider.getAllSuppliers();
    _getPurchasedList();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
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
                item['supplier_name'] = suppliers.firstWhere((element) => element['id'] == item['supplier'])['name'];
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

  _removePurchased(int index) async {
    if (_isLoading) return;
    PurchasedModel removeItem = purchasedList[index];
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/purchased?asin=" + removeItem.asin;
    var response = await HttpHelper.authDelete(url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          Helper.showToast(LangHelper.SUCCESS, true);
          purchasedList.removeAt(index);
        } else {
          Helper.showToast(LangHelper.FAILED, false);
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
                          controller: _scrollController,
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
                            return Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: PurchasedListItem(
                                  purchasedModel: purchasedList[index],
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.fade,
                                          child: PurchasedDetailPage(purchasedModel: purchasedList[index]),
                                          inheritTheme: true,
                                          curve: Curves.easeIn,
                                          ctx: context,
                                        )).then((value) {
                                      if (value == "Remove") {
                                        _removePurchased(index);
                                      }
                                    });
                                  }),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  onTap: () {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: Text("削除してもよろしいでしょうか？"),
                                          actions: [
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: Text(LangHelper.YES),
                                              onPressed: () {
                                                Navigator.of(context, rootNavigator: true).pop("Discard");
                                                _removePurchased(index);
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: Text(LangHelper.NO),
                                              isDestructiveAction: true,
                                              onPressed: () {
                                                Navigator.of(context, rootNavigator: true).pop("Discard");
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  iconWidget: Container(
                                    decoration: BoxDecoration(color: Colors.red),
                                    child: Center(
                                      child: Icon(Icons.delete, size: 25, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                          itemCount: purchasedList.length + 1,
                        ),
                      )
                : Positioned.fill(
                    child: Container(color: Constants.BackgroundColor, child: Loading()),
                  ),
            _isLoading
                ? Positioned.fill(
                    child: Container(color: Colors.transparent, child: Loading()),
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
          ]),
        ),
      ),
    );
  }
}
