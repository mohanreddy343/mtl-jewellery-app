// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:mtl_jewellery/screens/profile_screen.dart';
// import 'package:mtl_jewellery/screens/search_screen.dart';
// import '../config/app_colors.dart';
// import '../model/product_model.dart';
// import '../services/api_service.dart';
// import '../services/category_api_service.dart';
// import '../widgets/product_card.dart';
// import 'home_tab.dart';
// import 'location_picker_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   const _SearchBarDelegate({required this.child});
//
//   @override
//   double get minExtent => 62;
//   @override
//   double get maxExtent => 62;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return child;
//   }
//
//   @override
//   bool shouldRebuild(_SearchBarDelegate oldDelegate) => true;
// }
//
// class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   const _CategoryTabsDelegate({required this.child});
//
//   @override
//   double get minExtent => 106;
//   @override
//   double get maxExtent => 106;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return child;
//   }
//
//   @override
//   bool shouldRebuild(_CategoryTabsDelegate oldDelegate) => true;
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedCategoryIndex = 0;
//   final PageController _bannerController = PageController();
//   int _currentBannerIndex = 0;
//   Timer? _bannerTimer;
//
//   // Shown in the address bar. Updated when the user picks a location on the map.
//   String _addressText = 'Tap to choose your delivery location';
//
//   // First tab is always "All"; the rest come from the /categories API.
//   List<Map<String, dynamic>> _categories = [
//     {'icon': Icons.shopping_bag_outlined, 'label': 'All'},
//   ];
//   List<CategoryModel> _parentCategories = [];
//   CategoryModel? _selectedParent;
//   List<Product> _parentProducts = [];
//   bool _catLoading = false;
//   String? _catError;
//
//   IconData _iconFor(String name) {
//     switch (name.toLowerCase()) {
//       case 'fashion':
//         return Icons.checkroom_outlined;
//       case 'mobiles':
//         return Icons.smartphone_outlined;
//       case 'beauty':
//         return Icons.face_retouching_natural_outlined;
//       case 'electronics':
//         return Icons.laptop_outlined;
//       case 'home':
//         return Icons.home_outlined;
//       default:
//         return Icons.category_outlined;
//     }
//   }
//
//   Future<void> _loadCategories() async {
//     try {
//       final cats = await CategoryApi.getCategories();
//       if (!mounted) return;
//       setState(() {
//         _parentCategories = cats;
//         _categories = [
//           <String, dynamic>{'icon': Icons.shopping_bag_outlined, 'label': 'All'},
//           ...cats.map((c) =>
//           <String, dynamic>{'icon': _iconFor(c.name), 'label': c.name}),
//         ];
//       });
//     } catch (e) {
//       // Keep just the "All" tab if categories can't be loaded.
//       debugPrint('Categories load failed: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Categories: $e')),
//       );
//     }
//   }
//
//   Future<void> _selectCategory(int index) async {
//     if (index == 0 || index > _parentCategories.length) {
//       setState(() {
//         _selectedCategoryIndex = 0;
//         _selectedParent = null;
//       });
//       return;
//     }
//
//     final parent = _parentCategories[index - 1];
//     setState(() {
//       _selectedCategoryIndex = index;
//       _selectedParent = parent;
//       _parentProducts = [];
//       _catLoading = true;
//       _catError = null;
//     });
//
//     try {
//       final items = await CategoryApi.getProducts(parent.id);
//       if (!mounted || _selectedParent?.id != parent.id) return;
//       setState(() {
//         _parentProducts = items;
//         _catLoading = false;
//       });
//     } catch (e) {
//       if (!mounted || _selectedParent?.id != parent.id) return;
//       setState(() {
//         _catError = e.toString();
//         _catLoading = false;
//       });
//     }
//   }
//
//   final List<Color> _bannerColors = [
//     const Color(0xFFFF9800),
//     const Color(0xFFFB8C00),
//     const Color(0xFFF57C00),
//   ];
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;
//
//   Future<void> _loadProducts() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final data = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = data;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = 'Could not load products.\n$e';
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//     _loadCategories();
//     _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (_bannerController.hasClients) {
//         final nextPage = (_currentBannerIndex + 1) % 3;
//         _bannerController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _bannerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.screenBackground,
//       resizeToAvoidBottomInset: false,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildAddressBarOnly(),
//           _buildStickySearchBar(),
//           SizedBox(height: 106, child: _buildCategoryTabs()),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (_selectedParent != null) return _buildParentCategoryView();
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(_error!, textAlign: TextAlign.center),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _loadProducts,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 8),
//           _buildBannerCarousel(),
//           const SizedBox(height: 12),
//           _buildStillLookingSection(),
//           const SizedBox(height: 12),
//           _buildPeopleAlsoViewedSection(),
//           const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }
//
//   // ── Location ───────────────────────────────────────────────────────────────
//   Future<void> _pickLocation() async {
//     final result = await Navigator.push<PickedLocation>(
//       context,
//       MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//     );
//     if (result != null && mounted) {
//       setState(() => _addressText = result.full);
//     }
//   }
//
//   Widget _buildAddressBarOnly() {
//     return Container(
//       color: AppColors.screenBackground,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: AppColors.screenBackground,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300, width: 1.5),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.location_on, color: Colors.orange, size: 20),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: _pickLocation,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'CURRENT',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       _addressText,
//                       style: const TextStyle(fontSize: 12, color: Colors.black54),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                 );
//               },
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: const BoxDecoration(
//                   color: Colors.orange,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.person, color: Colors.white, size: 20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openSearch() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SearchScreen(products: _products),
//       ),
//     );
//   }
//
//   Widget _buildStickySearchBar() {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _openSearch,
//       child: _searchBarBody(),
//     );
//   }
//
//   Widget _searchBarBody() {
//     return Container(
//       color: AppColors.screenBackground,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Container(
//         height: 46,
//         decoration: BoxDecoration(
//           color: AppColors.screenBackground,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.black, width: 1.5),
//         ),
//         child: const Row(
//           children: [
//             SizedBox(width: 14),
//             Icon(Icons.search, color: Colors.black45, size: 20),
//             SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 'Search products, categories, offers...',
//                 style: TextStyle(color: Colors.black38, fontSize: 13),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(0),
//       child: AppBar(
//         backgroundColor: AppColors.appBarBackground,
//         elevation: 0,
//       ),
//     );
//   }
//
//   Widget _buildCategoryTabs() {
//     return Container(
//       color: AppColors.screenBackground,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         clipBehavior: Clip.hardEdge,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Row(
//           children: List.generate(_categories.length, (index) {
//             final isSelected = _selectedCategoryIndex == index;
//             return GestureDetector(
//               onTap: () => _selectCategory(index),
//               child: Container(
//                 margin: const EdgeInsets.only(right: 16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 58,
//                       height: 58,
//                       decoration: BoxDecoration(
//                         color: isSelected ? Colors.black : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: isSelected ? Colors.black : Colors.grey.shade300,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Icon(
//                         _categories[index]['icon'] as IconData,
//                         size: 24,
//                         color: isSelected ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       _categories[index]['label'] as String,
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         color: isSelected ? Colors.black : Colors.black54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBannerCarousel() {
//     return Column(
//       children: [
//         SizedBox(
//           height: 200,
//           child: PageView.builder(
//             controller: _bannerController,
//             itemCount: 3,
//             onPageChanged: (index) => setState(() => _currentBannerIndex = index),
//             itemBuilder: (context, index) {
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: _bannerColors[index],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Banner ${index + 1}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(3, (index) {
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 3),
//               width: _currentBannerIndex == index ? 20 : 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: _currentBannerIndex == index
//                     ? Colors.black87
//                     : Colors.grey.shade400,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildParentCategoryView() {
//     final parent = _selectedParent!;
//
//     Widget sectionCard({required String title, required Widget child}) {
//       return Container(
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(horizontal: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87)),
//             const SizedBox(height: 12),
//             child,
//           ],
//         ),
//       );
//     }
//
//     Widget productsBody() {
//       if (_catLoading) {
//         return const Padding(
//           padding: EdgeInsets.symmetric(vertical: 24),
//           child: Center(child: CircularProgressIndicator()),
//         );
//       }
//       if (_catError != null) {
//         return Center(
//           child: Column(
//             children: [
//               Text(_catError!, textAlign: TextAlign.center),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () => _selectCategory(_selectedCategoryIndex),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         );
//       }
//       if (_parentProducts.isEmpty) {
//         return const Padding(
//           padding: EdgeInsets.symmetric(vertical: 16),
//           child: Text('No products in this category yet.',
//               style: TextStyle(color: Colors.black54)),
//         );
//       }
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: _parentProducts.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           mainAxisExtent: 320,
//         ),
//         itemBuilder: (context, i) =>
//             ProductCard(product: _parentProducts[i], imageHeight: 170),
//       );
//     }
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 8),
//           sectionCard(
//             title: '${parent.name} categories',
//             child: parent.subcategories.isEmpty
//                 ? const Text('No subcategories.',
//                 style: TextStyle(color: Colors.black54))
//                 : Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: parent.subcategories
//                   .map((s) => Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                   border:
//                   Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Text(s.name,
//                     style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600)),
//               ))
//                   .toList(),
//             ),
//           ),
//           const SizedBox(height: 12),
//           sectionCard(title: '${parent.name} products', child: productsBody()),
//           const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStillLookingSection() {
//     final first5 = _products.take(5).toList();
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFFFF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Still looking for these?',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 330, // adjust to match your card height
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: first5.length,
//               itemBuilder: (context, i) => SizedBox(
//                 width: 150,
//                 child: ProductCard(
//                   product: first5[i],
//                   imageHeight: 170,
//                   cardRightMargin: i < first5.length - 1 ? 10 : 0,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPeopleAlsoViewedSection() {
//     final last5 = _products.skip(5).toList();
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFFFF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'People also viewed',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               Stack(
//                 children: [
//                   const Icon(Icons.stars_outlined, color: Colors.orange, size: 28),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       width: 10,
//                       height: 10,
//                       decoration: const BoxDecoration(
//                         color: Colors.orange,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: last5.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               mainAxisExtent: 320,
//             ),
//             itemBuilder: (context, i) => ProductCard(
//               product: last5[i],
//               imageHeight: 170,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtl_jewellery/screens/profile_screen.dart';
import 'package:mtl_jewellery/screens/search_screen.dart';
import 'package:mtl_jewellery/screens/sub_category_screen.dart';
import '../config/app_colors.dart';
import '../model/product_model.dart';
import '../services/api_service.dart';
import '../services/category_api_service.dart';
import '../widgets/product_card.dart';
import 'home_tab.dart';
import 'location_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _SearchBarDelegate({required this.child});

  @override
  double get minExtent => 62;
  @override
  double get maxExtent => 62;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => true;
}

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _CategoryTabsDelegate({required this.child});

  @override
  double get minExtent => 106;
  @override
  double get maxExtent => 106;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_CategoryTabsDelegate oldDelegate) => true;
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  // Shown in the address bar. Updated when the user picks a location on the map.
  String _addressText = 'Tap to choose your delivery location';

  // First tab is always "All"; the rest come from the /categories API.
  List<Map<String, dynamic>> _categories = [
    {'icon': Icons.shopping_bag_outlined, 'label': 'All'},
  ];
  List<CategoryModel> _parentCategories = [];
  CategoryModel? _selectedParent;
  List<Product> _parentProducts = [];
  bool _catLoading = false;
  String? _catError;

  IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'fashion':
        return Icons.checkroom_outlined;
      case 'mobiles':
        return Icons.smartphone_outlined;
      case 'beauty':
        return Icons.face_retouching_natural_outlined;
      case 'electronics':
        return Icons.laptop_outlined;
      case 'home':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryApi.getCategories();
      if (!mounted) return;
      setState(() {
        _parentCategories = cats;
        _categories = [
          <String, dynamic>{'icon': Icons.shopping_bag_outlined, 'label': 'All'},
          ...cats.map((c) =>
          <String, dynamic>{'icon': _iconFor(c.name), 'label': c.name}),
        ];
      });
    } catch (e) {
      // Keep just the "All" tab if categories can't be loaded.
      debugPrint('Categories load failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categories: $e')),
      );
    }
  }

  Future<void> _selectCategory(int index) async {
    if (index == 0 || index > _parentCategories.length) {
      setState(() {
        _selectedCategoryIndex = 0;
        _selectedParent = null;
      });
      return;
    }

    final parent = _parentCategories[index - 1];
    setState(() {
      _selectedCategoryIndex = index;
      _selectedParent = parent;
      _parentProducts = [];
      _catLoading = true;
      _catError = null;
    });

    try {
      final items = await CategoryApi.getProducts(parent.id);
      if (!mounted || _selectedParent?.id != parent.id) return;
      setState(() {
        _parentProducts = items;
        _catLoading = false;
      });
    } catch (e) {
      if (!mounted || _selectedParent?.id != parent.id) return;
      setState(() {
        _catError = e.toString();
        _catLoading = false;
      });
    }
  }

  void _openSubcategory(CategoryModel parent, CategoryModel sub) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubcategoryScreen(parent: parent, initialSub: sub),
      ),
    );
  }

  final List<Color> _bannerColors = [
    const Color(0xFFFF9800),
    const Color(0xFFFB8C00),
    const Color(0xFFF57C00),
  ];
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load products.\n$e';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildAddressBarOnly(),
          _buildStickySearchBar(),
          SizedBox(height: 106, child: _buildCategoryTabs()),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedParent != null) return _buildParentCategoryView();
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildBannerCarousel(),
          const SizedBox(height: 12),
          _buildStillLookingSection(),
          const SizedBox(height: 12),
          _buildPeopleAlsoViewedSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Location ───────────────────────────────────────────────────────────────
  Future<void> _pickLocation() async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null && mounted) {
      setState(() => _addressText = result.full);
    }
  }

  Widget _buildAddressBarOnly() {
    return Container(
      color: AppColors.screenBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.screenBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickLocation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _addressText,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(products: _products),
      ),
    );
  }

  Widget _buildStickySearchBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSearch,
      child: _searchBarBody(),
    );
  }

  Widget _searchBarBody() {
    return Container(
      color: AppColors.screenBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.screenBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Row(
          children: [
            SizedBox(width: 14),
            Icon(Icons.search, color: Colors.black45, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search products, categories, offers...',
                style: TextStyle(color: Colors.black38, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(0),
      child: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.screenBackground,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(_categories.length, (index) {
            final isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => _selectCategory(index),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _categories[index]['icon'] as IconData,
                        size: 24,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _categories[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: 3,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _bannerColors[index],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Banner ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? Colors.black87
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Parent category view: subcategory chips + the parent's direct products ─
  Widget _buildParentCategoryView() {
    final parent = _selectedParent!;

    Widget sectionCard({required String title, required Widget child}) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
    }

    Widget productsBody() {
      if (_catLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_catError != null) {
        return Center(
          child: Column(
            children: [
              Text(_catError!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectCategory(_selectedCategoryIndex),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      if (_parentProducts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No products in this category yet.',
              style: TextStyle(color: Colors.black54)),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _parentProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 320,
        ),
        itemBuilder: (context, i) =>
            ProductCard(product: _parentProducts[i], imageHeight: 170),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          sectionCard(
            title: '${parent.name} categories',
            child: parent.subcategories.isEmpty
                ? const Text('No subcategories.',
                style: TextStyle(color: Colors.black54))
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: parent.subcategories
                  .map((s) => GestureDetector(
                onTap: () => _openSubcategory(parent, s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(s.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          sectionCard(title: '${parent.name} products', child: productsBody()),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStillLookingSection() {
    final first5 = _products.take(5).toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Still looking for these?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 330, // adjust to match your card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: first5.length,
              itemBuilder: (context, i) => SizedBox(
                width: 150,
                child: ProductCard(
                  product: first5[i],
                  imageHeight: 170,
                  cardRightMargin: i < first5.length - 1 ? 10 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleAlsoViewedSection() {
    final last5 = _products.skip(5).toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'People also viewed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Stack(
                children: [
                  const Icon(Icons.stars_outlined, color: Colors.orange, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: last5.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 320,
            ),
            itemBuilder: (context, i) => ProductCard(
              product: last5[i],
              imageHeight: 170,
            ),
          ),
        ],
      ),
    );
  }
}