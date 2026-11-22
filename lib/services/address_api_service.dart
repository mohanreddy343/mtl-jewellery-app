import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Error with a message that is safe to show to the user.
/// this is add_address_api in saved address screen
class AddressApiException implements Exception {
  final String message;
  AddressApiException(this.message);

  @override
  String toString() => message;
}

class AddressApi {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('auth_token');
    return (t == null || t.isEmpty) ? null : t;
  }

  /// True when a login token is saved (guests have none).
  static Future<bool> isLoggedIn() async => (await _token()) != null;

  /// POST /addresses
  /// [body] is SavedAddress.toJson(). Returns the saved address from the server.
  static Future<Map<String, dynamic>> add(Map<String, dynamic> body) async {
    final token = await _token();
    if (token == null) {
      throw AddressApiException('Please log in to save addresses online.');
    }

    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode == 401) {
        throw AddressApiException('Your session expired. Please log in again.');
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw AddressApiException(
            data['error']?.toString() ?? 'Could not save (${res.statusCode})');
      }
      return data;
    } on SocketException {
      throw AddressApiException('Cannot reach the server.');
    } on TimeoutException {
      throw AddressApiException('The server took too long to respond.');
    } on FormatException {
      throw AddressApiException('Unexpected response from the server.');
    }
  }
}