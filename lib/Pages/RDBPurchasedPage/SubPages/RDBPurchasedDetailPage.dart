import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:flutter/material.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/RDBPurchasedPage/Model/RDBPurchasedDetailModel.dart';
import 'package:monito/Pages/RDBPurchasedPage/Model/RDBPurchasedModel.dart';
import 'package:monito/Pages/WebPages/WebPage.dart';
import 'package:monito/Widgets/LabelWidget.dart';
import 'package:monito/Widgets/Loading.dart';
import 'package:monito/Widgets/LoadingButton.dart';
import 'package:monito/Widgets/ZoomOverlayWidget.dart';
import 'package:monito/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class RDBPurchasedDetailPage extends StatefulWidget {
  RDBPurchasedModel rdbPurchasedModel;

  RDBPurchasedDetailPage({Key key, @required this.rdbPurchasedModel}) : super(key: key);

  @override
  _RDBPurchasedDetailPageState createState() => _RDBPurchasedDetailPageState();
}

class _RDBPurchasedDetailPageState extends State<RDBPurchasedDetailPage> {
  bool _draggableContentWidget = false;
  bool _isLoading = false;
  bool _isPageLoading = false;
  bool _isError = false;
  RDBPurchasedDetailModel rdbPurchasedDetailModel;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: Constants.TransitionTime), () => _init());
  }

  _init() async {
    setState(() {
      _isPageLoading = true;
      _isError = false;
    });
    String url = Constants.URL + "api/rdb/purchased/" + widget.rdbPurchasedModel.asin;
    var response = await HttpHelper.authGet(context, null, url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          rdbPurchasedDetailModel = RDBPurchasedDetailModel.fromJson(result['data']);
          setState(() {
            _isPageLoading = false;
          });
        } else {
          _errorPageHandler();
        }
      } else {
        _errorPageHandler();
      }
    }
  }

  _errorPageHandler() {
    if (mounted) {
      setState(() {
        _isPageLoading = false;
        _isError = true;
      });
    }
  }

  _addPurchasing() async {
    if (allowPurchasingList > 0) {
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
      });
      String url = Constants.URL + "api/purchasing";
      var response = await HttpHelper.authPost(context, url, {'asin': widget.rdbPurchasedModel.asin}, {}, false);
      if (mounted) {
        if (response != null) {
          var result = json.decode(response.body);
          if (result['result'] == "success") {
            setState(() {
              _isLoading = false;
              widget.rdbPurchasedModel.isPurchasing = true;
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
    String url = Constants.URL + "api/purchasing?asin=" + widget.rdbPurchasedModel.asin;
    var response = await HttpHelper.authDelete(url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          setState(() {
            _isLoading = false;
            widget.rdbPurchasedModel.isPurchasing = false;
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

  _errorHandler({message = LangHelper.FAILED}) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Helper.showToast(message, false);
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
            _isError
                ? Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("エラー!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : Positioned.fill(
                    child: SingleChildScrollView(
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
                                            decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10), color: Colors.white),
                                            padding: EdgeInsets.all(3),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Hero(
                                                tag: "rdb_purchased_image_${widget.rdbPurchasedModel.id}",
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                                                  imageUrl: Helper.imageURL(widget.rdbPurchasedModel.photo),
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
                                                    tag: "rdb_purchased_title_${widget.rdbPurchasedModel.id}",
                                                    child: Container(
                                                      alignment: Alignment.topLeft,
                                                      child: Material(
                                                        type: MaterialType.transparency,
                                                        child: Text(
                                                          widget.rdbPurchasedModel.title ?? "",
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
                                                    child: Text(widget.rdbPurchasedModel.category_name, style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
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
                                                          Helper.clipBoardWidget(widget.rdbPurchasedModel.asin, context);
                                                        },
                                                        child: Text(
                                                          "ASIN: ${widget.rdbPurchasedModel.asin}",
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
                                                          "JAN: ${widget.rdbPurchasedModel.jan}",
                                                          style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(
                                                          "リスト追加件数: ${widget.rdbPurchasedModel.purchased.formatter}件",
                                                          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
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
                                            sprintf("%s位", [widget.rdbPurchasedModel.sales_rank.formatter]),
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
                                            sprintf("%s円", [widget.rdbPurchasedModel.cart_price == -1 ? widget.rdbPurchasedModel.new_price.formatter : widget.rdbPurchasedModel.cart_price.formatter]),
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
                                            sprintf("%s人", [widget.rdbPurchasedModel.offers.formatter]),
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
                                          label: "平均仕入れ価格",
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            sprintf("%s円", [rdbPurchasedDetailModel == null ? "--" : rdbPurchasedDetailModel.avg_price.formatter]),
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
                                  imageUrl: "https://graph.keepa.com/pricehistory.png?asin=" + widget.rdbPurchasedModel.asin + "&domain=co.jp&salesrank=1&width=600&height=200&range=90",
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
                                                  url: "https://sellercentral.amazon.co.jp/product-search/search?q=${widget.rdbPurchasedModel.asin}&ref_=xx_addlisting_dnav_home",
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
                                      title: widget.rdbPurchasedModel.isPurchasing ? "登録解除" : "仕入れ予定",
                                      fontColor: Colors.white,
                                      fontSize: 15,
                                      loadingColor: Colors.black,
                                      loadingSize: 20,
                                      borderRadius: 10,
                                      onPressed: () {
                                        if (widget.rdbPurchasedModel.isPurchasing) {
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
                                                  url: Constants.AmazonURL + widget.rdbPurchasedModel.asin,
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
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildDraggableContentWidget(),
            ),
            _isPageLoading ? Positioned.fill(child: Loading()) : Container()
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
                child: ZoomOverlayWidget(asin: widget.rdbPurchasedModel.asin),
              )
            ],
          ),
        ),
      ),
    );
  }
}
