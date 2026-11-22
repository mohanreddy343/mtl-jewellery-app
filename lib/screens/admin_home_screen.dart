import 'package:flutter/material.dart';

import 'admin_banners_home_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_delivery_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_requests_screen.dart';

/// Admin menu. Only reachable from Profile when the server says role = admin.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const Color _accent = Color(0xFFFFA000);

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
        title: const Text('Admin access',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _item(
            icon: Icons.local_shipping_outlined,
            title: 'Orders & tracking',
            subtitle: 'See all orders and update their status',
            onTap: () => _open(context, const AdminOrdersScreen()),
          ),
          _item(
            icon: Icons.category_outlined,
            title: 'Categories',
            subtitle: 'Add, rename and delete categories',
            onTap: () => _open(context, const AdminCategoriesScreen()),
          ),
          _item(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            subtitle: 'Add, edit prices and stock, delete products',
            onTap: () => _open(context, const AdminProductsScreen()),
          ),
          _item(
            icon: Icons.delivery_dining_outlined,
            title: 'Delivery charges',
            subtitle: 'Set charges per governorate and free delivery',
            onTap: () => _open(context, const AdminDeliveryScreen()),
          ),
          _item(
            icon: Icons.view_carousel_outlined,
            title: 'Banners',
            subtitle: 'Add home banners with an optional link',
            onTap: () => _open(context, const AdminBannersScreen()),
          ),
          _item(
            icon: Icons.cancel_outlined,
            title: 'Cancel orders',
            subtitle: 'Approve or reject customer cancel requests',
            onTap: () =>
                _open(context, const AdminRequestsScreen(isCancel: true)),
          ),
          _item(
            icon: Icons.assignment_return_outlined,
            title: 'Return orders',
            subtitle: 'Approve or reject customer return requests',
            onTap: () =>
                _open(context, const AdminRequestsScreen(isCancel: false)),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: _accent, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}