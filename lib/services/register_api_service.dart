import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Error with a message that is safe to show to the user.
class RegisterApiException implements Exception {
  final String message;
  RegisterApiException(this.message);

  @override
  String toString() => message;
}

/// What the server returns after a successful sign up.
class RegisterResult {
  final String token;
  final String userId;
  final String name;
  final String email;

  RegisterResult({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });
}

class RegisterApi {
  // USB tunnel (adb reverse): http://localhost:3000
  // Wi-Fi: your laptop's IPv4 from `ipconfig`, e.g. http://10.122.245.1:3000
  static const String baseUrl = ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  /// Calls POST /auth/register
  static Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      )
          .timeout(_timeout);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw RegisterApiException(
            data['error']?.toString() ?? 'Sign up failed (${res.statusCode})');
      }

      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw RegisterApiException('Sign up failed. Please try again.');
      }

      final user = (data['user'] as Map?) ?? {};
      return RegisterResult(
        token: token,
        userId: user['id']?.toString() ?? email,
        name: user['name']?.toString() ?? name,
        email: user['email']?.toString() ?? email,
      );
    } on SocketException {
      throw RegisterApiException(
          'Cannot reach the server. Check your connection and server address.');
    } on TimeoutException {
      throw RegisterApiException('The server took too long to respond.');
    } on FormatException {
      throw RegisterApiException('Unexpected response from the server.');
    }
  }

  /// Calls POST /auth/login
  static Future<RegisterResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(_timeout);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw RegisterApiException(
            data['error']?.toString() ?? 'Login failed (${res.statusCode})');
      }

      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw RegisterApiException('Login failed. Please try again.');
      }

      final user = (data['user'] as Map?) ?? {};
      return RegisterResult(
        token: token,
        userId: user['id']?.toString() ?? email,
        name: user['name']?.toString() ?? '',
        email: user['email']?.toString() ?? email,
      );
    } on SocketException {
      throw RegisterApiException(
          'Cannot reach the server. Check your connection and server address.');
    } on TimeoutException {
      throw RegisterApiException('The server took too long to respond.');
    } on FormatException {
      throw RegisterApiException('Unexpected response from the server.');
    }
  }

  /// Saves the login token so later API calls can use it.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
}