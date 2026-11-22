import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';
import 'api_config.dart';

class ApiService {
  // Android emulator: http://10.0.2.2:3000
  // Chrome / iOS simulator: http://localhost:3000
  // Real phone: http://YOUR-LAPTOP-IP:3000
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Product>> getProducts({String? category}) async {
    final uri = Uri.parse("$baseUrl/products").replace(
      queryParameters: (category != null && category != 'All')
          ? {'category': category}
          : null,
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load products (${response.statusCode})");
    }

    final List data = jsonDecode(response.body);
    return data.map<Product>((j) => Product(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      price: ((j['price'] ?? 0) as num).toDouble(),
      originalPrice: ((j['originalPrice'] ?? j['price'] ?? 0) as num).toDouble(),
      image: (j['image'] ?? '').toString(),
      imageUrl: (j['imageUrl'] ?? '').toString(),
      category: (j['category'] ?? '').toString(),
      weight: (j['weight'] ?? '').toString(),
      sku: (j['sku'] ?? '').toString(),
      discountPercentage: ((j['discountPercentage'] ?? 0) as num).toDouble(),
      quantity: ((j['quantity'] ?? 0) as num).toInt(),
      posQuantity: ((j['posQuantity'] ?? 0) as num).toInt(),
    )).toList();
  }
}