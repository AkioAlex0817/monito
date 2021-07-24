import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/Pages/SearchPage/SubPages/SearchDetailPage.dart';
import 'package:monito/Pages/SearchPage/Widget/SearchListItem.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:page_transition/page_transition.dart';

import 'Model/SearchModel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchNode = FocusNode();
  List<SearchModel> _searchLists = [];
  List<Map<String, dynamic>> categories = [];
  bool _isCursorEnd = true;
  bool _isShowClearButton = false;
  bool _isRequest = false;
  bool _isError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _searchNode.addListener(() {
      if (_searchNode.hasFocus) {
        if (_searchController.text.length > 0 && _isCursorEnd) {
          _isCursorEnd = false;
          _searchController.selection = TextSelection.collapsed(offset: _searchController.text.length);
        }
      } else {
        _isCursorEnd = true;
      }
    });
    _initOption();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  _initOption() async {
    categories = await _databaseProvider.getAllCategories();
    Timer(Duration(milliseconds: 100), () {
      _searchNode.requestFocus();
    });
  }

  _getSearchSubmit() async {
    setState(() {
      _isError = false;
    });
    if (_isRequest) return;
    String searchStr = _searchController.text.trim();
    if (searchStr.isEmpty) {
      FocusScope.of(context).requestFocus(_searchNode);
      Helper.showToast("キーワードをご入力ください。", false);
      return;
    }
    setState(() {
      _isRequest = true;
    });
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _searchLists = [];
    });
    String url = Constants.URL + "api/search";
    var response = await HttpHelper.authPost(context, url, {"query": searchStr}, {}, false);
    if (mounted) {
      if (response != null) {
        var results = json.decode(response.body);
        if (results['result'] == "success") {
          for (var item in results['data']) {
            var category = categories.firstWhere((element) => element['cat_id'] == item['cat_id'].toString(), orElse: () => null);
            if (category != null) {
              item['category_name'] = category['name'];
            } else {
              item['category_name'] = "--";
            }
            SearchModel model = SearchModel.fromJson(item);
            _searchLists.add(model);
          }
          setState(() {
            _isRequest = false;
            _isError = false;
            _errorMessage = "";
          });
        } else {
          _errorPostHandler(errorMessage: results["message"]);
        }
      } else {
        _errorPostHandler();
      }
    }
  }

  _errorPostHandler({String errorMessage}) {
    if (mounted) {
      setState(() {
        _isError = true;
        _errorMessage = errorMessage != null && errorMessage.isNotEmpty ? errorMessage : "該当データなし";
        _isRequest = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 60,
                width: double.infinity,
                child: Container(
                  color: Constants.StatusBarColor,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            focusNode: _searchNode,
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search, size: 30, color: Colors.grey),
                                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                hintText: "キーワード、JAN、ASIN、ISBNで検索",
                                hintStyle: TextStyle(letterSpacing: 1, color: Color.fromARGB(255, 192, 202, 204), fontSize: 13, fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                                suffixIcon: _isShowClearButton
                                    ? Transform.rotate(
                                        angle: 45 * pi / 180,
                                        child: IconButton(
                                          icon: Icon(Icons.add_circle, color: Colors.grey),
                                          onPressed: () {
                                            Future.delayed(Duration(milliseconds: 50)).then((_) => _searchController.clear());
                                            setState(() {
                                              _isShowClearButton = false;
                                            });
                                          },
                                        ),
                                      )
                                    : null),
                            onSubmitted: (value) {
                              _getSearchSubmit();
                            },
                            onChanged: (value) {
                              if (value.length > 0) {
                                setState(() {
                                  _isShowClearButton = true;
                                });
                              } else {
                                setState(() {
                                  _isShowClearButton = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      10.width,
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: FloatingActionButton(
                          onPressed: _getSearchSubmit,
                          child: Icon(Icons.search, size: 30),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: _isError
                      ? Container(
                          constraints: BoxConstraints.expand(),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          child: Text(
                            _errorMessage == "" ? "通信エラー" : _errorMessage,
                            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )
                      : _isRequest
                          ? Container(
                              constraints: BoxConstraints.expand(),
                              alignment: Alignment.center,
                              child: Center(child: Loading()),
                            )
                          : _searchLists.length == 0
                              ? Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "キーワード,JAN,ASINを入力してください",
                                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _searchLists.length,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  separatorBuilder: (context, index) => Divider(color: Colors.transparent),
                                  itemBuilder: (BuildContext context, int index) {
                                    return SearchListItem(
                                      searchModel: _searchLists[index],
                                      onPressed: () {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: SearchDetailPage(searchModel: _searchLists[index]), inheritTheme: true, curve: Curves.easeIn, ctx: context)).then((value) {
                                          setState(() {});
                                        });
                                      },
                                    );
                                  },
                                ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
