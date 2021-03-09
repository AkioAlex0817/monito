import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monito/Pages/SplashPage/SplashPage.dart';
import 'package:monito/main.dart';

import 'Constants.dart';
import 'Helper.dart';

class HttpHelper {
  static Future<http.Response> get(http.Client client, String url, Map<String, String> headers) async {
    if (client == null) {
      client = new http.Client();
    }
    headers.addAll({"accept": "application/json"});
    try {
      var response = await client.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (socketErr) {
      print("SocketException: $socketErr");
      return null;
    } on TimeoutException catch (timeErr) {
      print("TimeOutException : $timeErr");
      return null;
    } on Exception catch (err) {
      print("Error: $err");
      return null;
    } catch (catch_err) {
      print("Error: $catch_err");
      return null;
    }
  }

  static Future<http.Response> post(http.Client client, String url, Map<String, dynamic> params, Map<String, String> headers, bool isJson, bool allowUnAuth) async {
    if (client == null) {
      client = new http.Client();
    }
    headers.addAll({"accept": "application/json"});
    try {
      var response = await client.post(Uri.parse(url), headers: headers, body: isJson ? json.encode(params) : params);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 500) {
        return null;
      } else if (allowUnAuth) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (socketErr) {
      print("SocketException: $socketErr");
      return null;
    } on TimeoutException catch (timeErr) {
      print("TimeOutException : $timeErr");
      return null;
    } on Exception catch (err) {
      print("Error: $err");
      return null;
    } catch (catch_err) {
      print("Error: $catch_err");
      return null;
    }
  }

  static Future<http.Response> authPost(BuildContext context, String url, Map<String, dynamic> params, Map<String, String> headers, bool isJSON, {http.Client client}) async {
    String tokenString = await MyApp.shareUtils.getString(Constants.SharePreferencesKey);
    if (Helper.checkEmptyToken(tokenString)) {
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
              fullscreenDialog: true,
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                return SplashPage();
              },
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              }),
          (_) => false);
      return null;
    }
    if (client == null) {
      client = new http.Client();
    }
    var token = json.decode(tokenString);
    headers.addAll({"Authorization": token["token_type"] + " " + token["access_token"], "accept": "application/json"});
    if (isJSON) {
      headers.addAll({"Content-type": "application/json"});
    }
    try {
      var response = await client.post(Uri.parse(url), headers: headers, body: isJSON ? json.encode(params) : params);
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 403) {
        return response;
      } else if (response.statusCode == 401) {
        await MyApp.shareUtils.setString(Constants.SharePreferencesKey, null);
        Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
                fullscreenDialog: true,
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                  return SplashPage();
                },
                transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                }),
            (_) => false);
        return null;
      } else {
        var data = json.decode(response.body);
        String message = data["message"].toString();
        throw new Exception(message);
      }
    } on SocketException catch (socketErr) {
      print("SocketException: $socketErr");
      return null;
    } on TimeoutException catch (timeErr) {
      print("TimeOutException : $timeErr");
      return null;
    } on Exception catch (err) {
      print("Error: $err");
      return null;
    } catch (catch_err) {
      print("Error: $catch_err");
      return null;
    }
  }

  static Future<http.Response> authGet(BuildContext context, http.Client client, String url, Map<String, String> headers) async {
    String tokenString = await MyApp.shareUtils.getString(Constants.SharePreferencesKey);
    if (Helper.checkEmptyToken(tokenString)) {
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
              fullscreenDialog: true,
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                return SplashPage();
              },
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              }),
          (_) => false);
      return null;
    }
    if (client == null) {
      client = new http.Client();
    }
    var token = json.decode(tokenString);
    headers.addAll({"Authorization": token["token_type"] + " " + token["access_token"], "accept": "application/json"});
    try {
      var response = await client.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401) {
        await MyApp.shareUtils.setString(Constants.SharePreferencesKey, null);
        Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
                fullscreenDialog: true,
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                  return SplashPage();
                },
                transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                }),
            (_) => false);
        return null;
      } else {
        return null;
      }
    } on SocketException catch (socketErr) {
      print("SocketException: $socketErr");
      return null;
    } on TimeoutException catch (timeErr) {
      print("TimeOutException : $timeErr");
      return null;
    } on Exception catch (err) {
      print("Error: $err");
      return null;
    } catch (catch_err) {
      print("Error: $catch_err");
      return null;
    }
  }

  static Future<http.Response> authDelete(String url, Map<String, String> headers) async {
    String tokenString = await MyApp.shareUtils.getString(Constants.SharePreferencesKey);
    if (Helper.checkEmptyToken(tokenString)) {
      return null;
    }
    var client = new http.Client();
    var token = json.decode(tokenString);
    headers.addAll({"Authorization": token["token_type"] + " " + token["access_token"], "accept": "application/json"});
    try {
      var response = await client.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else if (response.statusCode == 401) {
        await MyApp.shareUtils.setString(Constants.SharePreferencesKey, null);
        return null;
      } else {
        return null;
      }
    } on SocketException catch (socketErr) {
      print("SocketException: $socketErr");
      return null;
    } on TimeoutException catch (timeErr) {
      print("TimeOutException : $timeErr");
      return null;
    } on Exception catch (err) {
      print("Error: $err");
      return null;
    } catch (catch_err) {
      print("Error: $catch_err");
      return null;
    }
  }
}
