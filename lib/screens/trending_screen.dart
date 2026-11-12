// import 'package:flutter/material.dart';
//
// class TrendingScreen extends StatefulWidget {
//   const TrendingScreen({super.key});
//
//   @override
//   State<TrendingScreen> createState() => _TrendingScreenState();
// }
//
// class _TrendingScreenState extends State<TrendingScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   final List<String> _tabs = ['All', 'Fashion', 'Electronics', 'Home', 'Beauty'];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildTabBar(),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: List.generate(
//                 _tabs.length,
//                     (index) => _buildTrendingContent(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       title: const Text(
//         'Trending',
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.black),
//           onPressed: () {},
//         ),
//         IconButton(
//           icon: const Icon(Icons.notifications_outlined, color: Colors.black),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTabBar() {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: const Color(0xFF2874F0),
//         unselectedLabelColor: Colors.black54,
//         indicatorColor: const Color(0xFF2874F0),
//         indicatorWeight: 2.5,
//         labelStyle:
//         const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//         unselectedLabelStyle:
//         const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
//         tabs: _tabs.map((t) => Tab(text: t)).toList(),
//       ),
//     );
//   }
//
//   Widget _buildTrendingContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTrendingBanner(),
//           const SizedBox(height: 16),
//           _buildTrendingDealsSection(),
//           const SizedBox(height: 16),
//           _buildTopBrandsSection(),
//           const SizedBox(height: 16),
//           _buildFlashSaleSection(),
//           const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTrendingBanner() {
//     return Container(
//       height: 150,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2874F0), Color(0xFF0047BB)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: 20,
//             top: 20,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   '🔥 Trending Now',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   'Up to 70% OFF',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'On most trending products',
//                   style: TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTrendingDealsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Trending Deals',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 'See All',
//                 style: TextStyle(color: Color(0xFF2874F0), fontSize: 13),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: 4,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             mainAxisSpacing: 10,
//             crossAxisSpacing: 10,
//             childAspectRatio: 0.8,
//           ),
//           itemBuilder: (context, index) => _trendingDealCard(index),
//         ),
//       ],
//     );
//   }
//
//   Widget _trendingDealCard(int index) {
//     final List<Color> colors = [
//       Colors.blue.shade50,
//       Colors.orange.shade50,
//       Colors.green.shade50,
//       Colors.purple.shade50,
//     ];
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade100,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: colors[index],
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
//               ),
//               child: Stack(
//                 children: [
//                   const Center(
//                     child: Icon(Icons.image_outlined, color: Colors.grey, size: 36),
//                   ),
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Text(
//                         '50% OFF',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Product Name ${index + 1}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Text(
//                       '₹999',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       '₹1,999',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade500,
//                         decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTopBrandsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Top Brands',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(6, (index) {
//               return Container(
//                 margin: const EdgeInsets.only(right: 10),
//                 width: 80,
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.grey.shade100,
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: const Icon(Icons.storefront_outlined,
//                           color: Colors.grey, size: 30),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Brand ${index + 1}',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 11, color: Colors.black87),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFlashSaleSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.flash_on, color: Colors.orange, size: 20),
//             const SizedBox(width: 4),
//             const Text(
//               'Flash Sale',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: const Text(
//                 'Ends in 02:34:56',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(5, (index) {
//               return Container(
//                 margin: const EdgeInsets.only(right: 10),
//                 width: 130,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade200),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 110,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(10)),
//                       ),
//                       child: const Center(
//                         child: Icon(Icons.image_outlined,
//                             color: Colors.grey, size: 30),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Flash Item ${index + 1}',
//                             style: const TextStyle(
//                                 fontSize: 11, color: Colors.black87),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               const Text(
//                                 '₹499',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '₹999',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey.shade500,
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           LinearProgressIndicator(
//                             value: 0.7,
//                             backgroundColor: Colors.grey.shade200,
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 Colors.orange),
//                             minHeight: 4,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                           const SizedBox(height: 2),
//                           const Text(
//                             '70% sold',
//                             style: TextStyle(
//                                 fontSize: 9, color: Colors.orange),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/widgets/product_card.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Fashion', 'Electronics', 'Home', 'Beauty'];

  // Same real `Product` model as the home screen. Same ids ('1'..'10') means
  // the cart quantity stays in sync between Home and Trending.
  // TODO: replace with the products you load from your API.
  final List<Product> _products = [
    Product(id: '1',  name: 'Wireless Bluetooth Earbuds Pro Max',   price: 999,  originalPrice: 1999, image: '', imageUrl: '', category: 'Electronics', weight: '50g',  sku: 'SKU001', discountPercentage: 50, quantity: 10, posQuantity: 10),
    Product(id: '2',  name: 'Men\'s Slim Fit Casual T-Shirt',        price: 349,  originalPrice: 699,  image: '', imageUrl: '', category: 'Fashion',     weight: '200g', sku: 'SKU002', discountPercentage: 50, quantity: 25, posQuantity: 25),
    Product(id: '3',  name: 'Vitamin C Face Serum 30ml',             price: 449,  originalPrice: 899,  image: '', imageUrl: '', category: 'Beauty',      weight: '30ml', sku: 'SKU003', discountPercentage: 50, quantity: 15, posQuantity: 15),
    Product(id: '4',  name: 'Mechanical Gaming Keyboard RGB',        price: 1799, originalPrice: 2999, image: '', imageUrl: '', category: 'Electronics', weight: '850g', sku: 'SKU004', discountPercentage: 40, quantity: 8,  posQuantity: 8),
    Product(id: '5',  name: 'Women\'s Running Sneakers Light Foam',  price: 799,  originalPrice: 1499, image: '', imageUrl: '', category: 'Fashion',     weight: '300g', sku: 'SKU005', discountPercentage: 47, quantity: 20, posQuantity: 20),
    Product(id: '6',  name: 'Stainless Steel Water Bottle 1L',       price: 299,  originalPrice: 599,  image: '', imageUrl: '', category: 'Home',        weight: '400g', sku: 'SKU006', discountPercentage: 50, quantity: 30, posQuantity: 30),
    Product(id: '7',  name: 'SPF 50 Sunscreen Lotion 100ml',         price: 249,  originalPrice: 449,  image: '', imageUrl: '', category: 'Beauty',      weight: '100ml',sku: 'SKU007', discountPercentage: 44, quantity: 0,  posQuantity: 0),
    Product(id: '8',  name: 'Smart LED Desk Lamp USB Charging',      price: 599,  originalPrice: 999,  image: '', imageUrl: '', category: 'Electronics', weight: '600g', sku: 'SKU008', discountPercentage: 40, quantity: 12, posQuantity: 12),
    Product(id: '9',  name: 'Cotton Bath Towel Set of 2 Soft',       price: 399,  originalPrice: 799,  image: '', imageUrl: '', category: 'Home',        weight: '500g', sku: 'SKU009', discountPercentage: 50, quantity: 18, posQuantity: 18),
    Product(id: '10', name: 'Smartphone Tempered Glass Screen Guard', price: 99,  originalPrice: 199,  image: '', imageUrl: '', category: 'Mobiles',     weight: '20g',  sku: 'SKU010', discountPercentage: 50, quantity: 50, posQuantity: 50),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                _tabs.length,
                    (index) => _buildTrendingContent(),
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
        controller: _tabController,
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

  Widget _buildTrendingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingBanner(),
          const SizedBox(height: 16),
          _buildTrendingDealsSection(),
          const SizedBox(height: 16),
          _buildTopBrandsSection(),
          const SizedBox(height: 16),
          _buildFlashSaleSection(),
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

  // ── Trending Deals (ProductCard, same as home screen) ──────────────────────
  Widget _buildTrendingDealsSection() {
    final deals = _products.take(4).toList();
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
            mainAxisExtent: 320, // same as the home screen grid
          ),
          itemBuilder: (context, i) => ProductCard(
            product: deals[i],
            imageHeight: 170,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Brands',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(6, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 80,
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.storefront_outlined,
                          color: Colors.grey, size: 30),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Brand ${index + 1}',
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Flash Sale (ProductCard, same as home "Still looking" row) ─────────────
  Widget _buildFlashSaleSection() {
    final flash = _products.skip(4).take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.orange, size: 20),
            const SizedBox(width: 4),
            const Text(
              'Flash Sale',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ends in 02:34:56',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(flash.length, (i) {
              return SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductCard(
                      product: flash[i],
                      imageHeight: 170,
                      cardRightMargin: i < flash.length - 1 ? 10 : 0,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.only(
                          right: i < flash.length - 1 ? 10 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '70% sold',
                            style:
                            TextStyle(fontSize: 9, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}