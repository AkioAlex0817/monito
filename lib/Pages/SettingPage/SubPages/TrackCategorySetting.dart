import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/SettingPage/Model/AmazonCategory.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';

class TrackCategorySetting extends StatefulWidget {
  @override
  _TrackCategorySettingState createState() => _TrackCategorySettingState();
}

class _TrackCategorySettingState extends State<TrackCategorySetting> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  bool _isError = false;
  bool _isLoading = false;

  bool _readyGetCategories = false;
  bool _readyUserCategory = false;

  int _selectedCount = 0;
  List<String> selectedCategory = [];
  List<AmazonCategory> allCategories = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Timer(Duration(milliseconds: Constants.TransitionTime), () => _init());
  }

  _init() {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    _getCategory();
    _getUserCategory();
  }

  _getCategory() async {
    String url = Constants.URL + "api/categories";
    HttpHelper.get(null, url, {}).then((response) async {
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            for (var item in result['data']) {
              allCategories.add(new AmazonCategory(item['cat_id'].toString(), item['name'], item['context_free_name'], item['highest_rank'].toString(), item['product_count'].toString()));
              await _databaseProvider.insertOrUpdateCategory(item['cat_id'].toString(), item['name'], item['context_free_name']);
            }
            _readyGetCategories = true;
            _checkInit();
          } else {
            _errorHandler();
          }
        } else {
          _errorHandler();
        }
      }
    });
  }

  _getUserCategory() async {
    if (isLogin) {
      String url = Constants.URL + "api/setting";
      HttpHelper.authGet(context, null, url, {}).then((response) {
        if (mounted) {
          if (response != null) {
            var result = json.decode(response.body);
            if (result['result'] == "success") {
              for (var item in result['data']['track_categories']) {
                selectedCategory.add(item);
                _selectedCount++;
              }
              _readyUserCategory = true;
              _checkInit();
            } else {
              _errorHandler();
            }
          } else {
            _errorHandler();
          }
        }
      });
    } else {
      String unAuthCategory = await MyApp.shareUtils.getString(Constants.UnAuthTrackCategoryKey);
      if (unAuthCategory != null && unAuthCategory != "") {
        selectedCategory.add(unAuthCategory);
        _selectedCount = 1;
      }
      _readyUserCategory = true;
    }
  }

  _errorHandler() {
    if (mounted) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  _checkInit() {
    if (mounted) {
      if (_readyGetCategories && _readyUserCategory) {
        setState(() {
          _isLoading = false;
          _isError = false;
        });
      }
    }
  }

  _saveCategory() async {
    if (_isLoading) return;
    if (selectedCategory.isEmpty) return;
    if (isLogin) {
      setState(() {
        _isError = false;
        _isLoading = true;
      });

      String url = Constants.URL + "api/setting/track_categories";
      var response = await HttpHelper.authPost(context, url, {'value': selectedCategory.join(",")}, {}, false);
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            setState(() {
              _isLoading = false;
            });
            Helper.showToast(LangHelper.SUCCESS, true);
          } else {
            setState(() {
              _isLoading = false;
            });
            Helper.showToast(LangHelper.FAILED, false);
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          Helper.showToast(LangHelper.FAILED, false);
        }
      }
    } else {
      await MyApp.shareUtils.setString(Constants.UnAuthTrackCategoryKey, selectedCategory.first);
      Helper.showToast(LangHelper.SUCCESS, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("カテゴリ", style: TextStyle(color: Colors.white)),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              onPressed: _selectedCount <= 0
                  ? null
                  : () {
                      _saveCategory();
                    },
              color: Colors.amber,
              disabledColor: Colors.amber.withOpacity(0.2),
              child: Text(
                "保存",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
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
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          return CheckboxListTile(
                            title: Text(
                              allCategories[index].name,
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            value: selectedCategory.contains(allCategories[index].cat_id),
                            onChanged: _selectedCount < maxTracker || selectedCategory.contains(allCategories[index].cat_id)
                                ? (bool value) {
                                    if (value) {
                                      setState(() {
                                        selectedCategory.add(allCategories[index].cat_id);
                                        _selectedCount++;
                                      });
                                    } else {
                                      setState(() {
                                        selectedCategory.remove(allCategories[index].cat_id);
                                        _selectedCount--;
                                      });
                                    }
                                  }
                                : null,
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.black,
                        ),
                        itemCount: allCategories.length,
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
