import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class WidgetHelper{
  static const int WEB_PAGE_LOADING = 0;
  static const int WEB_PAGE_LOADED = 1;
  static const int WEB_PAGE_ERROR = 2;

  static Widget buildWebStateWidget(int webPageState){
    Widget result;
    switch(webPageState){
      case WidgetHelper.WEB_PAGE_LOADING: //Loading
        result = Positioned.fill(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            child: CupertinoActivityIndicator(
              radius: 15,
            ),
          ),
        );
        break;
      case WidgetHelper.WEB_PAGE_LOADED: //Loaded
      return Container();
//        result = Positioned.fill(
//          child: Container(
//            decoration: BoxDecoration(color: Colors.white),
//            alignment: Alignment.center,
//            child: Text("一度タブを閉じて再度開いてください", style: TextStyle(color: Constants.fontColor, fontSize: ScreenUtil().setSp(30), fontWeight: FontWeight.bold),),
//          ),
        //);
        break;
      case WidgetHelper.WEB_PAGE_ERROR: //Error
        result = Positioned.fill(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            child: Text("該当するデータがありません。", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
          ),
        );
        break;
    }
    return result;
  }
}