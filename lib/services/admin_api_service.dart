import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/banner_model.dart';
import 'api_config.dart';

class AdminApiException implements Exception {
  final String message;
  AdminApiException(this.message);

  @override
  String toString() => message;
}

/// "12" instead of "12.0", "12.50" for decimals.
String kwd(num v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

// ── Orders ───────────────────────────────────────────────────────────────────
class AdminOrder {
  final int id;
  String status;
  final double total;
  final String createdAt; // UTC, "YYYY-MM-DD HH:MM:SS"
  final String customerName;
  final String phone;
  final String paymentMethod;
  final List<String> items; // "Name x2"
  final String addressText;

  AdminOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.customerName,
    required this.phone,
    required this.paymentMethod,
    required this.items,
    required this.addressText,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> j) {
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

    return AdminOrder(
      id: (j['id'] as num).toInt(),
      status: (j['status'] ?? 'Placed').toString(),
      total: ((j['total'] ?? 0) as num).toDouble(),
      createdAt: (j['createdAt'] ?? '').toString(),
      customerName: (j['customerName'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      paymentMethod: (j['paymentMethod'] ?? '').toString(),
      items: ((j['items'] as List?) ?? const [])
          .map((e) => '${e['name']} x${e['qty']}')
          .toList(),
      addressText: addr,
    );
  }
}

class RequestItem {
  final String name, sku, weight, imageUrl;
  final double price;
  final int qty;

  RequestItem({
    required this.name,
    required this.sku,
    required this.weight,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  factory RequestItem.fromJson(Map<String, dynamic> j) => RequestItem(
    name: (j['name'] ?? '').toString(),
    sku: (j['sku'] ?? '').toString(),
    weight: (j['weight'] ?? '').toString(),
    imageUrl: (j['imageUrl'] ?? '').toString(),
    price: ((j['price'] ?? 0) as num).toDouble(),
    qty: ((j['qty'] ?? 1) as num).toInt(),
  );
}

class AdminRequest {
  final int id;
  final double total;
  final String createdAt, customerName, phone, paymentMethod, addressText;
  final List<RequestItem> items;

  AdminRequest({
    required this.id,
    required this.total,
    required this.createdAt,
    required this.customerName,
    required this.phone,
    required this.paymentMethod,
    required this.addressText,
    required this.items,
  });

  factory AdminRequest.fromJson(Map<String, dynamic> j) {
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

    return AdminRequest(
      id: (j['id'] as num).toInt(),
      total: ((j['total'] ?? 0) as num).toDouble(),
      createdAt: (j['createdAt'] ?? '').toString(),
      customerName: (j['customerName'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      paymentMethod: (j['paymentMethod'] ?? '').toString(),
      addressText: addr,
      items: ((j['items'] as List?) ?? const [])
          .map((e) => RequestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminCategory {
  final int id;
  final String name;
  final int? parentId;
  final String parentName;
  final int productCount;
  final String imageUrl;

  AdminCategory({
    required this.id,
    required this.name,
    required this.parentId,
    required this.parentName,
    required this.productCount,
    this.imageUrl = '',
  });

  bool get isParent => parentId == null;

  /// "Electronics" or "Electronics › Audio"
  String get fullName => isParent ? name : '$parentName › $name';

  factory AdminCategory.fromJson(Map<String, dynamic> j) => AdminCategory(
    id: (j['id'] as num).toInt(),
    name: (j['name'] ?? '').toString(),
    parentId: (j['parentId'] as num?)?.toInt(),
    parentName: (j['parentName'] ?? '').toString(),
    productCount: ((j['productCount'] ?? 0) as num).toInt(),
    imageUrl: (j['imageUrl'] ?? '').toString(),
  );
}

// ── Products
class AdminProduct {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final int quantity;
  final String weight;
  final String sku;
  final String image;
  final int? categoryId;
  final String categoryName;
  final String groupId;

  AdminProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.weight,
    required this.sku,
    required this.image,
    required this.categoryId,
    required this.categoryName,
    this.groupId = '',
  });

  factory AdminProduct.fromJson(Map<String, dynamic> j) => AdminProduct(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    price: ((j['price'] ?? 0) as num).toDouble(),
    originalPrice: ((j['originalPrice'] ?? j['price'] ?? 0) as num).toDouble(),
    quantity: ((j['quantity'] ?? 0) as num).toInt(),
    weight: (j['weight'] ?? '').toString(),
    sku: (j['sku'] ?? '').toString(),
    image: (j['image'] ?? '').toString(),
    categoryId: (j['categoryId'] as num?)?.toInt(),
    categoryName: (j['categoryName'] ?? j['category'] ?? '').toString(),
    groupId: (j['groupId'] ?? '').toString(),
  );
}

// ── Delivery charges ─────────────────────────────────────────────────────────
class DeliveryCharge {
  final String governorate;
  double charge;
  DeliveryCharge(this.governorate, this.charge);
}

class DeliveryConfig {
  final List<DeliveryCharge> charges;
  double freeAbove; // 0 = free delivery is off

  DeliveryConfig({required this.charges, required this.freeAbove});

  factory DeliveryConfig.fromJson(Map<String, dynamic> j) => DeliveryConfig(
    charges: ((j['charges'] as List?) ?? const [])
        .map((e) => DeliveryCharge(
      (e['governorate'] ?? '').toString(),
      ((e['charge'] ?? 0) as num).toDouble(),
    ))
        .toList(),
    freeAbove: ((j['freeAbove'] ?? 0) as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'charges': charges
        .map((c) => {'governorate': c.governorate, 'charge': c.charge})
        .toList(),
    'freeAbove': freeAbove,
  };
}

// ── API ──────────────────────────────────────────────────────────────────────
class AdminApi {
  static String get baseUrl => ApiConfig.baseUrl;
  static const _timeout = ApiConfig.timeout;

  /// Same order steps as the server and the customer "Track order" sheet.
  static const List<String> statuses = [
    'Placed',
    'Confirmed',
    'Shipped',
    'Out for delivery',
    'Delivered',
  ];

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('auth_token');
    return (t == null || t.isEmpty) ? null : t;
  }

  /// True only when the server says this logged-in user has role "admin".
  static Future<bool> isAdmin() async {
    final token = await _token();
    if (token == null) return false;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  static Future<dynamic> _send(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final token = await _token();
    if (token == null) {
      throw AdminApiException('Please log in again.');
    }
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final payload = body == null ? null : jsonEncode(body);

      final http.Response res;
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          res = await http
              .post(uri, headers: headers, body: payload)
              .timeout(_timeout);
          break;
        case 'PUT':
          res = await http
              .put(uri, headers: headers, body: payload)
              .timeout(_timeout);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default: // PATCH
          res = await http
              .patch(uri, headers: headers, body: payload)
              .timeout(_timeout);
      }

      dynamic data;
      try {
        data = jsonDecode(res.body);
      } catch (_) {}

      if (res.statusCode == 401) {
        throw AdminApiException('Your session expired. Please log in again.');
      }
      if (res.statusCode == 403) {
        throw AdminApiException('This account does not have admin access.');
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        final msg = data is Map ? data['error']?.toString() : null;
        throw AdminApiException(msg ?? 'Request failed (${res.statusCode})');
      }
      return data;
    } on SocketException {
      throw AdminApiException('Cannot reach the server.');
    } on TimeoutException {
      throw AdminApiException('The server took too long to respond.');
    } on FormatException {
      throw AdminApiException('Unexpected response from the server.');
    }
  }

  // ── Orders ─────────────────────────────────────────────────────────────────
  static Future<List<AdminOrder>> getOrders() async {
    final data = await _send('GET', '/admin/orders') as List;
    return data
        .map((e) => AdminOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> setOrderStatus(int orderId, String status) async {
    await _send('PATCH', '/admin/orders/$orderId/status',
        body: {'status': status});
  }

  // ── Cancel / return requests ───────────────────────────────────────────────
  /// [type] is 'cancel' or 'return'.
  static Future<List<AdminRequest>> getRequests(String type) async {
    final data = await _send('GET', '/admin/requests?type=$type') as List;
    return data
        .map((e) => AdminRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> decideRequest(int orderId, bool approve) async {
    await _send('POST', '/admin/requests/$orderId/decision',
        body: {'approve': approve});
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  static Future<List<AdminCategory>> getCategories() async {
    final data = await _send('GET', '/admin/categories') as List;
    return data
        .map((e) => AdminCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addCategory(String name,
      {int? parentId, String image = ''}) async {
    await _send('POST', '/admin/categories',
        body: {'name': name, 'parentId': parentId, 'image': image});
  }

  /// [image] null = keep the current image.
  static Future<void> renameCategory(int id, String name,
      {String? image}) async {
    await _send('PUT', '/admin/categories/$id', body: {
      'name': name,
      if (image != null) 'image': image,
    });
  }

  static Future<void> deleteCategory(int id) async {
    await _send('DELETE', '/admin/categories/$id');
  }

  // ── Products ───────────────────────────────────────────────────────────────
  static Future<List<AdminProduct>> getProducts() async {
    final data = await _send('GET', '/admin/products') as List;
    return data
        .map((e) => AdminProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// [id] null = create a new product, otherwise update that product.
  static Future<void> saveProduct(Map<String, dynamic> body,
      {String? id}) async {
    if (id == null) {
      await _send('POST', '/admin/products', body: body);
    } else {
      await _send('PUT', '/admin/products/$id', body: body);
    }
  }

  static Future<void> deleteProduct(String id) async {
    await _send('DELETE', '/admin/products/$id');
  }

  /// Uploads a picked image and returns the saved file name.
  static Future<String> uploadImage(String filePath) async {
    final token = await _token();
    if (token == null) {
      throw AdminApiException('Please log in again.');
    }
    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/upload'),
      );
      req.headers['Authorization'] = 'Bearer $token';
      req.files.add(await http.MultipartFile.fromPath('image', filePath));

      final res = await http.Response.fromStream(
        await req.send().timeout(const Duration(seconds: 60)),
      );

      dynamic data;
      try {
        data = jsonDecode(res.body);
      } catch (_) {}

      if (res.statusCode == 401) {
        throw AdminApiException('Your session expired. Please log in again.');
      }
      if (res.statusCode == 403) {
        throw AdminApiException('This account does not have admin access.');
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        final msg = data is Map ? data['error']?.toString() : null;
        throw AdminApiException(msg ?? 'Upload failed (${res.statusCode})');
      }
      final name = data is Map ? data['filename']?.toString() : null;
      if (name == null || name.isEmpty) {
        throw AdminApiException('Unexpected response from the server.');
      }
      return name;
    } on SocketException {
      throw AdminApiException('Cannot reach the server.');
    } on TimeoutException {
      throw AdminApiException('The upload took too long.');
    }
  }

  // ── Banners ────────────────────────────────────────────────────────────────
  static Future<List<BannerModel>> getBanners() async {
    final data = await _send('GET', '/admin/banners') as List;
    return data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addBanner(String image, String link) async {
    await _send('POST', '/admin/banners',
        body: {'image': image, 'link': link});
  }

  /// [image] null = keep the current picture.
  static Future<void> updateBanner(int id, String link,
      {String? image}) async {
    await _send('PUT', '/admin/banners/$id', body: {
      'link': link,
      if (image != null) 'image': image,
    });
  }

  static Future<void> deleteBanner(int id) async {
    await _send('DELETE', '/admin/banners/$id');
  }

  // ── Delivery charges ───────────────────────────────────────────────────────
  static Future<DeliveryConfig> getDelivery() async {
    final data = await _send('GET', '/admin/delivery') as Map<String, dynamic>;
    return DeliveryConfig.fromJson(data);
  }

  static Future<void> saveDelivery(DeliveryConfig config) async {
    await _send('PUT', '/admin/delivery', body: config.toJson());
  }
}