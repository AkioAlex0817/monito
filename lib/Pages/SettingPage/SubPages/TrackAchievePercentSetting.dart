import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';

class TrackAchievePercentSetting extends StatefulWidget {
  @override
  _TrackAchievePercentSettingState createState() => _TrackAchievePercentSettingState();
}

class _TrackAchievePercentSettingState extends State<TrackAchievePercentSetting> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  bool _isError = false;
  bool _isLoading = false;
  final percentController = TextEditingController();
  FocusNode percentNode;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    percentNode = FocusNode();
    percentNode.addListener(() {
      if (this.percentNode.hasFocus) {
        if (this.percentController.text.length > 0) {
          this.percentController.selection = TextSelection(baseOffset: 0, extentOffset: this.percentController.text.length);
        }
      }
    });
    Timer(Duration(milliseconds: Constants.TransitionTime), () => _getAchievePercentInfo());
  }

  @override
  void dispose() {
    percentController?.dispose();
    percentNode?.dispose();
    super.dispose();
  }

  _getAchievePercentInfo() async {
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
            await _databaseProvider.insertOrUpdateSetting(memberId, result['data']['keepa_api_key'], result['data']['price_archive_percent'], result['data']['track_ranking']);
            percentController.text = result['data']['price_archive_percent'].toString();
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

  _save() async {
    if (_isLoading) return;
    String percent = percentController.text.trim();
    if (percent.isEmpty) {
      Helper.showToast("Please insert percent", false);
      return;
    }
    if (int.parse(percent) > 100) {
      Helper.showToast("Percent must be less than 100", false);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/setting/price_archive_percent";
    var response = await HttpHelper.authPost(context, url, {'value': percent}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          await _databaseProvider.updateUserSetting(memberId, {'price_archive_percent': int.parse(percent)});
          Helper.showToast(LangHelper.SUCCESS, true);
        } else {
          Helper.showToast(LangHelper.FAILED, false);
        }
      } else {
        Helper.showToast(LangHelper.FAILED, false);
      }
      setState(() {
        _isError = false;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("Keepa設定", style: TextStyle(color: Colors.white)),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              onPressed: () {
                _save();
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
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Color.fromARGB(255, 69, 78, 86)))),
                            child: ListTile(
                              tileColor: Colors.white,
                              leading: Text(
                                "Achieve Percent(%)",
                                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              title: TextFormField(
                                controller: percentController,
                                focusNode: percentNode,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          )
                        ],
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
