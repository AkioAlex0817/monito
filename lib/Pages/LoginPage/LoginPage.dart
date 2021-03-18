import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Pages/OptCodePage/OptCodePage.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  PageController pageController;

  // Variable Sign in
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  FocusNode _usernameNode;
  FocusNode _passwordNode;
  bool isSecure = true;
  bool _usernameValidate = false;
  bool _passwordValidate = false;
  String _usernameValidateMessage = "";
  String _passwordValidateMessage = "";

  // Variable Sign in end

  //Variable Sign up
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  FocusNode _nickNameNode;
  FocusNode _emailNode;
  FocusNode _newPasswordNode;
  FocusNode _confirmPasswordNode;

  bool _newPasswordSecure = true;
  bool _confirmPasswordSecure = true;

  bool _nickNameValidate = false;
  bool _emailValidate = false;
  bool _newPasswordValidate = false;

  String _nickNameValidateMessage = "";
  String _emailValidateMessage = "";
  String _newPasswordValidateMessage = "";

  // Variable Sign up end

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    pageController = PageController(initialPage: 0);
    _usernameNode = FocusNode();
    _passwordNode = FocusNode();
    _nickNameNode = FocusNode();
    _emailNode = FocusNode();
    _newPasswordNode = FocusNode();
    _confirmPasswordNode = FocusNode();
  }

  @override
  void dispose() {
    _usernameController?.dispose();
    _passwordController?.dispose();
    _nicknameController?.dispose();
    _emailController?.dispose();
    _newPasswordController?.dispose();
    _confirmPasswordController?.dispose();
    _usernameNode?.dispose();
    _passwordNode?.dispose();
    _nickNameNode?.dispose();
    _emailNode?.dispose();
    _newPasswordNode?.dispose();
    _confirmPasswordNode?.dispose();
    pageController?.dispose();
    super.dispose();
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

  _signUp() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_isLoading) return;

    String nickname = _nicknameController.text.trim();
    String email = _emailController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _nickNameValidate = true;
        _nickNameValidateMessage = "このフィールドは必須です。";
      });
      return;
    }
    setState(() {
      _nickNameValidate = false;
      _nickNameValidateMessage = "";
    });

    if (email.isEmpty) {
      setState(() {
        _emailValidate = true;
        _emailValidateMessage = "メールアドレスを入力してください。";
      });
      return;
    }

    if (!RegExp(r"^.+@.+\.[a-zA-Z\-_]+$").hasMatch(email)) {
      setState(() {
        _emailValidate = true;
        _emailValidateMessage = "メールアドレスの形式が不正です。";
      });
      return;
    }
    setState(() {
      _emailValidate = false;
      _emailValidateMessage = "";
    });

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordValidate = true;
        _newPasswordValidateMessage = "パスワードを入力してください。";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _newPasswordValidate = true;
        _newPasswordValidateMessage = "パスワードと、確認フィールドとが、一致していません。";
      });
    }

    setState(() {
      _newPasswordValidate = false;
      _newPasswordValidateMessage = "";
      _isLoading = true;
    });

    String url = Constants.URL + "api/register";
    var response = await HttpHelper.post(null, url, {'name': nickname, 'email': email, 'password': newPassword, 'password_confirmation': confirmPassword}, {}, false, false);

    if (mounted) {
      if (response != null) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result'] == 'success') {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(PageTransition(type: PageTransitionType.rightToLeft, child: OptCodePage(email: email), inheritTheme: false, curve: Curves.easeIn));
        } else {
          setState(() {
            _isLoading = false;
          });
          Helper.showToast(result['message'], false);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Helper.showToast("未知エラー:サーバ通信中にエラーが出ました。", false);
      }
    }
  }

  _resendOptCode() async {
    String email = _usernameController.text.trim();
    String url = Constants.URL + "api/register/optcode/resend";
    var response = await HttpHelper.post(null, url, {'email': email}, {}, false, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          Navigator.of(context).pushReplacement(PageTransition(type: PageTransitionType.rightToLeft, child: OptCodePage(email: email), inheritTheme: false, curve: Curves.easeIn));
        } else {
          setState(() {
            _isLoading = false;
          });
          Helper.showToast(result['message'], false);
        }
      } else {
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
    String url = sprintf("%sapi/me?is_ios=%d&device_token=%s&is_test=%s", [Constants.URL, isIOS ? 1 : 0, deviceToken, isTest ? "1" : "0"]);
    var response = await HttpHelper.authGet(context, null, url, {}, needResponse: true);
    if (mounted && response != null) {
      if (response.statusCode == 403) {
        //email not verified
        isLogin = false;
        await MyApp.shareUtils.setString(Constants.SharePreferencesKey, null);
        //send optcode resend
        _resendOptCode();
        return;
      }
      var result = json.decode(response.body);
      if (result['result'] == "success") {
        var data = result['data'];
        //init user limitation
        Helper.setMemberInfo(
          data['current_plan'],
          data['profile']['id'],
          data['profile']['name'],
          data['profile']['email'],
          data['limitation']['tracker'],
          data['limitation']['deals'],
          data['limitation']['achievelist'] is int ? data['limitation']['achievelist'] : 0,
          data['limitation']['wishlist'] is int ? data['limitation']['wishlist'] : 0,
          data['limitation']['purchasinglist'] is int ? data['limitation']['purchasinglist'] : 0,
          data['limitation']['purchasedlist'] is int ? data['limitation']['purchasedlist'] : 0,
          data['limitation']['rdb'],
        );
        //sync suppliers name
        for(var item in data['suppliers']){
          await _databaseProvider.insertOrUpdateSupplier(item['id'], item['name']);
        }
        //update user setting
        await _databaseProvider.insertOrUpdateSetting(memberId, data['user_settings']['keepa_api_key'], data['user_settings']['price_archive_percent'], data['user_settings']['track_ranking']);
      }
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: PageView.builder(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, int index) {
            switch (index) {
              case 0:
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: SingleChildScrollView(
                        child: Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(left: 24, right: 24, top: height * 0.1),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Image.asset("assets/splash_icon.png", width: width * 0.4),
                              ),
                              40.height,
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
                                    hintStyle: TextStyle(color: Colors.grey),
                                    errorText: _usernameValidate ? _usernameValidateMessage : null,
                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                    errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 0.5)),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                              ),
                              24.height,
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
                                    hintStyle: TextStyle(color: Colors.grey),
                                    errorText: _passwordValidate ? _passwordValidateMessage : null,
                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                    errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 0.5)),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                              ),
                              24.height,
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
                              24.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("アカウントを持っていない方は?"),
                                  InkWell(
                                    onTap: () {
                                      FocusScope.of(context).requestFocus(new FocusNode());
                                      pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                    },
                                    child: Text(
                                      "会員登録",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  )
                                ],
                              ),
                              48.height,
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
                );
                break;
              case 1:
                return Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        child: Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(left: 24, right: 24, top: height * 0.06),
                          child: Column(
                            children: [
                              Center(
                                child: Image.asset("assets/splash_icon.png", width: width * 0.4),
                              ),
                              30.height,
                              TextField(
                                focusNode: _nickNameNode,
                                controller: _nicknameController,
                                style: TextStyle(fontSize: 18.0, color: Colors.black),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                onSubmitted: (term) {
                                  _nickNameNode.unfocus();
                                  FocusScope.of(context).requestFocus(_emailNode);
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                                    hintText: "ニックネーム",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    errorText: _nickNameValidate ? _nickNameValidateMessage : null,
                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                    errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 0.5)),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                              ),
                              15.height,
                              TextField(
                                focusNode: _emailNode,
                                controller: _emailController,
                                style: TextStyle(fontSize: 18.0, color: Colors.black),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                onSubmitted: (term) {
                                  _emailNode.unfocus();
                                  FocusScope.of(context).requestFocus(_newPasswordNode);
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                                    hintText: "メールアドレス",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    errorText: _emailValidate ? _emailValidateMessage : null,
                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                    errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 0.5)),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                              ),
                              15.height,
                              TextField(
                                focusNode: _newPasswordNode,
                                controller: _newPasswordController,
                                style: TextStyle(fontSize: 18.0, color: Colors.black),
                                obscureText: _newPasswordSecure,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
                                onSubmitted: (term) {
                                  _newPasswordNode.unfocus();
                                  FocusScope.of(context).requestFocus(_confirmPasswordNode);
                                },
                                decoration: InputDecoration(
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _newPasswordSecure = !_newPasswordSecure;
                                        });
                                      },
                                      child: Icon(
                                        _newPasswordSecure ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                                    hintText: "パスワード",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    errorText: _newPasswordValidate ? _newPasswordValidateMessage : null,
                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                    errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 0.5)),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                              ),
                              15.height,
                              TextField(
                                focusNode: _confirmPasswordNode,
                                controller: _confirmPasswordController,
                                style: TextStyle(fontSize: 18.0, color: Colors.black),
                                obscureText: _confirmPasswordSecure,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
                                onSubmitted: (term) {
                                  _confirmPasswordNode.unfocus();
                                },
                                decoration: InputDecoration(
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _confirmPasswordSecure = !_confirmPasswordSecure;
                                        });
                                      },
                                      child: Icon(
                                        _confirmPasswordSecure ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                                    hintText: "パスワード確認",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                    errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 0.5)),
                                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                              ),
                              24.height,
                              GestureDetector(
                                onTap: () {
                                  _signUp();
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
                                    "会員登録",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              24.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("アカウントをお持ちの方は?"),
                                  InkWell(
                                    onTap: () {
                                      FocusScope.of(context).requestFocus(new FocusNode());
                                      pageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                    },
                                    child: Text(
                                      "ログイン",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  )
                                ],
                              ),
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
                );
                break;
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
