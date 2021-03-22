import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Pages/RankInPage/Model/RankModel.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/main.dart';
import 'package:sprintf/sprintf.dart';

class RankListItem extends StatelessWidget {
  final RankModel rankModel;
  final VoidCallback onPressed;

  RankListItem({@required this.rankModel, @required this.onPressed});

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
                      tag: 'rank_image_' + rankModel.asin,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                        errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                        imageUrl: Helper.imageURL(rankModel.photo),
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
                        tag: "rank_title_" + rankModel.asin,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              rankModel.title,
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Text("ASIN: ${rankModel.asin}", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                      Helper.isNullOrEmpty(rankModel.jan) ? Container() : Text("JAN: ${rankModel.jan}", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sprintf("%s位", [currency.format(rankModel.sales_rank)]),
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            rankModel.category_name,
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Text(Helper.formatDate(DateTime.parse(rankModel.ranked_at), 'yyyy-MM-dd'), style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
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
