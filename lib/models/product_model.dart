class ProductModel {
  final String barcode;
  final String productName;
  final String date;
  final String price;
  final bool isSafe;
  final List<String> ingredients;
  final String calories;
  final String nutrients;
  final String nutritionalInfo;
  final String imageURL;
  final List<String> allergens;

  ProductModel({
    required this.barcode,
    required this.productName,
    required this.date,
    required this.price,
    required this.isSafe,
    required this.ingredients,
    required this.calories,
    required this.nutrients,
    required this.nutritionalInfo,
    required this.imageURL,
    required this.allergens,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'productName': productName,
      'date': date,
      'price': price,
      'isSafe': isSafe,
      'ingredients': ingredients,
      'calories': calories,
      'nutrients': nutrients,
      'nutritionalInfo': nutritionalInfo,
      'imageURL': imageURL,
      'allergens': allergens,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      barcode: map['barcode'] ?? '',
      productName: map['productName'] ?? '',
      date: map['date'] ?? '',
      price: map['price'] ?? '',
      isSafe: map['isSafe'] ?? false,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      calories: map['calories'] ?? 'N/A',
      nutrients: map['nutrients'] ?? 'N/A',
      nutritionalInfo: map['nutritionalInfo'] ?? 'N/A',
      imageURL: map['imageURL'] ?? '',
      allergens: List<String>.from(map['allergens'] ?? []),
    );
  }
}