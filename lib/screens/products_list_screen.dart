import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/screens/search_screen.dart';
import 'package:mtl_jewellery/widgets/product_card.dart';

enum _Sort { relevance, priceLow, priceHigh, discount }

const Map<_Sort, String> _sortLabels = {
  _Sort.relevance: 'Relevance',
  _Sort.priceLow: 'Price: Low to High',
  _Sort.priceHigh: 'Price: High to Low',
  _Sort.discount: 'Discount',
};

/// Product listing shown after tapping a sub-category.
/// It is embedded inside the Categories tab (not pushed as a new route), so
/// the bottom navigation bar stays visible.
///
/// Brand = first word of the product name until your API gives a brand field.
class ProductListScreen extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onBack;

  const ProductListScreen({
    super.key,
    required this.products,
    required this.onBack,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  static const _pink = Color(0xFFFF0080);
  static const _blue = Color(0xFF2F5FE8);

  bool _onlyDeals = false;
  String? _brand;
  _Sort _sort = _Sort.relevance;

  // ── Data helpers ───────────────────────────────────────────────────────────
  String _brandOf(Product p) => p.name.split(' ').first;

  List<String> get _brands {
    final seen = <String>[];
    for (final p in widget.products) {
      final b = _brandOf(p);
      if (!seen.contains(b)) seen.add(b);
    }
    return seen;
  }

  bool get _filtersActive => _onlyDeals || _brand != null;

  List<Product> get _visible {
    final list = widget.products.where((p) {
      if (_onlyDeals && p.computedDiscount < 40) return false;
      if (_brand != null && _brandOf(p) != _brand) return false;
      return true;
    }).toList();

    switch (_sort) {
      case _Sort.relevance:
        break;
      case _Sort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _Sort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _Sort.discount:
        list.sort((a, b) => b.computedDiscount.compareTo(a.computedDiscount));
        break;
    }
    return list;
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(products: widget.products),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _chips()),
                  SliverToBoxAdapter(child: _brandSection()),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _empty(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, i) => ProductCard(
                              product: items[i], imageHeight: 170),
                          childCount: items.length,
                        ),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 320,
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(child: _pill()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Top search bar with back arrow ─────────────────────────────────────────
  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.chevron_left, size: 28),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openSearch,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('Search',
                    style: TextStyle(fontSize: 16, color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────
  Widget _chips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          _chip('Deals', Icons.local_offer_outlined, _onlyDeals,
                  () => setState(() => _onlyDeals = !_onlyDeals)),
          const SizedBox(width: 10),
          _chip('Brand', Icons.sell_outlined, _brand != null, _openFilter,
              chevron: true),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, bool active, VoidCallback onTap,
      {bool chevron = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? Colors.black87 : Colors.grey.shade300,
              width: active ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
            if (chevron) ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  // ── Shop by brand ──────────────────────────────────────────────────────────
  Widget _brandSection() {
    final brands = _brands;
    if (brands.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Shop by brand',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final b = brands[i];
                final selected = _brand == b;
                return GestureDetector(
                  onTap: () => setState(() => _brand = selected ? null : b),
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(b,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.black38),
          const SizedBox(height: 12),
          const Text('No products match your filters',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          TextButton(
            onPressed: () => setState(() {
              _onlyDeals = false;
              _brand = null;
            }),
            child: const Text('Clear filters',
                style: TextStyle(color: _pink)),
          ),
        ],
      ),
    );
  }

  // ── Floating Sort | Filter pill ────────────────────────────────────────────
  Widget _pill() {
    Widget button(String label, IconData icon, VoidCallback onTap,
        {bool dot = false}) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Icon(icon, color: Colors.white, size: 20),
              if (dot) ...[
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button('Sort', Icons.swap_vert, _openSort),
          Container(width: 1, height: 22, color: Colors.white54),
          button('Filter', Icons.filter_alt_outlined, _openFilter,
              dot: _filtersActive),
        ],
      ),
    );
  }

  // ── Bottom sheets ──────────────────────────────────────────────────────────
  void _openSort() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sort by',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ),
            for (final s in _Sort.values)
              ListTile(
                title: Text(_sortLabels[s]!),
                trailing: s == _sort
                    ? const Icon(Icons.check, color: _blue)
                    : null,
                onTap: () {
                  setState(() => _sort = s);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openFilter() {
    var deals = _onlyDeals;
    String? brand = _brand;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Filter',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    TextButton(
                      onPressed: () => setSheet(() {
                        deals = false;
                        brand = null;
                      }),
                      child: const Text('Reset',
                          style: TextStyle(color: _pink)),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deals (40% off or more)'),
                  value: deals,
                  onChanged: (v) => setSheet(() => deals = v),
                ),
                const SizedBox(height: 8),
                const Text('Brand',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in _brands)
                      ChoiceChip(
                        label: Text(b),
                        selected: brand == b,
                        onSelected: (sel) =>
                            setSheet(() => brand = sel ? b : null),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _onlyDeals = deals;
                        _brand = brand;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}