import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'address_api_service.dart' show AddressApiException;
import 'api_config.dart';

class AddressDeleteApi {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  /// DELETE /addresses/:id
  /// [id] is the server id (SavedAddress.id).
  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw AddressApiException('Please log in to delete addresses online.');
    }

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);

      if (res.statusCode == 401) {
        throw AddressApiException('Your session expired. Please log in again.');
      }
      // 404 means it is already gone on the server, which is fine for a delete
      if (res.statusCode == 404) return;

      if (res.statusCode < 200 || res.statusCode >= 300) {
        Map<String, dynamic> data = {};
        try {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {}
        throw AddressApiException(
            data['error']?.toString() ?? 'Could not delete (${res.statusCode})');
      }
    } on SocketException {
      throw AddressApiException('Cannot reach the server.');
    } on TimeoutException {
      throw AddressApiException('The server took too long to respond.');
    }
  }
}