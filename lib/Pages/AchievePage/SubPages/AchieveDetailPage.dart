import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/AchievePage/Model/AchieveModel.dart';
import 'package:monito/Pages/WebPages/WebPage.dart';
import 'package:monito/Widgets/LabelWidget.dart';
import 'package:monito/Widgets/LoadingButton.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/Widgets/ZoomOverlayWidget.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class AchieveDetailPage extends StatefulWidget {
  AchieveModel achieveModel;

  AchieveDetailPage({Key key, @required this.achieveModel}) : super(key: key);

  @override
  _AchieveDetailPageState createState() => _AchieveDetailPageState();
}

class _AchieveDetailPageState extends State<AchieveDetailPage> {
  bool _draggableContentWidget = false;
  bool _isLoading = false;

  _addPurchasing() async {
    if (allowPurchasingList > 0) {
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
      });
      String url = Constants.URL + "api/purchasing";
      var response = await HttpHelper.authPost(context, url, {'asin': widget.achieveModel.asin}, {}, false);
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            setState(() {
              _isLoading = false;
              widget.achieveModel.isAddPurchasedList = true;
            });
            Helper.showToast(LangHelper.SUCCESS, true);
          } else {
            _errorHandler();
          }
        } else {
          _errorHandler();
        }
      }
    } else {
      Helper.showToast("この機能を利用するためにはプランをアップグレードしてください。", false);
    }
  }

  _removePurchasing() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/purchasing?asin=" + widget.achieveModel.asin;
    var response = await HttpHelper.authDelete(url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          setState(() {
            _isLoading = false;
            widget.achieveModel.isAddPurchasedList = false;
          });
          Helper.showToast(LangHelper.SUCCESS, true);
        } else {
          _errorHandler();
        }
      } else {
        _errorHandler();
      }
    }
  }

  _errorHandler() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Helper.showToast(LangHelper.FAILED, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("商品情報", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Constants.BackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        30.height,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            height: 130,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10)),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Hero(
                                        tag: "achieve_image_" + widget.achieveModel.asin,
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                                          imageUrl: Helper.imageURL(widget.achieveModel.photo),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                10.width,
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 60,
                                          child: Hero(
                                            tag: "achieve_title_" + widget.achieveModel.asin,
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Text(
                                                  widget.achieveModel.title,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Colors.black, fontSize: 13.5, fontWeight: FontWeight.bold),
                                                  maxLines: 3,
                                                  softWrap: true,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(widget.achieveModel.category_name, style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                onLongPress: () {
                                                  Helper.clipBoardWidget(widget.achieveModel.asin, context);
                                                },
                                                child: Text(
                                                  "ASIN: ${widget.achieveModel.asin}",
                                                  style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "JAN: ${widget.achieveModel.jan}",
                                                  style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  Helper.formatDate(DateTime.parse(widget.achieveModel.created_at), 'yyyy-MM-dd'),
                                                  style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 10, color: Colors.black),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: LabelWidget(
                                  color: Constants.ButtonColor,
                                  label: "ランキング",
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    sprintf("%s位 → %s位", [widget.achieveModel.achieveWishListModel.last_sales_rank.formatter, widget.achieveModel.sales_rank.formatter]),
                                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(height: 10, color: Colors.black),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: LabelWidget(
                                  color: Constants.ButtonColor,
                                  label: "新品価格",
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    sprintf(
                                      "%s円 → %s円",
                                      widget.achieveModel.cart_price == -1
                                          ? [
                                              widget.achieveModel.last_new_price.formatter,
                                              widget.achieveModel.new_price.formatter,
                                            ]
                                          : [
                                              widget.achieveModel.last_cart_price.formatter,
                                              widget.achieveModel.cart_price.formatter,
                                            ],
                                    ),
                                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(height: 10, color: Colors.black),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: LabelWidget(
                                  color: Constants.ButtonColor,
                                  label: "新品出品者数",
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    sprintf("%s人", [widget.achieveModel.offers.formatter]),
                                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(height: 10, color: Colors.black),
                  InkWell(
                    onTap: () {
                      if (!_draggableContentWidget) {
                        setState(() {
                          _draggableContentWidget = true;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => SizedBox(
                            height: 150,
                            child: Center(
                              child: CupertinoActivityIndicator(radius: 10),
                            ),
                          ),
                          imageUrl: "https://graph.keepa.com/pricehistory.png?asin=" + widget.achieveModel.asin + "&domain=co.jp&salesrank=1&width=600&height=200&range=90",
                          errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 10, color: Colors.black),
                  SizedBox(
                    height: 60,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: LoadingButton(
                              color: Constants.ButtonColor,
                              disabled: false,
                              loading: false,
                              title: "出品制限",
                              fontColor: Colors.white,
                              fontSize: 15,
                              loadingColor: Colors.black,
                              loadingSize: 20,
                              borderRadius: 10,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: WebPage(
                                          url: "https://sellercentral.amazon.co.jp/product-search/search?q=${widget.achieveModel.asin}&ref_=xx_addlisting_dnav_home",
                                        ),
                                        type: PageTransitionType.bottomToTop,
                                        inheritTheme: true,
                                        curve: Curves.easeIn,
                                        ctx: context));
                              },
                            ),
                          ),
                          20.width,
                          Expanded(
                            flex: 1,
                            child: LoadingButton(
                              color: Constants.ButtonColor,
                              disabled: _isLoading,
                              loading: _isLoading,
                              title: widget.achieveModel.isAddPurchasedList ? "登録解除" : "仕入れ予定",
                              fontColor: Colors.white,
                              fontSize: 15,
                              loadingColor: Colors.black,
                              loadingSize: 20,
                              borderRadius: 10,
                              onPressed: () {
                                if (widget.achieveModel.isAddPurchasedList) {
                                  _removePurchasing();
                                } else {
                                  _addPurchasing();
                                }
                              },
                            ),
                          ),
                          20.width,
                          Expanded(
                            flex: 1,
                            child: LoadingButton(
                              color: Constants.ButtonColor,
                              disabled: false,
                              loading: false,
                              title: "Amazon",
                              fontColor: Colors.white,
                              fontSize: 15,
                              loadingColor: Colors.black,
                              loadingSize: 20,
                              borderRadius: 10,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: WebPage(
                                          url: Constants.AmazonURL + widget.achieveModel.asin,
                                        ),
                                        type: PageTransitionType.bottomToTop,
                                        inheritTheme: true,
                                        curve: Curves.easeIn,
                                        ctx: context));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildDraggableContentWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableContentWidget() {
    return Visibility(
      visible: _draggableContentWidget,
      child: Container(
        child: SizedBox(
          width: double.infinity,
          height: 300,
          child: Stack(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 69, 78, 86),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          setState(() {
                            _draggableContentWidget = false;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                color: Colors.white,
                child: ZoomOverlayWidget(asin: widget.achieveModel.asin),
              )
            ],
          ),
        ),
      ),
    );
  }
}
