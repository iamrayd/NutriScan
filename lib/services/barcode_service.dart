import '../models/product_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class BarcodeService {
  final ApiService _apiService = ApiService();

  Future<ProductModel> fetchProductDetails(String barcode) async {
    try {
      return await _apiService.fetchProductDetails(barcode);
    } catch (e) {
      throw Exception('Failed to fetch product details: $e');
    }
  }

  bool checkProductSafety(UserModel user, ProductModel product) {
    try {
      // Normalize user allergens to lowercase for comparison
      final userAllergens = user.allergens.map((a) => a.toLowerCase()).toSet();

      // Check product allergens first
      if (product.allergens.isNotEmpty) {
        for (String allergen in product.allergens) {
          if (userAllergens.contains(allergen.toLowerCase())) {
            return false;
          }
        }
      }

      // Fallback to ingredients if no allergens provided
      if (product.ingredients.isNotEmpty) {
        for (String ingredient in product.ingredients) {
          if (userAllergens.contains(ingredient.toLowerCase())) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      throw Exception('Failed to check product safety: $e');
    }
  }
}