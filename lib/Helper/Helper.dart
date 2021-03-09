import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/main.dart';

import 'Constants.dart';

class Helper {
  static bool checkEmptyToken(String tokenString) {
    if (tokenString == null || tokenString == "") {
      return true;
    }
    return false;
  }

  static void showToast(String msg, bool success) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: success ? Colors.green : Colors.red, textColor: Colors.white, fontSize: 12);
  }

  static void copyClipBoard(String copy_val) async {
    final data = ClipboardData(text: copy_val);
    await Clipboard.setData(data);
    Helper.showToast("コピーされました。", true);
  }

  static void clipBoardWidget(String content, BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                  Helper.copyClipBoard(content);
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      Icon(Icons.content_copy),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  static void setMemberInfo(String plan, int id, String name, String email, int tracker, int deals, int achievelist, int wishlist, int purchasing, int purchased, bool rdb) {
    currentPlan = isLogin ? plan : null;
    memberId = id;
    memberName = name;
    memberEmail = email;
    maxTracker = tracker;
    maxDeals = deals;
    allowAchieveList = achievelist;
    allowWishList = wishlist;
    allowPurchasingList = purchasing;
    allowPurchasedList = purchased;
    allowRDB = rdb;
  }

  static String imageURL(String filename) {
    List<String> params = filename.split(".");
    return Constants.ImageURL + params[0] + ".SL160." + params[1];
  }

  static Future<String> getCategoryName(String cat_id) async {
    Map<String, dynamic> result = await DatabaseProvider.db.getCategory(cat_id);
    if (result == null) return "";
    return result['name'];
  }

  static bool isNullOrEmpty(String check) {
    if (["", null, false, 0].contains(check)) {
      return true;
    }
    return false;
  }

  static String formatDate(DateTime date, String format){
    return DateFormat(format).format(date);
  }
}
