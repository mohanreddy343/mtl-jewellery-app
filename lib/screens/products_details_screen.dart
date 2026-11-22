import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/providers/cart_provider.dart';
import 'package:mtl_jewellery/widgets/product_card.dart';

import '../services/products_details_api_service.dart';

String _kwd(num v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

/// Full details of one product, its size options (100g, 200g ...) and
/// similar products below.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _accent = Color(0xFFFF9800);

  late Product _current; // the product / size that is selected right now
  List<Product> _variants = [];
  List<Product> _similar = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _current = widget.product;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await ProductDetailApi.getDetail(widget.product.id);
      List<Product> similar = [];
      try {
        similar = await ProductDetailApi.getSimilar(widget.product.id);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _current = detail.product;
        _variants = detail.variants;
        _similar = similar;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _imageOf(Product p) {
    if (p.imageUrl.startsWith('http')) return p.imageUrl;
    return p.image.startsWith('http') ? p.image : '';
  }

  void _addToCart() {
    CartProvider.instance.add(_current);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Product details',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: _body(),
      bottomNavigationBar: _loading || _error != null ? null : _bottomBar(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final p = _current;
    final hasDiscount = p.originalPrice > p.price && p.price > 0;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _imageArea(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('KWD ${_kwd(p.price)}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  if (hasDiscount) ...[
                    const SizedBox(width: 10),
                    Text(_kwd(p.originalPrice),
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                          '${p.computedDiscount}% OFF',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32))),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                p.isInStock ? 'In stock' : 'Out of stock',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.isInStock
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE02020)),
              ),
              if (_variants.length > 1) ...[
                const SizedBox(height: 20),
                const Text('Select size',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _variantChips(),
              ],
              const SizedBox(height: 20),
              const Text('Product details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _detailRow('Name', p.name),
              if (p.weight.isNotEmpty) _detailRow('Weight / size', p.weight),
              if (p.category.isNotEmpty) _detailRow('Category', p.category),
              if (p.sku.isNotEmpty) _detailRow('SKU', p.sku),
              _detailRow('Original price', 'KWD ${_kwd(p.originalPrice)}'),
              _detailRow('Selling price', 'KWD ${_kwd(p.price)}'),
            ],
          ),
        ),
        if (_similar.isNotEmpty) ...[
          const SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey.shade200),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text('Similar products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          SizedBox(
            height: 330,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _similar.length,
              itemBuilder: (context, i) => SizedBox(
                width: 150,
                child: ProductCard(
                  product: _similar[i],
                  imageHeight: 170,
                  cardRightMargin: i < _similar.length - 1 ? 10 : 0,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _imageArea() {
    var url = _imageOf(_current);
    if (url.isEmpty) url = _imageOf(widget.product);
    return Container(
      height: 300,
      width: double.infinity,
      color: const Color(0xFFF3F3F3),
      child: url.isEmpty
          ? const Center(
          child: Icon(Icons.image_not_supported,
              color: Colors.grey, size: 56))
          : Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_not_supported,
                color: Colors.grey, size: 56)),
      ),
    );
  }

  Widget _variantChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _variants.map((v) {
        final selected = v.id == _current.id;
        final label = v.weight.isNotEmpty ? v.weight : v.name;
        final out = !v.isInStock;
        return GestureDetector(
          onTap: () => setState(() => _current = v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF3E0) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: selected ? _accent : Colors.grey.shade300,
                  width: selected ? 1.8 : 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: out ? Colors.grey : Colors.black87)),
                const SizedBox(height: 2),
                Text(out ? 'Out of stock' : 'KWD ${_kwd(v.price)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: out
                            ? const Color(0xFFE02020)
                            : Colors.grey.shade700)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _detailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final out = !_current.isInStock;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, -2)),
          ],
        ),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: out ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: Text(out ? 'Out of stock' : 'Add to cart',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}