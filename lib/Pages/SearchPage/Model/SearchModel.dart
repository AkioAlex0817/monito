class SearchModel {
  String asin;
  String cat_id;
  String title;
  String photo;
  String jan;
  String product_group;
  int amazon_price;
  int new_price;
  int used_price;
  int sales_rank;
  bool has_amazon_offer;
  bool isFavorite;
  String category_name;

  SearchModel.fromJson(Map<String, dynamic> json) {
    asin = json["asin"];
    cat_id = json['cat_id'].toString();
    title = json["title"];
    photo = json["photo"];
    jan = json["jan"];
    product_group = json["product_group"];
    amazon_price = json["amazon_price"];
    new_price = json["new_price"];
    used_price = json["used_price"];
    sales_rank = json["sales_rank"];
    has_amazon_offer = json['has_amazon_offer'];
    isFavorite = false;
    category_name = json['category_name'];
  }
}
