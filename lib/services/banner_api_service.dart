import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/banner_model.dart';
import 'api_config.dart';

/// Public banner list for the home screen (no login needed).
class BannerApi {
  static Future<List<BannerModel>> getBanners() async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/banners'))
          .timeout(ApiConfig.timeout);
      if (res.statusCode != 200) {
        throw Exception('Banners failed (${res.statusCode})');
      }
      final data = jsonDecode(res.body) as List;
      return data
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Cannot reach the server.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    }
  }
}