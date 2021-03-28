class RankModel {
  int id;
  String cat_id;
  String asin;
  String jan;
  String title;
  String photo;
  int sales_rank;
  int cart_price;
  int amazon_price;
  int new_price;
  int used_price;
  int offers;
  int new_offers;
  int used_offers;
  bool has_amazon_offer;
  int sales_rank_at_rankin;
  String acknowledged_at;
  String ranked_at;
  String created_at;
  String updated_at;
  String last_update;
  bool isFavorite;
  String category_name;

  RankModel(this.id, this.cat_id, this.asin, this.jan, this.title, this.photo, this.sales_rank, this.cart_price, this.amazon_price, this.new_price, this.used_price, this.offers, this.new_offers, this.used_offers, this.has_amazon_offer, this.sales_rank_at_rankin, this.acknowledged_at, this.ranked_at,
      this.created_at, this.updated_at, this.last_update, this.isFavorite, this.category_name);

  RankModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cat_id = json['cat_id'].toString();
    asin = json['asin'];
    jan = json['jan'];
    title = json['title'];
    photo = json['photo'];
    sales_rank = json['sales_rank'];
    cart_price = json['cart_price'];
    amazon_price = json['amazon_price'];
    new_price = json['new_price'];
    used_price = json['used_price'];
    offers = json['offers'];
    new_offers = json['new_offers'];
    used_offers = json['used_offers'];
    has_amazon_offer = json['has_amazon_offer'];
    sales_rank_at_rankin = json['sales_rank_at_rankin'];
    acknowledged_at = json['acknowledged_at'];
    ranked_at = json['ranked_at'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    last_update = json['last_update'];
    isFavorite = false;
    category_name = json['category_name'];
  }
}
