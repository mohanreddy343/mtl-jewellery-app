import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/product_model.dart';
import 'api_config.dart';

class ProductApiException implements Exception {
  final String message;
  ProductApiException(this.message);

  @override
  String toString() => message;
}

/// One product plus its size options (100g, 200g ...). [variants] is empty
/// when the product has no other sizes.
class ProductDetail {
  final Product product;
  final List<Product> variants;
  ProductDetail({required this.product, required this.variants});
}

class ProductDetailApi {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  static Product _toProduct(Map<String, dynamic> j) => Product(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    price: ((j['price'] ?? 0) as num).toDouble(),
    originalPrice:
    ((j['originalPrice'] ?? j['price'] ?? 0) as num).toDouble(),
    image: (j['image'] ?? '').toString(),
    imageUrl: (j['imageUrl'] ?? '').toString(),
    category: (j['category'] ?? '').toString(),
    weight: (j['weight'] ?? '').toString(),
    sku: (j['sku'] ?? '').toString(),
    discountPercentage:
    ((j['discountPercentage'] ?? 0) as num).toDouble(),
    quantity: ((j['quantity'] ?? 0) as num).toInt(),
    posQuantity: ((j['posQuantity'] ?? 0) as num).toInt(),
  );

  static Future<dynamic> _get(String path) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$path')).timeout(_timeout);
      if (res.statusCode == 404) {
        throw ProductApiException('Product not found');
      }
      if (res.statusCode != 200) {
        throw ProductApiException('Request failed (${res.statusCode})');
      }
      return jsonDecode(res.body);
    } on SocketException {
      throw ProductApiException('Cannot reach the server.');
    } on TimeoutException {
      throw ProductApiException('The server took too long to respond.');
    } on FormatException {
      throw ProductApiException('Unexpected response from the server.');
    }
  }

  /// GET /products/:id
  static Future<ProductDetail> getDetail(String id) async {
    final data = await _get('/products/$id') as Map<String, dynamic>;
    final vars = ((data['variants'] as List?) ?? const [])
        .map((e) => _toProduct(e as Map<String, dynamic>))
        .toList();
    return ProductDetail(product: _toProduct(data), variants: vars);
  }

  /// GET /products/:id/similar
  static Future<List<Product>> getSimilar(String id) async {
    final data = await _get('/products/$id/similar') as List;
    return data.map((e) => _toProduct(e as Map<String, dynamic>)).toList();
  }
}