import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monito/Helper/Helper.dart';
import 'package:monito/Pages/SearchPage/Model/SearchModel.dart';
import 'package:monito/Helper/IntExtensions.dart';
import 'package:monito/main.dart';
import 'package:sprintf/sprintf.dart';

class SearchListItem extends StatelessWidget {
  final SearchModel searchModel;
  final VoidCallback onPressed;

  const SearchListItem({@required this.searchModel, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5.0, offset: const Offset(0.0, 5.0)),
        ],
      ),
      child: Material(
        child: InkWell(
          onTap: onPressed,
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
                      tag: 'search_image_${searchModel.asin}',
                      child: CachedNetworkImage(
                        placeholder: (context, url) => CupertinoActivityIndicator(radius: 10),
                        errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                        imageUrl: searchModel.photo,
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
                        tag: "search_title_" + searchModel.asin,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              searchModel.title ?? "",
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Text("ASIN: ${searchModel.asin}", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("JAN: ${Helper.isNullOrEmpty(searchModel.jan) ? "--" : searchModel.jan}", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sprintf("%s位", [searchModel.sales_rank.formatter]),
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            searchModel.category_name,
                            style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
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
