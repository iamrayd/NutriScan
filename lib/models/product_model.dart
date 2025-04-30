class ProductModel {
  final String barcode;
  final String productName;
  final String date;
  final String price;
  final bool isSafe;
  final List<String> ingredients; // To check against allergens

  ProductModel({
    required this.barcode,
    required this.productName,
    required this.date,
    required this.price,
    required this.isSafe,
    required this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'productName': productName,
      'date': date,
      'price': price,
      'isSafe': isSafe,
      'ingredients': ingredients,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      barcode: map['barcode'],
      productName: map['productName'],
      date: map['date'],
      price: map['price'],
      isSafe: map['isSafe'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
    );
  }
}