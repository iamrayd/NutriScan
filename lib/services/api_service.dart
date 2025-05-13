import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  Future<ProductModel> fetchProductDetails(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/product/$barcode'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};

          final nutritionalInfo = [
            if (nutriments['fat'] != null) 'Fat: ${nutriments['fat']}g',
            if (nutriments['fiber'] != null) 'Fiber: ${nutriments['fiber']}g',
            if (nutriments['sugars'] != null) 'Sugars: ${nutriments['sugars']}g',
          ].join(', ');

          final nutrients = [
            if (nutriments['proteins'] != null) 'Protein: ${nutriments['proteins']}g',
            if (nutriments['fat'] != null) 'Fats: ${nutriments['fat']}g',
            if (nutriments['carbohydrates'] != null) 'Carbs: ${nutriments['carbohydrates']}g',
          ].join(', ');

          final allergens = (product['allergens_tags'] as List<dynamic>?)
              ?.map((tag) => (tag as String).replaceFirst('en:', '').toLowerCase())
              .toList() ?? [];

          return ProductModel(
            barcode: barcode,
            productName: product['product_name'] ?? 'Unknown Product',
            date: DateTime.now().toString().split(' ')[0],
            price: product['product_price'] ?? 'N/A',
            isSafe: true,
            ingredients: List<String>.from(product['ingredients_text']?.split(', ') ?? []),
            calories: nutriments['energy-kcal'] != null ? '${nutriments['energy-kcal']} kcal' : 'N/A',
            nutrients: nutrients.isNotEmpty ? nutrients : 'N/A',
            nutritionalInfo: nutritionalInfo.isNotEmpty ? nutritionalInfo : 'N/A',
            imageURL: product['image_url'] ?? '',
            allergens: allergens,
          );
        }
        throw Exception('Product not found');
      }
      throw Exception('Failed to fetch product: ${response.statusCode}');
    } catch (e) {
      throw Exception('API error: $e');
    }
  }
}