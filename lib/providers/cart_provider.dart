import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtl_jewellery/model/product_model.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});

  String get id => product.id;
  double get lineTotal => product.price * qty;
}

class CartProvider extends ChangeNotifier {
  CartProvider._();
  static final CartProvider instance = CartProvider._();

  static const _prefsKey = 'cart_items_v1';
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get totalCount => _items.values.fold(0, (s, i) => s + i.qty);
  double get totalPrice => _items.values.fold(0.0, (s, i) => s + i.lineTotal);

  int qtyOf(String id) => _items[id]?.qty ?? 0;

  /// Max quantity a customer can add (stock from either source).
  int _maxQty(Product p) => math.max(p.quantity, p.posQuantity);

  void add(Product product) {
    if (!product.isInStock) return;
    final existing = _items[product.id];
    if (existing != null) {
      if (existing.qty >= _maxQty(product)) return; // stock cap
      existing.qty++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    _changed();
  }

  /// Qty 1 -> removes the item (the delete icon behaviour).
  void decrease(String id) {
    final item = _items[id];
    if (item == null) return;
    if (item.qty <= 1) {
      _items.remove(id);
    } else {
      item.qty--;
    }
    _changed();
  }

  void remove(String id) {
    _items.remove(id);
    _changed();
  }

  void clear() {
    _items.clear();
    _changed();
  }

  // ── Persistence ────────────────────────────────────────────────────────────
  void _changed() {
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _items.values
          .map((i) => {'product': i.product.toJson(), 'qty': i.qty})
          .toList();
      await prefs.setString(_prefsKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      for (final e in jsonDecode(raw) as List<dynamic>) {
        final m = e as Map<String, dynamic>;
        final p = Product.fromJson(m['product'] as Map<String, dynamic>);
        _items[p.id] = CartItem(product: p, qty: (m['qty'] as num).toInt());
      }
      notifyListeners();
    } catch (_) {}
  }
}