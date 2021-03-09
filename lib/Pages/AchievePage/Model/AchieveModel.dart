import 'AchieveWishListModel.dart';

class AchieveModel {
  int id;
  String asin;
  int wishlist_id;
  int type; //1: 価格上昇 , 2: Amazon切れ
  String created_at;
  String updated_at;
  AchieveWishListModel achieveWishListModel;
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
  bool isAddPurchasedList;
  String category_name;

  AchieveModel(this.id, this.asin, this.wishlist_id, this.type, this.created_at, this.updated_at, this.achieveWishListModel, this.cat_id, this.title, this.photo, this.amazon_price, this.new_price, this.used_price, this.cart_price, this.offers, this.new_offers, this.used_offers,
      this.has_amazon_offer, this.sales_rank, this.last_update, this.isAddPurchasedList, this.category_name);

  AchieveModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    asin = json['asin'];
    wishlist_id = json['wishlist_id'];
    type = json['type']; //1: 価格上昇 , 2: Amazon切れ
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    achieveWishListModel = AchieveWishListModel.fromJson(json['wishlist']);
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
    isAddPurchasedList = false;
    category_name = json['category_name'];
  }
}
