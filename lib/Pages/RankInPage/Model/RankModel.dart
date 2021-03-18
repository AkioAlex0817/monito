class RankModel {
  String cat_id;
  String asin;
  String title;
  String photo;
  int sales_rank;
  int amazon_price;
  int cart_price;
  int new_price;
  int used_price;
  int offers;
  int new_offers;
  int used_offers;
  int has_amazon_offer;
  int stock;
  String seller_stocks;
  int last_sales_rank;
  int sales_rank_at_rankin;
  int sales_rank_delta;
  String current;
  String delta;
  String delta_last;
  String last_update;
  String stock_updated_at;
  String rankin_at;
  String jan;
  bool isFavorite;
  String category_name;

  RankModel(this.cat_id, this.asin, this.title, this.photo, this.sales_rank, this.amazon_price, this.cart_price, this.new_price, this.used_price, this.offers, this.new_offers, this.used_offers, this.has_amazon_offer, this.stock, this.seller_stocks, this.last_sales_rank, this.sales_rank_at_rankin, this.sales_rank_delta,
      this.current, this.delta, this.delta_last, this.last_update, this.stock_updated_at, this.rankin_at, this.jan, this.isFavorite, this.category_name);

  RankModel.fromJson(Map<String, dynamic> json) {
    cat_id = json['cat_id'].toString();
    asin = json['asin'];
    title = json['title'];
    photo = json['photo'];
    sales_rank = json['sales_rank'];
    amazon_price = json['amazon_price'];
    cart_price = json['cart_price'];
    new_price = json['new_price'];
    used_price = json['used_price'];
    offers = json['offers'];
    new_offers = json['new_offers'];
    used_offers = json['used_offers'];
    has_amazon_offer = json['has_amazon_offer'];
    stock = json['stock'];
    seller_stocks = json['seller_stocks'];
    last_sales_rank = json['last_sales_rank'];
    sales_rank_at_rankin = json['sales_rank_at_rankin'];
    sales_rank_delta = json['sales_rank_delta'];
    current = json['current'];
    delta = json['delta'];
    delta_last = json['delta_last'];
    last_update = json['last_update'];
    stock_updated_at = json['stock_updated_at'];
    rankin_at = json['rankin_at'];
    jan = json['jan'];
    isFavorite = false;
    category_name = json['category_name'];
  }
}
