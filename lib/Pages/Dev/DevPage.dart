import 'package:flutter/material.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/main.dart';

class DevPage extends StatefulWidget {
  @override
  _DevPageState createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;

  sendUserInfo() async {
    Map<String, dynamic> userSetting = await _databaseProvider.getUserSetting(memberId);
    if (userSetting == null) {
      showUserInfo("User info is null");
      return;
    }
    if (Helper.isNullOrEmpty(userSetting['keepa_api_key'])) {
      showUserInfo("User info keep api key is wrong");
      return;
    }
    showUserInfo("User info is ok");
  }

  showUserInfo(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Plan: $currentPlan"),
                Text("MemberID: ${memberId.toString()}"),
                Text("MemberName: $memberName"),
                Text("MemberEmail: $memberEmail"),
                Text("MaxTracker: ${maxTracker.toString()}"),
                Text("MaxDeals: ${maxDeals.toString()}"),
                Text("AllowAchieveList: ${allowAchieveList.toString()}"),
                Text("AllowWishList: ${allowWishList.toString()}"),
                Text("AllowPurchasingList: ${allowPurchasingList.toString()}"),
                Text("AllowPurchasedList: ${allowPurchasedList.toString()}"),
                Text("AllowRDB: ${allowRDB ? 'Yes' : 'No'}"),
                Text("DeviceToken: $deviceToken"),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dev view")),
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text("Dev Button"),
                  onTap: () {
                    sendUserInfo();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
