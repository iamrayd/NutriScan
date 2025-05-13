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