import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/product_model.dart';
import 'api_config.dart';

class CategoryApiException implements Exception {
  final String message;
  CategoryApiException(this.message);

  @override
  String toString() => message;
}

class CategoryModel {
  final int id;
  final String name;
  final String image;
  final String imageUrl;
  final int productCount;
  final List<CategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.imageUrl = '',
    required this.productCount,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) {
    final subs = (j['subcategories'] as List?) ?? const [];
    return CategoryModel(
      id: (j['id'] as num).toInt(),
      name: (j['name'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      imageUrl: (j['imageUrl'] ?? '').toString(),
      productCount: ((j['productCount'] ?? 0) as num).toInt(),
      subcategories: subs
          .map((s) => CategoryModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryApi {
  // USB tunnel (adb reverse): http://localhost:3000
  // Wi-Fi: your laptop's IPv4 from `ipconfig`
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  static Future<dynamic> _get(String path) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$path')).timeout(_timeout);
      if (res.statusCode != 200) {
        throw CategoryApiException('Request failed (${res.statusCode})');
      }
      return jsonDecode(res.body);
    } on SocketException {
      throw CategoryApiException('Cannot reach the server.');
    } on TimeoutException {
      throw CategoryApiException('The server took too long to respond.');
    } on FormatException {
      throw CategoryApiException('Unexpected response from the server.');
    }
  }

  /// GET /categories -> parent categories, each with its subcategories
  static Future<List<CategoryModel>> getCategories() async {
    final data = await _get('/categories') as List;
    return data
        .map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// GET /categories/:id/products -> direct products of that category
  static Future<List<Product>> getProducts(int categoryId,
      {bool includeSub = false}) async {
    final data = await _get(
        '/categories/$categoryId/products${includeSub ? '?includeSub=true' : ''}')
    as Map<String, dynamic>;
    final List list = (data['products'] as List?) ?? const [];
    return list
        .map<Product>((j) => Product(
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
    ))
        .toList();
  }
}