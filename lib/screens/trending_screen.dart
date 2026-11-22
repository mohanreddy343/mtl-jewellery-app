import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/screens/sub_category_screen.dart';
import 'package:mtl_jewellery/widgets/product_card.dart';

import '../services/api_service.dart';
import '../services/category_api_service.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  // First tab is "All"; the rest are the parent categories from the API.
  List<String> _tabs = ['All'];
  List<CategoryModel> _cats = [];
  List<Product> _allProducts = [];
  List<List<Product>> _catProducts = []; // index = category index
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final cats = await CategoryApi.getCategories();
      final all = await ApiService.getProducts();
      final lists = await Future.wait(
        cats.map((c) => CategoryApi.getProducts(c.id, includeSub: true)),
      );
      if (!mounted) return;
      setState(() {
        _cats = cats;
        _allProducts = all;
        _catProducts = lists;
        _tabs = ['All', ...cats.map((c) => c.name)];
        _loading = false;
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
        _error = 'Could not load trending.\n$e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() => _load(silent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
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
    // Built only after loading, so the tab count is always correct.
    // The key rebuilds the controller if the number of tabs ever changes.
    return DefaultTabController(
      key: ValueKey(_tabs.length),
      length: _tabs.length,
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              children: List.generate(
                _tabs.length,
                    (i) => RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildTrendingContent(i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Trending',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        isScrollable: true,
        labelColor: const Color(0xFF2874F0),
        unselectedLabelColor: Colors.black54,
        indicatorColor: const Color(0xFF2874F0),
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildTrendingContent(int index) {
    final products = index == 0 ? _allProducts : _catProducts[index - 1];
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingBanner(),
          const SizedBox(height: 16),
          _buildTrendingDealsSection(products),
          const SizedBox(height: 16),
          _buildCategoryChips(index),
          const SizedBox(height: 16),
          _buildMoreSection(products),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTrendingBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2874F0), Color(0xFF0047BB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🔥 Trending Now',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Up to 70% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'On most trending products',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDealsSection(List<Product> products) {
    final deals = products.take(4).toList();
    if (deals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No products yet.',
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trending Deals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(color: Color(0xFF2874F0), fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: deals.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 320,
          ),
          itemBuilder: (context, i) => ProductCard(
            product: deals[i],
            imageHeight: 170,
          ),
        ),
      ],
    );
  }

  // Real categories: parents on the "All" tab, subcategories on a parent tab.
  Widget _buildCategoryChips(int index) {
    final isAll = index == 0;
    final parent = isAll ? null : _cats[index - 1];
    final items = isAll ? _cats : parent!.subcategories;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAll ? 'Shop by category' : '${parent!.name} categories',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((c) {
            return GestureDetector(
              onTap: () {
                if (isAll) {
                  DefaultTabController.of(context)
                      .animateTo(_cats.indexOf(c) + 1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SubcategoryScreen(parent: parent!, initialSub: c),
                    ),
                  );
                }
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          c.imageUrl,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const SizedBox(width: 24, height: 24),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(c.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Remaining real products as a horizontal row.
  Widget _buildMoreSection(List<Product> products) {
    final more = products.skip(4).take(10).toList();
    if (more.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More to explore',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: more.length,
            itemBuilder: (context, i) => SizedBox(
              width: 150,
              child: ProductCard(
                product: more[i],
                imageHeight: 170,
                cardRightMargin: i < more.length - 1 ? 10 : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}