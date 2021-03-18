import 'package:flutter/material.dart';

class Constants {
  static const SharePreferencesKey = "token_string";

  // static const URL = "http://192.168.31.200/fastalert/public/";
  // static const client_secret = "zSf198GJMDj6qey7sD6d4nayhmvlB8z25WwFvCjy";
  static const URL = "https://umc-monito.com/";
  static const client_secret = "qUHRHY9TzZfi0Nlcxv3abbwgLL3Svf0zicCP6kRv";
  static const AmazonURL = "https://www.amazon.co.jp/dp/";
  static const grant_type_password = "password";
  static const client_id = "2";
  static const scope = "*";
  static const KeepaURL = "https://keepa.com/iframe_addon.html#5-0-";
  static const ImageURL = "https://images-na.ssl-images-amazon.com/images/I/";

  //Color Constants
  static const Color BackgroundColor = Colors.white;
  static const Color PrimaryColor = Color.fromARGB(255, 127, 127, 127);
  static const Color SecondaryColor = Colors.grey;
  static const Color PrimaryTextColor = Colors.black12;
  static const Color SecondaryTextColor = Colors.white;
  static const Color StatusBarColor = Color(0xFF131d25);
  static const Color ButtonColor = Color(0xFF131d25);

  static const double StatusBarHeight = 50;

  //Page Constants
  static const int RankInPage = 1;
  static const int ConditionPage = 2;
  static const int FavoritePage = 3;
  static const int PurchasingPage = 4;
  static const int PurchasedPage = 5;
  static const int SettingPage = 6;
  static const int RDBPurchasingPage = 7;
  static const int RDBPurchasedPage = 8;

  //UnAuth User info
  static const UnAuthTrackCategoryKey = "track_category_key";
  static const UnAuthTrackRankingKey = "track_ranking_key";

  //Page Transition Time milliseconds
  static const int TransitionTime = 200;
}
