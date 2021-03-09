class AchieveWishListModel {
  int id;
  int user_id;
  String asin;
  int last_sales_rank;
  int last_used_price;
  int last_new_price;
  int last_amazon_price;
  int last_cart_price;
  String price_achieved_at;
  bool last_has_amazon_offer;
  String amazon_outstock_at;
  String created_at;
  String updated_at;
  String last_achieve_checked_at;

  AchieveWishListModel(
      this.id, this.user_id, this.asin, this.last_sales_rank, this.last_used_price, this.last_new_price, this.last_amazon_price, this.last_cart_price, this.price_achieved_at, this.last_has_amazon_offer, this.amazon_outstock_at, this.created_at, this.updated_at, this.last_achieve_checked_at);

  AchieveWishListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    asin = json['asin'];
    last_sales_rank = json['last_sales_rank'];
    last_used_price = json['last_used_price'];
    last_new_price = json['last_new_price'];
    last_amazon_price = json['last_amazon_price'];
    last_cart_price = json['last_cart_price'];
    price_achieved_at = json['price_achieved_at'];
    last_has_amazon_offer = json['last_has_amazon_offer'];
    amazon_outstock_at = json['amazon_outstock_at'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    last_achieve_checked_at = json['last_achieve_checked_at'];
  }
}
