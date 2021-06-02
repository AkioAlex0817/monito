import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/AchievePage/AchievePage.dart';
import 'package:monito/Pages/FavoritePage/FavoritePage.dart';
import 'package:monito/Pages/MainPage/Widgets/GridButton.dart';
import 'package:monito/Pages/PurchasedPage/PurchasedPage.dart';
import 'package:monito/Pages/PurchasingPage/PurchasingPage.dart';
import 'package:monito/Pages/RDBPurchasedPage/RDBPurchasedPage.dart';
import 'package:monito/Pages/RDBPurchasingPage/RDBPurchasingPage.dart';
import 'package:monito/Pages/RankInPage/RankInPage.dart';
import 'package:monito/Pages/SettingPage/OnlineSettingPage.dart';
import 'package:monito/Pages/SettingPage/Widgets/SettingListItem.dart';
import 'package:monito/Pages/UserSetting/PasswordUpdatePage.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monito/Helper/IntExtensions.dart';

class MainPage extends StatefulWidget {
  final int initPage;

  MainPage({this.initPage});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  PageController pageController;
  var isSelected = 2;

  @override
  void initState() {
    super.initState();
    this.pageController = PageController(initialPage: 1);
    setState(() {});
    if (widget.initPage != null) {
      Timer(Duration(milliseconds: 50), () => _switchPage(widget.initPage));
    }
    _initBackgroundSetting();
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  Future<void> _initBackgroundSetting() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.ANY,
        ), (String taskID) async {
      print("Background Job Started");
      DatabaseProvider databaseProvider = DatabaseProvider.db;
      int targetTimeStamp = DateTime.now().subtract(Duration(minutes: 15)).microsecondsSinceEpoch;
      List<Map<String, dynamic>> expiredNotifications = await databaseProvider.getExpiredNotifications(targetTimeStamp);
      if (expiredNotifications.length > 0) {
        expiredNotifications.map((item) {
          try {
            MyApp.flutterLocalNotificationsPlugin.cancel(int.parse(item['id']));
          } catch (_) {}
        });
        await databaseProvider.removeExpiredNotifications(targetTimeStamp);
      }
      BackgroundFetch.finish(taskID);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {});
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {});
    });
    setState(() {});

    if (!mounted) return;
  }

  Widget tabItem(var pos, var icon, var name) {
    return GestureDetector(
      onTap: () {
        switch (pos) {
          case 1:
            if (this.pageController.page != 0) {
              if (this.pageController.page == 2) {
                this.pageController.jumpToPage(0);
              } else {
                this.pageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
              }
            }
            setState(() {
              isSelected = pos;
            });
            break;
          case 2:
            if (this.pageController.page != 1) {
              this.pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            }
            setState(() {
              isSelected = pos;
            });
            break;
          case 3:
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text("サインアウトしてもよろしいでしょうか？"),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(LangHelper.YES),
                      onPressed: () async {
                        await MyApp.shareUtils.setString(Constants.SharePreferencesKey, null);
                        await _databaseProvider.removeUserSetting();
                        await _databaseProvider.removeAllCategory();
                        await _databaseProvider.removeAllSuppliers();
                        Navigator.of(context, rootNavigator: true).pop("Discard");
                        //MyApp.firebaseMessaging.deleteInstanceID();
                        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text(LangHelper.NO),
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop("Discard");
                      },
                    )
                  ],
                );
              },
            );
            break;
        }
      },
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Container(
          alignment: Alignment.center,
          decoration: isSelected == pos ? BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(8)) : BoxDecoration(),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  color: isSelected == pos ? Color(0xFF1D2939) : Colors.white,
                ),
                Text(name, style: TextStyle(color: isSelected == pos ? Color(0xFF1D2939) : Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _switchPage(int page) async {
    switch (page) {
      case Constants.RankInPage:
        Map<String, dynamic> userSetting = await _databaseProvider.getUserSetting(memberId);
        if (userSetting == null || Helper.isNullOrEmpty(userSetting['keepa_api_key'])) {
          _emptySettingHandler();
          return;
        }
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: RankInPage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        break;
      case Constants.ConditionPage:
        Map<String, dynamic> userSetting = await _databaseProvider.getUserSetting(memberId);
        if (userSetting == null || Helper.isNullOrEmpty(userSetting['keepa_api_key'])) {
          _emptySettingHandler();
          return;
        }
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: AchievePage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        break;
      case Constants.FavoritePage:
        Map<String, dynamic> userSetting = await _databaseProvider.getUserSetting(memberId);
        if (userSetting == null || Helper.isNullOrEmpty(userSetting['keepa_api_key'])) {
          _emptySettingHandler();
          return;
        }
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: FavoritePage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        break;
      case Constants.PurchasingPage:
        if (allowPurchasingList > 0) {
          Map<String, dynamic> userSetting = await _databaseProvider.getUserSetting(memberId);
          if (userSetting == null || Helper.isNullOrEmpty(userSetting['keepa_api_key'])) {
            _emptySettingHandler();
            return;
          }
          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: PurchasingPage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        } else {
          Helper.showToast("この機能を利用するためにはプランをアップグレードしてください。", false);
        }
        break;
      case Constants.PurchasedPage:
        if (allowPurchasedList > 0) {
          Map<String, dynamic> userSetting = await _databaseProvider.getUserSetting(memberId);
          if (userSetting == null || Helper.isNullOrEmpty(userSetting['keepa_api_key'])) {
            _emptySettingHandler();
            return;
          }
          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: PurchasedPage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        } else {
          Helper.showToast("この機能を利用するためにはプランをアップグレードしてください。", false);
        }
        break;
      case Constants.SettingPage:
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: OnlineSettingPage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        break;
      case Constants.RDBPurchasingPage:
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: RDBPurchasingPage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        break;
      case Constants.RDBPurchasedPage:
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: RDBPurchasedPage(), inheritTheme: true, curve: Curves.easeIn, ctx: context));
        break;
    }
  }

  _emptySettingHandler() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("まだアプリの設定が行われていません。"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(LangHelper.YES),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop("Discard");
                _switchPage(Constants.SettingPage);
              },
            ),
            CupertinoDialogAction(
              child: Text(LangHelper.NO),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop("Discard");
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> _backHandler() async {
    if (this.pageController.page == 0 || this.pageController.page == 2) {
      this.pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      setState(() {
        isSelected = 2;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _backHandler,
      child: Scaffold(
        backgroundColor: Constants.BackgroundColor,
        bottomNavigationBar: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(16),
              height: 70,
              decoration: BoxDecoration(
                color: Color(0xFF1D2939),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: tabItem(1, "assets/user.png", "アカウント"),
                    flex: 1,
                  ),
                  Flexible(
                    child: tabItem(2, "assets/dashboard.png", "アプリ情報"),
                    flex: 1,
                  ),
                  Flexible(
                    child: tabItem(3, "assets/logout.png", "ログアウト"),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: PageView.builder(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, int index) {
              switch (index) {
                case 0:
                  return Container(
                    child: Column(
                      children: [
                        AppBar(
                          centerTitle: true,
                          backgroundColor: Constants.StatusBarColor,
                          title: Text("アカウント", style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SettingListItem(
                                  menuTitle: "パスワード変更",
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                          child: PasswordUpdatePage(),
                                          type: PageTransitionType.rightToLeft,
                                          duration: Duration(milliseconds: Constants.TransitionTime),
                                          reverseDuration: Duration(milliseconds: Constants.TransitionTime),
                                          curve: Curves.easeIn,
                                          ctx: context,
                                          inheritTheme: true,
                                        ));
                                  },
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                  break;
                case 1:
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GridButton(
                                            width: width / 4,
                                            height: width / 4,
                                            borderRadius: 12,
                                            asset: "assets/ranking.png",
                                            title: "ランクイン",
                                            onPressed: () {
                                              _switchPage(Constants.RankInPage);
                                            }),
                                        50.width,
                                        GridButton(
                                            width: width / 4,
                                            height: width / 4,
                                            borderRadius: 12,
                                            asset: "assets/archive.png",
                                            title: "条件達成",
                                            onPressed: () {
                                              _switchPage(Constants.ConditionPage);
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                                20.height,
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GridButton(
                                            width: width / 4,
                                            height: width / 4,
                                            borderRadius: 12,
                                            asset: "assets/favorite.png",
                                            title: "お気に入り",
                                            onPressed: () {
                                              _switchPage(Constants.FavoritePage);
                                            }),
                                        50.width,
                                        GridButton(
                                            width: width / 4,
                                            height: width / 4,
                                            borderRadius: 12,
                                            asset: "assets/purchasing.png",
                                            title: "仕入れ予定",
                                            onPressed: () {
                                              _switchPage(Constants.PurchasingPage);
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                                20.height,
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GridButton(
                                            width: width / 4,
                                            height: width / 4,
                                            borderRadius: 12,
                                            asset: "assets/purchased.png",
                                            title: "仕入れ済み",
                                            onPressed: () {
                                              _switchPage(Constants.PurchasedPage);
                                            }),
                                        50.width,
                                        GridButton(
                                            width: width / 4,
                                            height: width / 4,
                                            borderRadius: 12,
                                            asset: "assets/settings.png",
                                            title: "設定",
                                            onPressed: () {
                                              _switchPage(Constants.SettingPage);
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                                20.height,
                                Flexible(
                                  flex: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Material(
                                      color: Color(0xFF1D2939),
                                      child: InkWell(
                                        onTap: allowRDB
                                            ? () {
                                                this.pageController.animateToPage(2, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                              }
                                            : null,
                                        child: SizedBox(
                                          width: width / 2 + 50,
                                          height: width / 4,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "RDB",
                                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                "PRO版のみご利用いただけます",
                                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                  break;
                case 2:
                  return Container(
                    constraints: BoxConstraints.expand(),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Material(
                                    color: Color(0xFF1D2939),
                                    child: InkWell(
                                      onTap: () {
                                        _switchPage(Constants.RDBPurchasingPage);
                                      },
                                      child: SizedBox(
                                        width: width / 2 + 50,
                                        height: width / 4,
                                        child: Center(
                                          child: Text(
                                            "仕入れ予定RDB",
                                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              30.height,
                              Flexible(
                                flex: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Material(
                                    color: Color(0xFF1D2939),
                                    child: InkWell(
                                      onTap: () {
                                        _switchPage(Constants.RDBPurchasedPage);
                                      },
                                      child: SizedBox(
                                        width: width / 2 + 50,
                                        height: width / 4,
                                        child: Center(
                                          child: Text(
                                            "仕入れ済みRDB",
                                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
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
                                    this.pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                  },
                                ),
                              ),
                            ))
                      ],
                    ),
                  );
                  break;
                default:
                  return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
