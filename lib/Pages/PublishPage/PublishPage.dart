import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monito/Database/DatabaseProvider.dart';
import 'package:monito/Helper/Constants.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Helper/HttpHelper.dart';
import 'package:monito/Helper/LangHelper.dart';
import 'package:monito/Pages/PurchasingPage/Model/PurchasingModel.dart';
import 'package:monito/Pages/SettingPage/Model/SupplierModel.dart';
import 'package:monito/Pages/WebPages/WebPage.dart';
import 'package:monito/Widgets/LabelWidget.dart';
import 'package:monito/Widgets/LoadingButton.dart';
import 'package:monito/Widgets/ZoomOverlayWidget.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:page_transition/page_transition.dart';

import 'Formatter/CurrencyInputFormatter.dart';

class PublishPage extends StatefulWidget {
  final PurchasingModel purchasingModel;

  PublishPage({Key key, @required this.purchasingModel});

  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider.db;
  List<SupplierModel> suppliers = [];
  bool _isLoading = false;
  bool _draggableContentWidget = false;
  int currentSupplier = 0;

  final buyPriceController = TextEditingController();
  FocusNode buyPriceNode;

  @override
  void initState() {
    super.initState();
    currentSupplier = 0;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    buyPriceNode = FocusNode();
    buyPriceNode.addListener(() {
      if (buyPriceNode.hasFocus) {
        if (buyPriceController.text.length > 0) {
          buyPriceController.selection = TextSelection(baseOffset: 0, extentOffset: buyPriceController.text.length);
        }
      }
    });
    _init();
  }

  _init() async {
    List<Map<String, dynamic>> temps = await _databaseProvider.getAllSuppliers();
    suppliers.add(SupplierModel(0, ""));
    for (var item in temps) {
      suppliers.add(SupplierModel.fromJson(item));
    }
    buyPriceController.text = "0";
    setState(() {});
  }

  @override
  void dispose() {
    buyPriceController?.dispose();
    buyPriceNode?.dispose();
    super.dispose();
  }

  _publish() async {
    if (_isLoading) return;
    String price = buyPriceController.text.trim().replaceAll(",", "");
    if (Helper.isNullOrEmpty(price) || int.parse(price) == 0) {
      Helper.showToast("仕入れ価格を入力してください。", false);
      return;
    }
    /*if (currentSupplier == 0) {
      Helper.showToast("仕入れ先を選択してください。", false);
      return;
    }*/

    setState(() {
      _isLoading = true;
    });
    String url = Constants.URL + "api/purchased";
    var response = await HttpHelper.authPost(context, url, {'asin': widget.purchasingModel.asin, 'cost_price': price, 'supplier': currentSupplier.toString()}, {}, false);
    if (mounted) {
      if (response != null) {
        var result = json.decode(response.body);
        if (result['result'] == "success") {
          setState(() {
            _isLoading = false;
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.StatusBarColor,
        title: Text("仕入れ情報", style: TextStyle(color: Colors.white)),
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
                                    decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10), color: Colors.white),
                                    padding: EdgeInsets.all(3),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                                        imageUrl: Helper.imageURL(widget.purchasingModel.photo),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.error,
                                          color: Colors.red,
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
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              widget.purchasingModel.title,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Colors.black, fontSize: 13.5, fontWeight: FontWeight.bold),
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(widget.purchasingModel.category_name, style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
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
                                                  Helper.clipBoardWidget(widget.purchasingModel.asin, context);
                                                },
                                                child: Text(
                                                  "ASIN: ${widget.purchasingModel.asin}",
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
                                                  "JAN: ${widget.purchasingModel.jan}",
                                                  style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  Helper.formatDate(DateTime.parse(widget.purchasingModel.created_at), 'yyyy-MM-dd'),
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
                                  label: "仕入れ価格",
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 20),
                                  child: TextFormField(
                                    controller: buyPriceController,
                                    focusNode: buyPriceNode,
                                    textAlign: TextAlign.end,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black, width: 0.5)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black, width: 0.5),
                                      ),
                                    ),
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
                                  label: "仕入れ先",
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), borderRadius: BorderRadius.circular(4)),
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(left: 20),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: DropdownButton(
                                    underline: Container(),
                                    isExpanded: true,
                                    items: suppliers.map((SupplierModel e) {
                                      return new DropdownMenuItem(
                                        child: Text(e.name),
                                        value: e.id,
                                      );
                                    }).toList(),
                                    value: currentSupplier,
                                    onChanged: (value) {
                                      setState(() {
                                        currentSupplier = value;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
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
                          imageUrl: "https://graph.keepa.com/pricehistory.png?asin=" + widget.purchasingModel.asin + "&domain=co.jp&salesrank=1&width=600&height=200&range=90",
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
                                          url: "https://sellercentral.amazon.co.jp/product-search/search?q=${widget.purchasingModel.asin}&ref_=xx_addlisting_dnav_home",
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
                              title: "仕入れ済み",
                              fontColor: Colors.white,
                              fontSize: 15,
                              loadingColor: Colors.black,
                              loadingSize: 20,
                              borderRadius: 10,
                              onPressed: () {
                                _publish();
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
                                          url: Constants.AmazonURL + widget.purchasingModel.asin,
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
                child: ZoomOverlayWidget(asin: widget.purchasingModel.asin),
              )
            ],
          ),
        ),
      ),
    );
  }
}
