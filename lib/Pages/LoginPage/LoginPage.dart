import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isSecure = true;
  bool _isLoading = false;
  FocusNode _usernameNode;
  FocusNode _passwordNode;
  bool _usernameValidate = false;
  bool _passwordValidate = false;

  String _usernameValidateMessage = "";
  String _passwordValidateMessage = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _usernameNode = FocusNode();
    _passwordNode = FocusNode();
  }

  _signIn() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    if (_isLoading) return;
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _usernameValidate = true;
        _usernameValidateMessage = "メールアドレスを入力してください。";
      });
      return;
    }

    if (!RegExp(r"^.+@.+\.[a-zA-Z\-_]+$").hasMatch(username)) {
      setState(() {
        _usernameValidate = true;
        _usernameValidateMessage = "メールアドレスの形式が不正です。";
      });
      return;
    }

    setState(() {
      _usernameValidate = false;
      _usernameValidateMessage = "";
    });

    if (password.isEmpty) {
      setState(() {
        _passwordValidate = true;
        _passwordValidateMessage = "パスワードを入力してください。";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _passwordValidate = true;
        _passwordValidateMessage = "パスワードを正しく入力してください。";
      });
      return;
    }

    setState(() {
      _passwordValidate = false;
      _passwordValidateMessage = "";
      _isLoading = true;
    });

    String url = Constants.URL + "oauth/token";
    var response = await HttpHelper.post(
        null,
        url,
        {
          "grant_type": Constants.grant_type_password,
          "client_id": Constants.client_id,
          "client_secret": Constants.client_secret,
          "scope": Constants.scope,
          "username": username,
          "password": password,
        },
        {},
        false,
        true);
    if (response != null) {
      if (mounted) {
        Map<String, dynamic> result = jsonDecode(response.body);
        if (result.containsKey("error")) {
          setState(() {
            _isLoading = false;
          });
          Helper.showToast("メールアドレスもしくはパスワードが不正です。", false);
        } else {
          _successSignIn(response.body);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Helper.showToast("未知エラー:サーバ通信中にエラーが出ました。", false);
      }
    }
  }

  Future<void> _successSignIn(String body) async {
    isLogin = true;
    await MyApp.shareUtils.setString(Constants.SharePreferencesKey, body);
    //Get user info
    String url = Constants.URL + "api/me";
    var response = await HttpHelper.authGet(context, null, url, {});
    if (mounted && response != null) {
      var result = json.decode(response.body);
      if (result['result'] == "success") {
        var data = result['data'];
        Helper.setMemberInfo(
          data['current_plan'],
          data['profile']['id'],
          data['profile']['name'],
          data['profile']['email'],
          data['limitation']['tracker'],
          data['limitation']['deals'],
          data['limitation']['achievelist'],
          data['limitation']['wishlist'],
          data['limitation']['purchasinglist'],
          data['limitation']['purchasedlist'],
          data['limitation']['rdb'],
        );
      }
    }
    //sync suppliers name
    String supplierUrl = Constants.URL + "api/setting/suppliers";
    var supplierResponse = await HttpHelper.authGet(context, null, supplierUrl, {});
    if (mounted && supplierUrl != null) {
      var supplierResult = json.decode(supplierResponse.body);
      if (supplierResult['result'] == "success") {
        for (var item in supplierResult['data']) {
          await _databaseProvider.insertOrUpdateSupplier(item['id'], item['name']);
        }
      }
    }

    //update user setting
    String settingURL = Constants.URL + "api/setting";
    var settingResponse = await HttpHelper.authGet(context, null, settingURL, {});
    if (mounted && settingResponse != null) {
      var settingResult = json.decode(settingResponse.body);
      if (settingResult['result'] == 'success') {
        await _databaseProvider.insertOrUpdateSetting(memberId, settingResult['data']['keepa_api_key'], settingResult['data']['price_archive_percent'], settingResult['data']['track_ranking']);
      }
    }

    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController?.dispose();
    _passwordController?.dispose();
    _usernameNode?.dispose();
    _passwordNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(left: 24, right: 24, top: height * 0.15),
                  child: Column(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset("assets/splash_icon.png", width: width * 0.4),
                        ],
                      ),
                      SizedBox(height: 40),
                      TextField(
                        focusNode: _usernameNode,
                        controller: _usernameController,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (term) {
                          _usernameNode.unfocus();
                          FocusScope.of(context).requestFocus(_passwordNode);
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                            hintText: "メールアドレス",
                            hintStyle: TextStyle(color: Colors.black),
                            errorText: _usernameValidate ? _usernameValidateMessage : null,
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        focusNode: _passwordNode,
                        controller: _passwordController,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        obscureText: isSecure,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        onSubmitted: (term) {
                          _passwordNode.unfocus();
                        },
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSecure = !isSecure;
                                });
                              },
                              child: Icon(
                                isSecure ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                            hintText: "パスワード",
                            hintStyle: TextStyle(color: Colors.black),
                            errorText: _passwordValidate ? _passwordValidateMessage : null,
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          _signIn();
                        },
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Constants.ButtonColor,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Text(
                            "ログイン",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: ClipOval(
                child: Material(
                  color: Colors.black12,
                  child: InkWell(
                    splashColor: Colors.black26,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
            _isLoading
                ? Positioned.fill(
                    child: Loading(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
