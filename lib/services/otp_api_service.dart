import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Error with a message that is safe to show to the user.
class OtpApiException implements Exception {
  final String message;
  OtpApiException(this.message);

  @override
  String toString() => message;
}

/// What the server returns after a successful OTP check.
class VerifyOtpResult {
  final String token;
  final String userId;
  final String name;
  final bool isNewUser;

  VerifyOtpResult({
    required this.token,
    required this.userId,
    required this.name,
    required this.isNewUser,
  });
}

class OtpApi {
  // Physical phone: your laptop's IPv4 from `ipconfig` (same Wi-Fi).
  // Android emulator: use http://10.0.2.2:3000 instead.
  static const String baseUrl = 'http://localhost:3000';
  static const _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
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
        throw OtpApiException(
            data['error']?.toString() ?? 'Request failed (${res.statusCode})');
      }
      return data;
    } on SocketException {
      throw OtpApiException(
          'Cannot reach the server. Check your Wi-Fi and the server address.');
    } on TimeoutException {
      throw OtpApiException('The server took too long to respond.');
    } on FormatException {
      throw OtpApiException('Unexpected response from the server.');
    }
  }

  /// Calls POST /auth/verify-otp
  /// [mobile] must be the same clean number used for send-otp, e.g. +96512345678
  static Future<VerifyOtpResult> verify(String mobile, String code) async {
    final data = await _post('/auth/verify-otp', {
      'mobile': mobile,
      'code': code,
    });

    final user = (data['user'] as Map?) ?? {};
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw OtpApiException('Login failed. Please try again.');
    }

    return VerifyOtpResult(
      token: token,
      userId: user['id']?.toString() ?? mobile,
      name: user['name']?.toString() ?? '',
      isNewUser: data['isNewUser'] == true,
    );
  }

  /// Calls POST /auth/send-otp again (for the Resend button)
  static Future<void> resend(String mobile) async {
    await _post('/auth/send-otp', {'mobile': mobile});
  }

  /// Saves the login token so later API calls can use it.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}