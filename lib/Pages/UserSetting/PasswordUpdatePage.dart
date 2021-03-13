import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Widgets/LoadingButton.dart';

class PasswordUpdatePage extends StatefulWidget {
  @override
  _PasswordUpdatePageState createState() => _PasswordUpdatePageState();
}

class _PasswordUpdatePageState extends State<PasswordUpdatePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPasswordConfirmController = TextEditingController();
  bool _newPasswordSecure = true;
  bool _newPasswordConfirmSecure = true;
  bool _isLoading = false;
  FocusNode _currentPasswordNode;
  FocusNode _newPasswordNode;
  FocusNode _newPasswordConfirmNode;

  bool _currentPasswordValidate = false;
  bool _newPasswordValidate = false;
  bool _newPasswordConfirmValidate = false;

  String _currentPasswordValidateMessage = "";
  String _newPasswordValidateMessage = "";
  String _newPasswordConfirmValidateMessage = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _currentPasswordNode = FocusNode();
    _newPasswordNode = FocusNode();
    _newPasswordConfirmNode = FocusNode();
  }

  @override
  void dispose() {
    _currentPasswordController?.dispose();
    _newPasswordController?.dispose();
    _newPasswordConfirmController?.dispose();
    _currentPasswordNode?.dispose();
    _newPasswordNode?.dispose();
    _newPasswordConfirmNode?.dispose();
    super.dispose();
  }

  _updatePassword() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_isLoading) return;
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String newConfirmPassword = _newPasswordConfirmController.text.trim();

    if (currentPassword.isEmpty) {
      setState(() {
        _currentPasswordValidate = true;
        _currentPasswordValidateMessage = "Please insert current password";
      });
      return;
    }

    setState(() {
      _currentPasswordValidate = false;
      _currentPasswordValidateMessage = "";
    });

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordValidate = true;
        _newPasswordValidateMessage = "Please insert new password";
      });
      return;
    }

    setState(() {
      _newPasswordValidate = false;
      _newPasswordValidateMessage = "";
    });

    if (newConfirmPassword.isEmpty) {
      setState(() {
        _newPasswordConfirmValidate = true;
        _newPasswordConfirmValidateMessage = "Please insert new password confirm";
      });
      return;
    }
    setState(() {
      _newPasswordConfirmValidate = false;
      _newPasswordConfirmValidateMessage = "";
    });

    if (newPassword != newConfirmPassword) {
      setState(() {
        _newPasswordValidate = true;
        _newPasswordValidateMessage = "Please confirm password is wrong";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String url = Constants.URL + "api/update_password";
    var response = await HttpHelper.authPost(context, url, {"current_password": currentPassword, "password": newPassword, "password_confirmation": newConfirmPassword}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          Helper.showToast(LangHelper.SUCCESS, true);
        } else {
          Helper.showToast("メールアドレスもしくはパスワードが不正です。", false);
        }
      } else {
        Helper.showToast("未知エラー:サーバ通信中にエラーが出ました。", false);
      }
      setState(() {
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
        title: Text("パスワード変更", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    children: [
                      40.height,
                      TextField(
                        focusNode: _currentPasswordNode,
                        controller: _currentPasswordController,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (term) {
                          _currentPasswordNode.unfocus();
                          FocusScope.of(context).requestFocus(_newPasswordNode);
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                            hintText: "古いパスワード",
                            hintStyle: TextStyle(color: Colors.black),
                            errorText: _currentPasswordValidate ? _currentPasswordValidateMessage : null,
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                      ),
                      24.height,
                      TextField(
                        focusNode: _newPasswordNode,
                        controller: _newPasswordController,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        obscureText: _newPasswordSecure,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        onSubmitted: (term) {
                          _newPasswordNode.unfocus();
                          FocusScope.of(context).requestFocus(_newPasswordConfirmNode);
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
                            hintText: "新しいパスワード",
                            hintStyle: TextStyle(color: Colors.black),
                            errorText: _newPasswordValidate ? _newPasswordValidateMessage : null,
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                      ),
                      24.height,
                      TextField(
                        focusNode: _newPasswordConfirmNode,
                        controller: _newPasswordConfirmController,
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        obscureText: _newPasswordConfirmSecure,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        onSubmitted: (term) {
                          _newPasswordConfirmNode.unfocus();
                        },
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _newPasswordConfirmSecure = !_newPasswordConfirmSecure;
                                });
                              },
                              child: Icon(
                                _newPasswordConfirmSecure ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                            hintText: "パスワード確認",
                            hintStyle: TextStyle(color: Colors.black),
                            errorText: _newPasswordConfirmValidate ? _newPasswordConfirmValidateMessage : null,
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5))),
                      ),
                      48.height,
                      SizedBox(
                        height: 50,
                        child: LoadingButton(
                          title: "保 存",
                          color: Constants.ButtonColor,
                          disabled: _isLoading,
                          loading: _isLoading,
                          fontColor: Colors.white,
                          fontSize: 15,
                          loadingColor: Colors.black,
                          loadingSize: 20,
                          borderRadius: 10,
                          onPressed: () {
                            _updatePassword();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
