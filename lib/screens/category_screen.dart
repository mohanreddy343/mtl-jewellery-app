// import 'package:flutter/material.dart';
// import 'package:mtl_jewellery/model/product_model.dart';
// import 'package:mtl_jewellery/widgets/product_card.dart';
//
// /// Small helper used only to build the sample catalog below.
// class _Item {
//   final String name;
//   final double price;
//   final double original;
//   const _Item(this.name, this.price, this.original);
// }
//
// class CategoryScreen extends StatefulWidget {
//   const CategoryScreen({super.key});
//
//   @override
//   State<CategoryScreen> createState() => _CategoryScreenState();
// }
//
// class _CategoryScreenState extends State<CategoryScreen> {
//   static const _blue = Color(0xFF2874F0);
//
//   int _selectedParent = 0;
//   late String _selectedSub;
//   final ScrollController _leftScroll = ScrollController();
//
//   final List<Map<String, dynamic>> _leftCategories = [
//     {'icon': Icons.shopping_bag_outlined, 'label': 'For You'},
//     {'icon': Icons.local_grocery_store_outlined, 'label': 'Grocery'},
//     {'icon': Icons.checkroom_outlined, 'label': 'Fashion'},
//     {'icon': Icons.kitchen_outlined, 'label': 'Appliances'},
//     {'icon': Icons.smartphone_outlined, 'label': 'Mobiles'},
//     {'icon': Icons.devices_outlined, 'label': 'Electronics'},
//     {'icon': Icons.watch_outlined, 'label': 'Smart Gadgets'},
//     {'icon': Icons.home_outlined, 'label': 'Home'},
//     {'icon': Icons.face_retouching_natural_outlined, 'label': 'Beauty &\nPersonal Care'},
//   ];
//
//   // Parent label -> sub-categories (keys must match the labels above)
//   static const Map<String, List<String>> _subCategories = {
//     'For You': ['Trending Now', 'Top Deals'],
//     'Grocery': ['Fruits & Veg', 'Snacks'],
//     'Fashion': ['Men', 'Women', 'Kids'],
//     'Appliances': ['Kitchen', 'Cleaning'],
//     'Mobiles': ['Smartphones', 'Accessories'],
//     'Electronics': ['Audio', 'Computers & Gaming'],
//     'Smart Gadgets': ['Smart Watches', 'Smart Home'],
//     'Home': ['Kitchen & Dining', 'Bath & Decor'],
//     'Beauty &\nPersonal Care': ['Skin Care', 'Sun Care'],
//   };
//
//   // Sub-category -> sample products (replace with your real API data later)
//   static const Map<String, List<_Item>> _catalog = {
//     'Trending Now': [
//       _Item('Wireless Bluetooth Earbuds Pro', 14, 29),
//       _Item('Smart Fitness Band 7', 18, 35),
//       _Item('Portable Power Bank 20000mAh', 9, 16),
//     ],
//     'Top Deals': [
//       _Item('Stainless Steel Water Bottle 1L', 3, 7),
//       _Item('LED Desk Lamp USB Charging', 6, 11),
//       _Item('Cotton Bath Towel Set of 2', 5, 10),
//     ],
//     'Fruits & Veg': [
//       _Item('Fresh Red Apples 1kg', 4, 6),
//       _Item('Organic Bananas 1kg', 3, 5),
//       _Item('Baby Spinach 250g', 3, 5),
//     ],
//     'Snacks': [
//       _Item('Salted Potato Chips Family Pack', 3, 5),
//       _Item('Roasted Mixed Nuts 500g', 8, 12),
//       _Item('Chocolate Cookies 6 Pack', 4, 7),
//     ],
//     'Men': [
//       _Item('Men Slim Fit Casual T-Shirt', 7, 14),
//       _Item('Men Running Shoes', 22, 40),
//       _Item('Men Denim Jacket', 25, 45),
//     ],
//     'Women': [
//       _Item('Women Running Sneakers Light Foam', 20, 38),
//       _Item('Women Floral Summer Dress', 15, 30),
//       _Item('Women Leather Handbag', 28, 50),
//     ],
//     'Kids': [
//       _Item('Kids Cotton Pyjama Set', 8, 15),
//       _Item('Kids School Backpack', 10, 18),
//       _Item('Kids Sports Sandals', 9, 16),
//     ],
//     'Kitchen': [
//       _Item('Air Fryer 4L Digital', 35, 60),
//       _Item('Electric Kettle 1.7L', 9, 16),
//       _Item('Hand Blender 600W', 12, 22),
//     ],
//     'Cleaning': [
//       _Item('Robot Vacuum Cleaner', 85, 140),
//       _Item('Steam Iron 2400W', 14, 25),
//       _Item('Handheld Cordless Vacuum', 30, 50),
//     ],
//     'Smartphones': [
//       _Item('Flagship 5G Smartphone 256GB', 258, 453),
//       _Item('Pro Max 5G Smartphone 512GB', 297, 453),
//       _Item('Mid-Range 5G Smartphone 128GB', 75, 110),
//     ],
//     'Accessories': [
//       _Item('Smartphone Tempered Glass Screen Guard', 3, 6),
//       _Item('Fast Charging Cable 2m', 4, 8),
//       _Item('Silicone Phone Case', 4, 9),
//     ],
//     'Audio': [
//       _Item('Over-Ear Wireless Headphones', 24, 45),
//       _Item('Bluetooth Speaker Waterproof', 15, 28),
//       _Item('Wired Earphones with Mic', 3, 7),
//     ],
//     'Computers & Gaming': [
//       _Item('Mechanical Gaming Keyboard RGB', 22, 38),
//       _Item('Wireless Gaming Mouse', 12, 22),
//       _Item('Laptop Cooling Pad', 10, 18),
//     ],
//     'Smart Watches': [
//       _Item('Smart Watch AMOLED Display', 32, 60),
//       _Item('Kids GPS Smart Watch', 25, 45),
//       _Item('Fitness Tracker Band', 12, 24),
//     ],
//     'Smart Home': [
//       _Item('Smart Wi-Fi Plug 2 Pack', 8, 15),
//       _Item('Smart LED Bulb RGB', 6, 12),
//       _Item('Wi-Fi Security Camera 1080p', 18, 32),
//     ],
//     'Kitchen & Dining': [
//       _Item('Non-Stick Cookware Set 7 Pcs', 28, 50),
//       _Item('Glass Food Storage Containers 5 Pcs', 12, 22),
//       _Item('Dinner Set 24 Pieces', 30, 55),
//     ],
//     'Bath & Decor': [
//       _Item('Luxury Bath Towel Set of 4', 12, 22),
//       _Item('Decorative Wall Clock', 9, 17),
//       _Item('Scented Candle Gift Set', 6, 12),
//     ],
//     'Skin Care': [
//       _Item('Vitamin C Face Serum 30ml', 9, 18),
//       _Item('Hydrating Face Moisturiser 50ml', 7, 14),
//       _Item('Gentle Foaming Face Wash 150ml', 4, 8),
//     ],
//     'Sun Care': [
//       _Item('SPF 50 Sunscreen Lotion 100ml', 6, 11),
//       _Item('After Sun Soothing Gel 200ml', 5, 9),
//       _Item('SPF 30 Lip Balm', 2, 4),
//     ],
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedSub = _subsOf(0).first;
//   }
//
//   @override
//   void dispose() {
//     _leftScroll.dispose();
//     super.dispose();
//   }
//
//   // ── Data helpers ───────────────────────────────────────────────────────────
//   List<String> _subsOf(int parentIndex) =>
//       _subCategories[_leftCategories[parentIndex]['label'] as String] ??
//           const [];
//
//   String _clean(String s) => s.replaceAll('\n', ' ');
//
//   List<Product> _productsFor(String sub) {
//     final items = _catalog[sub] ?? const <_Item>[];
//     final key = sub.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
//     return [
//       for (var i = 0; i < items.length; i++)
//         Product(
//           id: 'cat_${key}_$i', // unique ids so cart lines never collide
//           name: items[i].name,
//           price: items[i].price,
//           originalPrice: items[i].original,
//           image: '',
//           imageUrl: '',
//           category: sub,
//           weight: '',
//           sku: 'CAT-$key-$i',
//           discountPercentage: 0,
//           quantity: 20,
//           posQuantity: 20,
//         ),
//     ];
//   }
//
//   void _selectParent(int index) {
//     if (index == _selectedParent) return;
//     setState(() {
//       _selectedParent = index;
//       _selectedSub = _subsOf(index).first;
//     });
//     // Selected parent moves to the top, so jump the list back to the top.
//     if (_leftScroll.hasClients) _leftScroll.jumpTo(0);
//   }
//
//   // ── Build ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(context),
//       body: Row(
//         children: [
//           _buildLeftPanel(),
//           _buildRightPanel(),
//         ],
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       title: const Text(
//         'All Categories',
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.black),
//           onPressed: () {},
//         ),
//         IconButton(
//           icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
//           onPressed: () {},
//         ),
//         IconButton(
//           icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
//
//   // ── Left panel: selected parent on top, its sub-categories under it,
//   //    then the remaining parents ─────────────────────────────────────────────
//   Widget _buildLeftPanel() {
//     final others = [
//       for (var i = 0; i < _leftCategories.length; i++)
//         if (i != _selectedParent) i,
//     ];
//
//     return Container(
//       width: 90,
//       color: Colors.grey.shade100,
//       child: ListView(
//         controller: _leftScroll,
//         children: [
//           _parentTile(_selectedParent),
//           ..._subsOf(_selectedParent).map(_subTile),
//           if (others.isNotEmpty) Divider(height: 1, color: Colors.grey.shade300),
//           ...others.map(_parentTile),
//         ],
//       ),
//     );
//   }
//
//   Widget _parentTile(int index) {
//     final isSelected = index == _selectedParent;
//     return GestureDetector(
//       onTap: () => _selectParent(index),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : Colors.transparent,
//           border: isSelected
//               ? const Border(left: BorderSide(color: _blue, width: 3))
//               : null,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 54,
//               height: 54,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 _leftCategories[index]['icon'] as IconData,
//                 size: 26,
//                 color: isSelected ? _blue : Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               _leftCategories[index]['label'] as String,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? _blue : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _subTile(String sub) {
//     final isSelected = sub == _selectedSub;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedSub = sub),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : Colors.grey.shade50,
//           border: isSelected
//               ? const Border(left: BorderSide(color: _blue, width: 3))
//               : null,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.category_outlined,
//                 size: 20,
//                 color: isSelected ? _blue : Colors.black45,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               sub,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                 color: isSelected ? _blue : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Right panel: products of the selected sub-category ─────────────────────
//   Widget _buildRightPanel() {
//     final products = _productsFor(_selectedSub);
//     final parentLabel =
//     _clean(_leftCategories[_selectedParent]['label'] as String);
//
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(parentLabel,
//                     style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 2),
//                 Text(_selectedSub,
//                     style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87)),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${products.length} ${products.length == 1 ? 'product' : 'products'}',
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: products.isEmpty
//                 ? Center(
//               child: Text('No products yet',
//                   style: TextStyle(
//                       fontSize: 13, color: Colors.grey.shade600)),
//             )
//                 : GridView.builder(
//               key: ValueKey(_selectedSub), // resets scroll on change
//               padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
//               itemCount: products.length,
//               gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 mainAxisExtent: 275,
//               ),
//               itemBuilder: (context, i) =>
//                   ProductCard(product: products[i], imageHeight: 120),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mtl_jewellery/model/product_model.dart';
import 'package:mtl_jewellery/screens/products_list_screen.dart';
import 'package:mtl_jewellery/screens/search_screen.dart';

// ── Sample data models (replace with your API data later) ────────────────────
/// One sample product: brand + model, price, original price.
class _I {
  final String brand;
  final String model;
  final double price;
  final double original;
  const _I(this.brand, this.model, this.price, this.original);
}

class _Sub {
  final String name;
  final IconData icon;
  final List<_I> items;
  final String image; // optional image URL, empty = show icon
  const _Sub(this.name, this.icon, this.items, {this.image = ''});
}

class _Cat {
  final String name;
  final IconData icon;
  final List<_Sub> subs;
  final String image; // optional image URL, empty = show icon
  const _Cat(this.name, this.icon, this.subs, {this.image = ''});
}

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

  // When set, the product list screen is shown in place of the categories
  String? _listTitle;
  List<Product> _listProducts = const [];

  // ── Catalog. Add `image: 'https://...'` to _Cat / _Sub to show photos. ─────
  static const List<_Cat> _cats = [
    _Cat('Mobiles &\naccessories', Icons.smartphone_outlined, [
      _Sub('Mobiles', Icons.smartphone_outlined, [
        _I('Samsung', 'Galaxy S25 Ultra 256GB', 258, 453),
        _I('Apple', 'iPhone 16 Pro Max 256GB', 355, 453),
        _I('Xiaomi', '15 Ultra 512GB', 249, 330),
        _I('Huawei', 'Pura 70 Pro 256GB', 189, 280),
      ]),
      _Sub('Power banks', Icons.battery_charging_full_outlined, [
        _I('Anker', 'PowerCore 20000mAh', 14, 25),
        _I('Xiaomi', '20000mAh Power Bank', 12, 20),
        _I('Baseus', 'Fast Charge 10000mAh', 9, 16),
      ]),
      _Sub('Headphones & earphones', Icons.headphones_outlined, [
        _I('Sony', 'WH-1000XM5 Headphones', 105, 155),
        _I('Apple', 'AirPods Pro 2', 79, 105),
        _I('JBL', 'Tune 520BT Headphones', 18, 30),
      ]),
      _Sub('Wearables', Icons.watch_outlined, [
        _I('Samsung', 'Galaxy Watch 7', 89, 130),
        _I('Apple', 'Watch Series 10', 135, 165),
        _I('Huawei', 'Watch GT 5', 75, 110),
      ]),
      _Sub('Tablets', Icons.tablet_mac_outlined, [
        _I('Xiaomi', 'Pad 7 11.2-inch 8GB', 94, 135),
        _I('Samsung', 'Galaxy Tab A9 64GB', 49, 75),
        _I('Apple', 'iPad 10th Gen 64GB', 125, 160),
      ]),
    ]),
    _Cat('Electronics', Icons.devices_outlined, [
      _Sub('Televisions', Icons.tv_outlined, [
        _I('LG', '55-inch 4K UHD Smart TV', 189, 280),
        _I('Samsung', '50-inch Crystal 4K TV', 165, 230),
        _I('Hisense', '43-inch Full HD TV', 99, 150),
      ]),
      _Sub('Speakers', Icons.speaker_outlined, [
        _I('JBL', 'Flip 6 Bluetooth Speaker', 38, 55),
        _I('Sony', 'SRS-XB100 Speaker', 24, 35),
        _I('Anker', 'Soundcore 3 Speaker', 22, 34),
      ]),
      _Sub('Cameras', Icons.photo_camera_outlined, [
        _I('Canon', 'EOS R50 Camera', 310, 400),
        _I('GoPro', 'HERO 12 Black', 150, 210),
        _I('Fujifilm', 'Instax Mini 12 Camera', 44, 60),
      ]),
    ]),
    _Cat('Gaming\nessentials', Icons.sports_esports_outlined, [
      _Sub('Consoles', Icons.videogame_asset_outlined, [
        _I('Sony', 'PlayStation 5 Slim', 165, 210),
        _I('Microsoft', 'Xbox Series S', 112, 145),
        _I('Nintendo', 'Switch OLED', 118, 150),
      ]),
      _Sub('Controllers', Icons.gamepad_outlined, [
        _I('Sony', 'DualSense Wireless Controller', 29, 38),
        _I('Microsoft', 'Xbox Wireless Controller', 27, 36),
        _I('Razer', 'Wolverine V2 Controller', 45, 65),
      ]),
      _Sub('Headsets', Icons.headset_mic_outlined, [
        _I('HyperX', 'Cloud II Gaming Headset', 32, 48),
        _I('Razer', 'BlackShark V2 X Headset', 28, 42),
        _I('Logitech', 'G335 Gaming Headset', 24, 36),
      ]),
    ]),
    _Cat('Beauty', Icons.face_retouching_natural_outlined, [
      _Sub('Skin care', Icons.spa_outlined, [
        _I('CeraVe', 'Hydrating Cleanser 236ml', 6, 10),
        _I('Nivea', 'Soft Moisturising Cream 200ml', 3, 5),
        _I('Garnier', 'Vitamin C Serum 30ml', 5, 9),
      ]),
      _Sub('Makeup', Icons.brush_outlined, [
        _I('Maybelline', 'Fit Me Foundation', 5, 9),
        _I('Revlon', 'Super Lustrous Lipstick', 4, 8),
        _I('Maybelline', 'Lash Sensational Mascara', 5, 9),
      ]),
      _Sub('Fragrance', Icons.auto_awesome_outlined, [
        _I('Versace', 'Eros EDT 100ml', 38, 55),
        _I('Armani', 'Code EDP 75ml', 45, 62),
        _I('Lacoste', 'Blanc EDT 100ml', 28, 40),
      ]),
    ]),
    _Cat('Small\nAppliances', Icons.kitchen_outlined, [
      _Sub('Air fryers', Icons.microwave_outlined, [
        _I('Philips', 'Air Fryer 4.1L', 49, 75),
        _I('Ninja', 'Air Fryer 3.8L', 55, 80),
        _I('Tefal', 'Easy Fry 4.2L', 52, 78),
      ]),
      _Sub('Kettles & blenders', Icons.emoji_food_beverage_outlined, [
        _I('Braun', 'Electric Kettle 1.7L', 19, 30),
        _I('Philips', 'Hand Blender 650W', 22, 35),
        _I('Kenwood', 'Stand Mixer 1000W', 95, 140),
      ]),
      _Sub('Coffee makers', Icons.coffee_outlined, [
        _I('Nespresso', 'Vertuo Pop Machine', 55, 80),
        _I('DeLonghi', 'Drip Coffee Maker', 28, 42),
        _I('Tefal', 'Espresso Maker', 38, 55),
      ]),
    ]),
    _Cat('Toys & Games', Icons.toys_outlined, [
      _Sub('Building sets', Icons.extension_outlined, [
        _I('LEGO', 'Classic Brick Box 790pcs', 22, 32),
        _I('LEGO', 'City Police Station', 49, 70),
        _I('Mega', 'Bloks Big Building Bag', 12, 18),
      ]),
      _Sub('Remote control', Icons.directions_car_outlined, [
        _I('HotWheels', 'RC Monster Truck', 14, 22),
        _I('WLtoys', 'Remote Control Car 1:18', 18, 28),
        _I('Syma', 'RC Helicopter', 16, 25),
      ]),
      _Sub('Board games', Icons.casino_outlined, [
        _I('Hasbro', 'Monopoly Classic', 9, 14),
        _I('Mattel', 'UNO Card Game', 2, 4),
        _I('Ravensburger', 'Puzzle 1000pcs', 7, 11),
      ]),
    ]),
    _Cat('Baby Care', Icons.child_care_outlined, [
      _Sub('Diapers', Icons.baby_changing_station_outlined, [
        _I('Pampers', 'Pants Size 5 84pcs', 14, 20),
        _I('Huggies', 'Newborn Diapers 64pcs', 10, 15),
        _I('Molfix', 'Baby Diapers Size 4 70pcs', 8, 12),
      ]),
      _Sub('Baby skin care', Icons.spa_outlined, [
        _I('Mustela', 'Hydra Bebe Lotion 300ml', 9, 14),
        _I('Johnson', 'Baby Shampoo 500ml', 4, 6),
        _I('Sudocrem', 'Nappy Rash Cream 125g', 4, 6),
      ]),
      _Sub('Feeding', Icons.local_drink_outlined, [
        _I('Philips', 'Avent Feeding Bottle 260ml', 7, 10),
        _I('Tommee', 'Tippee Bottle Set', 12, 18),
        _I('Nuk', 'Baby Food Spoon Set', 5, 8),
      ]),
    ]),
    _Cat('Baby gear', Icons.child_friendly_outlined, [
      _Sub('Strollers', Icons.child_friendly_outlined, [
        _I('Graco', 'Modes Pramette Stroller', 85, 120),
        _I('Chicco', 'Liteway Stroller', 95, 135),
        _I('Joie', 'Pact Lite Stroller', 70, 100),
      ]),
      _Sub('Car seats', Icons.airline_seat_recline_normal_outlined, [
        _I('Graco', 'Junior Maxi Car Seat', 60, 90),
        _I('Chicco', 'Gro-Up Car Seat', 110, 150),
        _I('Joie', 'Every Stage Car Seat', 95, 130),
      ]),
      _Sub('Cribs & cots', Icons.bed_outlined, [
        _I('Chicco', 'Next2Me Bedside Crib', 120, 170),
        _I('Fisher-Price', 'Baby Playard', 55, 80),
        _I('Joie', 'Portable Baby Cot', 48, 70),
      ]),
    ]),
    _Cat('Home &\nKitchen', Icons.home_outlined, [
      _Sub('Cookware', Icons.soup_kitchen_outlined, [
        _I('Tefal', 'Non-Stick Cookware Set 7pcs', 38, 60),
        _I('Prestige', 'Pressure Cooker 5L', 22, 34),
        _I('Tramontina', 'Frying Pan 28cm', 9, 14),
      ]),
      _Sub('Storage', Icons.inventory_2_outlined, [
        _I('Lock&Lock', 'Food Container Set 5pcs', 12, 18),
        _I('Tupperware', 'Lunch Box Set', 10, 16),
        _I('Rubbermaid', 'Storage Bin 20L', 8, 12),
      ]),
      _Sub('Bedding', Icons.bed_outlined, [
        _I('Hometex', 'Cotton Bedsheet Set Queen', 14, 22),
        _I('Dream', 'Memory Foam Pillow 2 Pack', 12, 20),
        _I('Fluffy', 'Comforter Queen', 24, 38),
      ]),
    ]),
  ];

  // ── Data helpers ───────────────────────────────────────────────────────────
  Product _toProduct(String id, String category, _I it) => Product(
    id: id, // unique per product so cart lines never collide
    name: '${it.brand} ${it.model}',
    price: it.price,
    originalPrice: it.original,
    image: '',
    imageUrl: '',
    category: category,
    weight: '',
    sku: id.toUpperCase(),
    discountPercentage: 0,
    quantity: 20,
    posQuantity: 20,
  );

  List<Product> _productsOf(int c, int s) {
    final sub = _cats[c].subs[s];
    return [
      for (var i = 0; i < sub.items.length; i++)
        _toProduct('cat_${c}_${s}_$i', sub.name, sub.items[i]),
    ];
  }

  List<Product> _allProductsOf(int c) => [
    for (var s = 0; s < _cats[c].subs.length; s++) ..._productsOf(c, s),
  ];

  List<Product> _allProducts() => [
    for (var c = 0; c < _cats.length; c++) ..._allProductsOf(c),
  ];

  String _clean(String s) => s.replaceAll('\n', ' ');

  void _openList(String title, List<Product> products) {
    setState(() {
      _listTitle = title;
      _listProducts = products;
    });
  }

  void _closeList() => setState(() => _listTitle = null);

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(products: _allProducts()),
      ),
    );
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
              : _buildCategories(),
        ),
      ),
    );
  }

  // ── Screen 1 + 2: category grid with expandable sub-categories ─────────────
  Widget _buildCategories() {
    final rowCount = (_cats.length + 2) ~/ 3;

    return ListView(
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
              child: _art(cat.image, cat.icon, 44, BoxFit.cover),
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
          for (var s = 0; s < cat.subs.length; s++)
            _subRow(
              cat.subs[s].name,
              cat.subs[s].icon,
              cat.subs[s].image,
                  () => _openList(cat.subs[s].name, _productsOf(catIndex, s)),
            ),
          _subRow(
            'View all',
            Icons.menu,
            '',
                () => _openList(_clean(cat.name), _allProductsOf(catIndex)),
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