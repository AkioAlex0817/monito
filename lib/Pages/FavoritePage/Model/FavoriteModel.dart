class FavoriteModel {
  String asin;
  int last_sales_rank;
  int last_used_price;
  int last_new_price;
  int last_amazon_price;
  int last_cart_price;
  String price_achieved_at;
  bool last_has_amazon_offer;
  String amazon_outstock_at;
  String last_achieve_checked_at;
  String cat_id;
  String title;
  String photo;
  int amazon_price;
  int new_price;
  int used_price;
  int cart_price;
  int offers;
  int new_offers;
  int used_offers;
  bool has_amazon_offer;
  int sales_rank;
  String last_update;
  String created_at;
  String category_name;

  FavoriteModel(this.asin, this.last_sales_rank, this.last_used_price, this.last_new_price, this.last_amazon_price, this.last_cart_price, this.price_achieved_at, this.last_has_amazon_offer, this.amazon_outstock_at, this.last_achieve_checked_at, this.cat_id, this.title, this.photo, this.amazon_price,
      this.new_price, this.used_price, this.cart_price, this.offers, this.new_offers, this.used_offers, this.has_amazon_offer, this.sales_rank, this.last_update, this.created_at, this.category_name);

  FavoriteModel.fromJson(Map<String, dynamic> json) {
    asin = json['asin'];
    last_sales_rank = json['last_sales_rank'];
    last_used_price = json['last_used_price'];
    last_new_price = json['last_new_price'];
    last_amazon_price = json['last_amazon_price'];
    last_cart_price = json['last_cart_price'];
    price_achieved_at = json['price_achieved_at'];
    last_has_amazon_offer = json['last_has_amazon_offer'];
    amazon_outstock_at = json['amazon_outstock_at'];
    last_achieve_checked_at = json['last_achieve_checked_at'];
    cat_id = json['cat_id'].toString();
    title = json['title'];
    photo = json['photo'];
    amazon_price = json['amazon_price'];
    new_price = json['new_price'];
    used_price = json['used_price'];
    cart_price = json['cart_price'];
    offers = json['offers'];
    new_offers = json['new_offers'];
    used_offers = json['used_offers'];
    has_amazon_offer = json['has_amazon_offer'];
    sales_rank = json['sales_rank'];
    last_update = json['last_update'];
    created_at = json['created_at'];
    category_name = json['category_name'];
  }
}
