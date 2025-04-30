import '../models/product_model.dart';
import '../models/user_model.dart';

class BarcodeService {
  Future<ProductModel> fetchProductDetails(String barcode) async {
    try {
      // Simulate fetching product details from an API
      await Future.delayed(Duration(seconds: 1)); // Mock delay
      return ProductModel(
        barcode: barcode,
        productName: "Sample Product",
        date: DateTime.now().toString().split(' ')[0],
        price: "P100",
        isSafe: true, // This will be determined below
        ingredients: ["peanuts", "milk", "soy"], // Mock ingredients
      );
    } catch (e) {
      throw Exception('Failed to fetch product details: $e');
    }
  }

  bool checkProductSafety(UserModel user, ProductModel product) {
    try {
      for (String ingredient in product.ingredients) {
        if (user.allergens.contains(ingredient.toLowerCase())) {
          return false;
        }
      }
      return true;
    } catch (e) {
      throw Exception('Failed to check product safety: $e');
    }
  }
}