import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Error with a message that is safe to show to the user.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // Physical phone: your laptop's IPv4 from `ipconfig` (same Wi-Fi).
  // Android emulator: use http://10.0.2.2:3000 instead.
  static const String baseUrl = 'http://10.229.212.1:3000';

  static const _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> _post(
      String path,
      Map<String, dynamic> body,
      ) async {
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(
            data['error']?.toString() ?? 'Request failed (${res.statusCode})');
      }
      return data;
    } on SocketException {
      throw ApiException(
          'Cannot reach the server. Check your Wi-Fi and the server address.');
    } on TimeoutException {
      throw ApiException('The server took too long to respond.');
    } on FormatException {
      throw ApiException('Unexpected response from the server.');
    }
  }

  // ── Mobile OTP ─────────────────────────────────────────────────────────────
  /// [mobile] example: +96512345678 (no spaces)
  static Future<void> sendOtp(String mobile) async {
    await _post('/auth/send-otp', {'mobile': mobile});
  }

  /// Returns { token, user, isNewUser }
  static Future<Map<String, dynamic>> verifyOtp(
      String mobile, String code) {
    return _post('/auth/verify-otp', {'mobile': mobile, 'code': code});
  }

  // ── Email ──────────────────────────────────────────────────────────────────
  /// Returns { token, user }
  static Future<Map<String, dynamic>> login(String email, String password) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  /// Returns { token, user }
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) {
    return _post(
        '/auth/register', {'name': name, 'email': email, 'password': password});
  }
}