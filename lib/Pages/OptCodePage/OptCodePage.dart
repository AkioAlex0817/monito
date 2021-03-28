import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/Pages/MainPage/MainPage.dart';
import 'package:monito/Pages/OptCodePage/Widgets/PinEntryTextField.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class OptCodePage extends StatefulWidget {
  final String email;

  OptCodePage({Key key, this.email}) : super(key: key);

  @override
  _OptCodePageState createState() => _OptCodePageState();
}

class _OptCodePageState extends State<OptCodePage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  final GlobalKey<PinEntryTextFieldState> pinEntryTextFieldKey = new GlobalKey<PinEntryTextFieldState>();
  Timer _timer;
  int _start = 180;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) =>
          setState(
                () {
              if (_start < 1) {
                timer.cancel();
              } else {
                _start = _start - 1;
              }
            },
          ),
    );
  }

  _resendOptCode() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    String url = Constants.URL + "api/register/optcode/resend";
    var response = await HttpHelper.post(null, url, {'email': widget.email}, {}, false, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          if (pinEntryTextFieldKey.currentState.mounted) {
            pinEntryTextFieldKey.currentState.clearTextFields();
          }
          _start = 180;
          startTimer();
          setState(() {
            _isLoading = false;
          });
        } else {
          _errorHandler(result['message']);
        }
      } else {
        _errorHandler("未知エラー:サーバ通信中にエラーが出ました。");
      }
    }
  }

  _checkOPTCode(String pin) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/register/confirm/optcode";
    var response = await HttpHelper.post(null, url, {'email': widget.email, 'opt_code': pin}, {}, false, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          _successSignIn(result['data']);
        } else {
          _errorHandler(result['message']);
        }
      } else {
        _errorHandler("未知エラー:サーバ通信中にエラーが出ました。");
      }
    }
  }

  Future<void> _successSignIn(Map<String, dynamic> body) async {
    await MyApp.shareUtils.setString(Constants.SharePreferencesKey, json.encode(body));
    //Get user info
    String url = sprintf("%sapi/me?is_ios=%d&device_token=%s&save_token=%s", [Constants.URL, isIOS ? 1 : 0, deviceToken, isTest ? "0" : "1"]);
    var response = await HttpHelper.authGet(context, null, url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == 'success') {
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
          //update user setting
          await _databaseProvider.insertOrUpdateSetting(memberId, data['user_settings']['keepa_api_key'], data['user_settings']['price_archive_percent'], data['user_settings']['track_ranking'], data['user_settings']['low_ranking_range']);
          Navigator.pushAndRemoveUntil(context, PageTransition(child: MainPage(), type: PageTransitionType.fade), (route) => false);
        } else {
          _errorHandler("Failed user info sync work");
        }
      } else {
        _errorHandler("Failed user info sync work");
      }
    }
  }

  _errorHandler(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if(this.pinEntryTextFieldKey.currentState.mounted){
        this.pinEntryTextFieldKey.currentState.clearTextFields();
      }
      Helper.showToast(message, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(left: 24, right: 24, top: height * 0.1),
                  child: Column(
                    children: [
                      Center(
                        child: Image.asset("assets/splash_icon.png", width: width * 0.4),
                      ),
                      40.height,
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "認証コードを入力していください。 \n 入力されたメールアドレスに認証コードを転送しました。",
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      40.height,
                      PinEntryTextField(
                        key: pinEntryTextFieldKey,
                        fields: 4,
                        fontSize: 18.0,
                        onSubmit: (pin) {
                          _checkOPTCode(pin);
                        },
                      ),
                      60.height,
                      Container(
                        alignment: Alignment.center,
                        child: _start == 0
                            ? InkWell(
                          onTap: () {
                            _resendOptCode();
                          },
                          child: Text("再送信", style: TextStyle(color: Colors.blue, fontSize: 16)),
                        )
                            : Text(
                          "再送信まで$_start秒",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
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
