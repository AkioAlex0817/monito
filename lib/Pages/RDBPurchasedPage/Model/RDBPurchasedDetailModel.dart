class RDBPurchasedDetailModel {
  int id;
  String asin;
  int purchased;
  String title;
  String cat_id;
  String photo;
  String jan;
  int cart_price;
  int amazon_price;
  int new_price;
  int used_price;
  int sales_rank;
  int offers;
  int new_offers;
  int used_offers;
  String created_at;
  String updated_at;
  int avg_price;

  RDBPurchasedDetailModel(
    this.id,
    this.asin,
    this.purchased,
    this.title,
    this.cat_id,
    this.photo,
    this.jan,
    this.cart_price,
    this.amazon_price,
    this.new_price,
    this.used_price,
    this.sales_rank,
    this.offers,
    this.new_offers,
    this.used_offers,
    this.created_at,
    this.updated_at,
    this.avg_price,
  );

  RDBPurchasedDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    asin = json['asin'];
    purchased = json['purchased'];
    title = json['title'];
    cat_id = json['cat_id'].toString();
    photo = json['photo'];
    jan = json['jan'];
    cart_price = json['cart_price'];
    amazon_price = json['amazon_price'];
    new_price = json['new_price'];
    used_price = json['used_price'];
    sales_rank = json['sales_rank'];
    offers = json['offers'];
    new_offers = json['new_offers'];
    used_offers = json['used_offers'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    avg_price = json['avg_price'];
  }
}
