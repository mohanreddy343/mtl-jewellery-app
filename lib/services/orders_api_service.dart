import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

///this api is for your orders api after purchase to see you products what we ordered

class OrdersApiException implements Exception {
  final String message;
  OrdersApiException(this.message);

  @override
  String toString() => message;
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int qty;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: (j['productId'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    price: ((j['price'] ?? 0) as num).toDouble(),
    qty: ((j['qty'] ?? 1) as num).toInt(),
    imageUrl: (j['imageUrl'] ?? '').toString(),
  );
}

class OrderModel {
  final int id;
  final String status;
  final String paymentMethod;
  final double total;
  final String createdAt; // UTC, "YYYY-MM-DD HH:MM:SS"
  final String customerName;
  final String phone; // 8 digits, without +965
  final String addressText;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
    required this.customerName,
    required this.phone,
    required this.addressText,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    final a = (j['address'] as Map?)?.cast<String, dynamic>() ?? {};
    String s(String k) => (a[k] ?? '').toString().trim();
    final addr = <String>[
      s('area'),
      if (s('block').isNotEmpty) 'Block ${s('block')}',
      if (s('street').isNotEmpty) 'Street ${s('street')}',
      if (s('building').isNotEmpty) 'Bldg ${s('building')}',
      if (s('floor').isNotEmpty) 'Floor ${s('floor')}',
      if (s('flat').isNotEmpty) 'Flat ${s('flat')}',
      s('governorate'),
    ].where((e) => e.isNotEmpty).join(', ');

    // The order stores the phone as "+965 12345678"; the screen adds +965 itself
    final rawPhone = (j['phone'] ?? '').toString();
    final phone = rawPhone.replaceFirst(RegExp(r'^\+?965\s*'), '');

    return OrderModel(
      id: (j['id'] as num).toInt(),
      status: (j['status'] ?? 'Placed').toString(),
      paymentMethod: (j['paymentMethod'] ?? 'Cash on Delivery').toString(),
      total: ((j['total'] ?? 0) as num).toDouble(),
      createdAt: (j['createdAt'] ?? '').toString(),
      customerName: (j['customerName'] ?? '').toString(),
      phone: phone,
      addressText: addr,
      items: ((j['items'] as List?) ?? const [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrdersApi {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  /// GET /orders/my. Returns null when nobody is logged in.
  static Future<List<OrderModel>?> getMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);

      if (res.statusCode == 401) {
        throw OrdersApiException('Your session expired. Please log in again.');
      }
      if (res.statusCode != 200) {
        throw OrdersApiException('Could not load orders (${res.statusCode})');
      }
      final data = jsonDecode(res.body) as List;
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw OrdersApiException('Cannot reach the server.');
    } on TimeoutException {
      throw OrdersApiException('The server took too long to respond.');
    } on FormatException {
      throw OrdersApiException('Unexpected response from the server.');
    }
  }

  /// POST /orders/:id/cancel
  static Future<void> cancelOrder(int id) => _action(id, 'cancel');

  /// POST /orders/:id/return
  static Future<void> returnOrder(int id) => _action(id, 'return');

  static Future<void> _action(int id, String what) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw OrdersApiException('Please log in again.');
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/orders/$id/$what'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);

      if (res.statusCode == 401) {
        throw OrdersApiException('Your session expired. Please log in again.');
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        String msg = 'Request failed (${res.statusCode})';
        try {
          msg = (jsonDecode(res.body) as Map)['error']?.toString() ?? msg;
        } catch (_) {}
        throw OrdersApiException(msg);
      }
    } on SocketException {
      throw OrdersApiException('Cannot reach the server.');
    } on TimeoutException {
      throw OrdersApiException('The server took too long to respond.');
    }
  }
}