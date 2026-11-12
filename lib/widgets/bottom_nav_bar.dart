import 'package:flutter/material.dart';

import 'package:mtl_jewellery/providers/cart_provider.dart';
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFE91E8C),
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: _CartIcon(active: false),
            activeIcon: _CartIcon(active: true),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final bool active;
  const _CartIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartProvider.instance,
      builder: (_, __) {
        final count = CartProvider.instance.totalCount;
        final icon =
        Icon(active ? Icons.shopping_cart : Icons.shopping_cart_outlined);
        if (count == 0) return icon;
        return Badge(
          backgroundColor: const Color(0xFFFF0080),
          label: Text('$count'),
          child: icon,
        );
      },
    );
  }
}