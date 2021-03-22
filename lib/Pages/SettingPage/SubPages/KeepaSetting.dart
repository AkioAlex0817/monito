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

class KeepaSetting extends StatefulWidget {
  final String keepaApiKey;

  KeepaSetting({Key key, @required this.keepaApiKey}) : super(key: key);

  @override
  _KeepaSettingState createState() => _KeepaSettingState();
}

class _KeepaSettingState extends State<KeepaSetting> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  bool _isError = false;
  bool _isLoading = false;

  final keepaController = TextEditingController();

  FocusNode keepaNode;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    keepaNode = FocusNode();
    keepaNode.addListener(() {
      if (keepaNode.hasFocus) {
        if (keepaController.text.length > 0) {
          keepaController.selection = TextSelection(baseOffset: 0, extentOffset: keepaController.text.length);
        }
      }
    });
    keepaController.text = widget.keepaApiKey;
  }

  @override
  void dispose() {
    keepaController?.dispose();
    keepaNode?.dispose();
    super.dispose();
  }

  _save() async {
    if (_isLoading) return;
    String keepaApiKey = keepaController.text.trim();
    if (keepaApiKey.isEmpty) {
      Helper.showToast("Keepa APIキーを入力してください。", false);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/setting/keepa_api_key";
    var response = await HttpHelper.authPost(context, url, {'value': keepaApiKey}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          await _databaseProvider.updateUserSetting(memberId, {'keepa_api_key': keepaApiKey});
          Helper.showToast(LangHelper.SUCCESS, true);
          Navigator.pop(context, keepaApiKey);
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
                                  "Keepaキー",
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                title: TextFormField(
                                  controller: keepaController,
                                  focusNode: keepaNode,
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                )),
                          ),
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
