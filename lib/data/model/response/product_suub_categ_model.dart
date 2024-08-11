class ProductSubCategory {
  final int id;
  final String name;
  final String price;

  ProductSubCategory({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) {
    return ProductSubCategory(
      id: json[0]['id'].toString() as int,
      name: json[0]['name'].toString() ,
      price: json[0]['price'].toString(),
    );
  }

  @override
  String toString() {
    return 'SubCategory{id: $id, name: $name, price: $price}';
  }
}
