import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/RankInPage/Model/RankModel.dart';
import 'package:monito/Pages/WebPages/WebPage.dart';
import 'package:monito/Widgets/LabelWidget.dart';
import 'package:monito/Widgets/LoadingButton.dart';
import 'package:monito/Widgets/RoundLabel.dart';
import 'package:monito/Widgets/ZoomOverlayWidget.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';

class RankDetailPage extends StatefulWidget {
  RankModel rankModel;

  RankDetailPage({Key key, @required this.rankModel}) : super(key: key);

  @override
  _RankDetailPageState createState() => _RankDetailPageState();
}

class _RankDetailPageState extends State<RankDetailPage> {
  bool _draggableContentWidget = false;
  bool _isLoading = false;
  bool acknowledged = false;

  @override
  void initState() {
    super.initState();
    if (widget.rankModel.acknowledged_at == null) {
      _syncAcknowledged();
    }
  }

  _syncAcknowledged() async {
    if (acknowledged) return;
    setState(() {
      acknowledged = true;
    });

    //rankin/{id}/acknowledge
    String url = sprintf("%sapi/rankin/%d/acknowledge", [Constants.URL, widget.rankModel.id]);
    print(url);
    var response = await HttpHelper.authPost(context, url, {}, {}, false);
    if (mounted) {
      acknowledged = false;
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          widget.rankModel.acknowledged_at = "true";
        }
      }
      setState(() {});
    }
  }

  _addFavorite() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/wishlist";
    var response = await HttpHelper.authPost(context, url, {'asin': widget.rankModel.asin}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          setState(() {
            _isLoading = false;
            widget.rankModel.isFavorite = true;
          });
          Helper.showToast(LangHelper.SUCCESS, true);
        } else {
          if ((result['code'] is int ? result['code'] : int.parse(result['code'])) == 406) {
            _errorHandler(message: "Your wishlist is limited");
          } else {
            _errorHandler();
          }
        }
      } else {
        _errorHandler();
      }
    }
  }

  _removeFavorite() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/wishlist?asin=" + widget.rankModel.asin;
    var response = await HttpHelper.authDelete(url, {});
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          setState(() {
            _isLoading = false;
            widget.rankModel.isFavorite = false;
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
            Positioned.fill(
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
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10)),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Hero(
                                          tag: "rank_image_" + widget.rankModel.asin,
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                                            imageUrl: Helper.imageURL(widget.rankModel.photo),
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
                                              tag: "rank_title_" + widget.rankModel.asin,
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                child: Material(
                                                  type: MaterialType.transparency,
                                                  child: Text(
                                                    widget.rankModel.title,
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
                                              child: Text(widget.rankModel.category_name, style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Material(
                                                    color: Colors.white,
                                                    child: InkWell(
                                                      onLongPress: () {
                                                        Helper.clipBoardWidget(widget.rankModel.asin, context);
                                                      },
                                                      child: Text(
                                                        "ASIN: ${widget.rankModel.asin}",
                                                        style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                  acknowledged
                                                      ? SpinKitThreeBounce(color: Colors.blue, size: 10)
                                                      : (widget.rankModel.acknowledged_at == null
                                                          ? Container()
                                                          : RoundLabel(
                                                              label: "確認済",
                                                              fontSize: 10,
                                                              height: 18,
                                                              backgroundColor: Colors.lightBlueAccent,
                                                              size: 10,
                                                            ))
                                                ],
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
                                                    "JAN: ${widget.rankModel.jan}",
                                                    style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    Helper.formatDate(DateTime.parse(widget.rankModel.ranked_at), 'yyyy-MM-dd'),
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
                                      sprintf("%s位 → %s位", [widget.rankModel.sales_rank_at_rankin.formatter, widget.rankModel.sales_rank.formatter]),
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
                                      sprintf("%s円", [widget.rankModel.cart_price == -1 ? widget.rankModel.new_price.formatter : widget.rankModel.cart_price.formatter]),
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
                                      sprintf("%s人", [widget.rankModel.offers.formatter]),
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
                            imageUrl: "https://graph.keepa.com/pricehistory.png?asin=" + widget.rankModel.asin + "&domain=co.jp&salesrank=1&width=600&height=200&range=90",
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
                                            url: "https://sellercentral.amazon.co.jp/product-search/search?q=${widget.rankModel.asin}&ref_=xx_addlisting_dnav_home",
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
                                title: widget.rankModel.isFavorite ? "登録解除" : "お気に入り",
                                fontColor: Colors.white,
                                fontSize: 15,
                                loadingColor: Colors.black,
                                loadingSize: 20,
                                borderRadius: 10,
                                onPressed: () {
                                  if (widget.rankModel.isFavorite) {
                                    _removeFavorite();
                                  } else {
                                    _addFavorite();
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
                                            url: Constants.AmazonURL + widget.rankModel.asin,
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
                child: ZoomOverlayWidget(asin: widget.rankModel.asin),
              )
            ],
          ),
        ),
      ),
    );
  }
}
