import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/widgets/product_card.dart';

/// Search page opened from the home screen search bar.
/// Filters the given [products] by name, category or SKU as you type.
class SearchScreen extends StatefulWidget {
  final List<Product> products;
  const SearchScreen({super.key, required this.products});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _pink = Color(0xFFFF0080);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final set = widget.products.map((p) => p.category).toSet().toList();
    set.sort();
    return set;
  }

  List<Product> get _results {
    final words = _query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];

    return widget.products.where((p) {
      final haystack = '${p.name} ${p.category} ${p.sku}'.toLowerCase();
      return words.every(haystack.contains);
    }).toList();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: value.length));
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _searchField(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  // ── Search field ───────────────────────────────────────────────────────────
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  hintText: 'Search products, categories, offers...',
                  hintStyle:
                  const TextStyle(color: Colors.black38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.black45, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.black54, size: 18),
                    onPressed: () => _setQuery(''),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _body() {
    if (_query.trim().isEmpty) return _suggestions();

    final results = _results;
    if (results.isEmpty) return _noResults();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            '${results.length} ${results.length == 1 ? 'result' : 'results'}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 320,
            ),
            itemBuilder: (context, i) =>
                ProductCard(product: results[i], imageHeight: 170),
          ),
        ),
      ],
    );
  }

  Widget _suggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        const Text('Browse categories',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories
              .map((c) => ActionChip(
            label: Text(c),
            backgroundColor: Colors.grey.shade100,
            side: BorderSide(color: Colors.grey.shade300),
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87),
            onPressed: () => _setQuery(c),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _noResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _pink, width: 2),
              ),
              child: const Icon(Icons.search_off, size: 48, color: _pink),
            ),
            const SizedBox(height: 20),
            const Text('No products found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Nothing matches "${_query.trim()}".\nTry a different word or pick a category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}