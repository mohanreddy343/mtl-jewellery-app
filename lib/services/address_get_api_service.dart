import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'address_api_service.dart' show AddressApiException;
import 'api_config.dart';

class AddressGetApi {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  /// GET /addresses
  /// Returns the logged-in user's addresses, or null when nobody is logged in.
  static Future<List<Map<String, dynamic>>?> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return null; // guest

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);

      if (res.statusCode == 401) {
        throw AddressApiException('Your session expired. Please log in again.');
      }
      if (res.statusCode != 200) {
        throw AddressApiException('Could not load addresses (${res.statusCode})');
      }

      final data = jsonDecode(res.body) as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } on SocketException {
      throw AddressApiException('Cannot reach the server.');
    } on TimeoutException {
      throw AddressApiException('The server took too long to respond.');
    } on FormatException {
      throw AddressApiException('Unexpected response from the server.');
    }
  }
}