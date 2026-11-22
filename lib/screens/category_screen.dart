import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/screens/products_list_screen.dart';
import 'package:mtl_jewellery/screens/search_screen.dart';

import '../services/category_api_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const _tileBg = Color(0xFFF0F1F6);
  static const _thumbBg = Color(0xFFE3E4EA);

  // Index of the parent category whose sub-categories are open (null = none)
  int? _expanded;

  // Data from the backend
  List<CategoryModel> _cats = [];
  bool _loading = true;
  String? _error;
  bool _loadingList = false;

  // When set, the product list screen is shown in place of the categories
  String? _listTitle;
  List<Product> _listProducts = const [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> _loadCategories({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await CategoryApi.getCategories();
      if (!mounted) return;
      setState(() {
        _cats = data;
        _loading = false;
        // Close the open panel if its category no longer exists
        if (_expanded != null && _expanded! >= data.length) _expanded = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        );
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() => _loadCategories(silent: true);

  IconData _iconFor(String name) {
    const icons = {
      'Electronics': Icons.devices_outlined,
      'Fashion': Icons.checkroom_outlined,
      'Beauty': Icons.face_retouching_natural_outlined,
      'Home': Icons.home_outlined,
      'Mobiles': Icons.smartphone_outlined,
    };
    return icons[name] ?? Icons.category_outlined;
  }

  String _clean(String s) => s.replaceAll('\n', ' ');

  void _openList(String title, List<Product> products) {
    setState(() {
      _listTitle = title;
      _listProducts = products;
    });
  }

  void _closeList() => setState(() => _listTitle = null);

  Future<void> _openCategory(String title, int categoryId,
      {bool includeSub = false}) async {
    setState(() => _loadingList = true);
    try {
      final products =
      await CategoryApi.getProducts(categoryId, includeSub: includeSub);
      if (!mounted) return;
      _openList(title, products);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  Future<void> _openSearch() async {
    setState(() => _loadingList = true);
    try {
      final lists = await Future.wait(
        _cats.map((c) => CategoryApi.getProducts(c.id, includeSub: true)),
      );
      if (!mounted) return;
      final all = lists.expand((l) => l).toList();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchScreen(products: all)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final inList = _listTitle != null;

    return PopScope(
      // Android back button closes the product list first
      canPop: !inList,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && inList) _closeList();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: inList
              ? ProductListScreen(
            key: ValueKey(_listTitle),
            products: _listProducts,
            onBack: _closeList,
          )
              : _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _loadCategories, child: const Text('Retry')),
          ],
        ),
      );
    }
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: _buildCategories(),
        ),
        if (_loadingList)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x55FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  // ── Category grid with expandable sub-categories ───────────────────────────
  Widget _buildCategories() {
    final rowCount = (_cats.length + 2) ~/ 3;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _searchBar(),
        const SizedBox(height: 20),
        const Text('Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        for (var r = 0; r < rowCount; r++) _catRow(r * 3),
      ],
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSearch,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 24, color: Colors.black87),
            SizedBox(width: 12),
            Text('What are you looking for?',
                style: TextStyle(fontSize: 15, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _catRow(int start) {
    final end = start + 3 > _cats.length ? _cats.length : start + 3;
    final openHere =
        _expanded != null && _expanded! >= start && _expanded! < end;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < 3; c++) ...[
              if (c > 0) const SizedBox(width: 12),
              Expanded(
                child: start + c < end
                    ? _catTile(start + c)
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: openHere
              ? _subPanel(_expanded!)
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _catTile(int index) {
    final cat = _cats[index];
    final selected = _expanded == index;

    return GestureDetector(
      onTap: () => setState(() => _expanded = selected ? null : index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.78,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _tileBg,
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? Border.all(color: const Color(0xFFC4C7D0), width: 2)
                    : null,
              ),
              child: _art(cat.imageUrl, _iconFor(cat.name), 44, BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.25,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? Colors.black : const Color(0xFF4A4D57),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subPanel(int catIndex) {
    final cat = _cats[catIndex];
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final sub in cat.subcategories)
            _subRow(
              sub.name,
              Icons.category_outlined,
              sub.imageUrl,
                  () => _openCategory(sub.name, sub.id),
            ),
          _subRow(
            'View all',
            Icons.menu,
            '',
                () => _openCategory(_clean(cat.name), cat.id, includeSub: true),
          ),
        ],
      ),
    );
  }

  Widget _subRow(
      String name, IconData icon, String image, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _tileBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 56,
              color: _thumbBg,
              child: _art(image, icon, 26, BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A3D48)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the network image if given, otherwise a soft placeholder icon.
  Widget _art(String image, IconData icon, double size, BoxFit fit) {
    Widget placeholder() => Center(
      child: Icon(icon, size: size, color: const Color(0xFF9AA0B4)),
    );
    if (image.isEmpty) return placeholder();
    return Image.network(
      image,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }
}