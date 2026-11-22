import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class OrderApi {
  /// items: [{'productId': '1', 'qty': 2}, ...]
  /// token: the login token, if the user is logged in (optional)
  /// this order api is for add order api
  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> address,
    required String paymentMethod,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = token ?? prefs.getString('auth_token');
      final res = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'items': items,
          'address': address,
          'paymentMethod': paymentMethod,
        }),
      )
          .timeout(ApiConfig.timeout);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(
            data['error']?.toString() ?? 'Request failed (${res.statusCode})');
      }
      return data;
    } on SocketException {
      throw Exception('Cannot reach the server.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    }
  }
}