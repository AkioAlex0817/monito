class SupplierModel {
  int id;
  String name;

  SupplierModel(this.id, this.name);

  SupplierModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
