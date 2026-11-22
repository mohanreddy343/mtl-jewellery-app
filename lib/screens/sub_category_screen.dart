import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../model/product_model.dart';
import '../services/category_api_service.dart';
import '../widgets/product_card.dart';

/// Subcategories listed down the left, products of the selected one on the right.
class SubcategoryScreen extends StatefulWidget {
  final CategoryModel parent;
  final CategoryModel initialSub;

  const SubcategoryScreen({
    super.key,
    required this.parent,
    required this.initialSub,
  });

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  late CategoryModel _selected;
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSub;
    _load(_selected);
  }

  Future<void> _load(CategoryModel sub) async {
    setState(() {
      _selected = sub;
      _products = [];
      _loading = true;
      _error = null;
    });
    try {
      final items = await CategoryApi.getProducts(sub.id);
      if (!mounted || _selected.id != sub.id) return;
      setState(() {
        _products = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || _selected.id != sub.id) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subs = widget.parent.subcategories;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.parent.name,
          style: const TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: subcategories, one under another
          Container(
            width: 100,
            color: Colors.white,
            child: ListView.builder(
              itemCount: subs.length,
              itemBuilder: (context, i) {
                final s = subs[i];
                final selected = _selected.id == s.id;
                return InkWell(
                  onTap: () => _load(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFFF3E0) : Colors.white,
                      border: Border(
                        left: BorderSide(
                          color: selected ? Colors.orange : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFF3F3F3),
                            child: s.imageUrl.isNotEmpty
                                ? Image.network(s.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 22))
                                : const Icon(Icons.category_outlined,
                                color: Colors.grey, size: 22),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                            color: selected ? Colors.black : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right: products of the selected subcategory
          Expanded(child: _buildProducts()),
        ],
      ),
    );
  }

  Widget _buildProducts() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _load(_selected),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(
        child: Text('No products in this subcategory yet.',
            style: TextStyle(color: Colors.black54)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 330 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
          itemCount: _products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 320,
          ),
          itemBuilder: (context, i) =>
              ProductCard(product: _products[i], imageHeight: 170),
        );
      },
    );
  }
}