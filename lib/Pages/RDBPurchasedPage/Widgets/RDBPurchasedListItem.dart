import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Pages/RDBPurchasedPage/Model/RDBPurchasedModel.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:sprintf/sprintf.dart';

class RDBPurchasedListItem extends StatelessWidget {
  final RDBPurchasedModel rdbPurchasedModel;
  final VoidCallback onPressed;

  RDBPurchasedListItem({@required this.rdbPurchasedModel, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5.0, offset: const Offset(0.0, 5.0)),
        ],
      ),
      child: Material(
        child: InkWell(
          onTap: () {
            onPressed();
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10), color: Colors.white),
                  padding: EdgeInsets.all(3),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'rdb_purchased_image_${rdbPurchasedModel.id}',
                      child: CachedNetworkImage(
                        placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                        errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                        imageUrl: Helper.imageURL(rdbPurchasedModel.photo),
                      ),
                    ),
                  ),
                ),
                10.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: "rdb_purchased_title_${rdbPurchasedModel.id}",
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              rdbPurchasedModel.title ?? "",
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Text("ASIN: ${rdbPurchasedModel.asin}", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                      Helper.isNullOrEmpty(rdbPurchasedModel.jan) ? Container() : Text("JAN: ${rdbPurchasedModel.jan}", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sprintf("%s位", [rdbPurchasedModel.sales_rank.formatter]),
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            sprintf("%s円", [rdbPurchasedModel.cart_price == -1 ? rdbPurchasedModel.new_price.formatter : rdbPurchasedModel.cart_price.formatter]),
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Text("リスト追加件数: ${rdbPurchasedModel.purchased.formatter}件", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
