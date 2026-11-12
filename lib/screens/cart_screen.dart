import 'package:flutter/material.dart';
import 'package:mtl_jewellery/providers/cart_provider.dart';

import 'address_screen.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onStartShopping;
  const CartScreen({super.key, this.onStartShopping});

  static const _pink = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.instance;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final items = cart.items;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(cart.totalCount),
          body: items.isEmpty
              ? _buildEmptyCart(context)
              : _buildCartList(cart, items),
          bottomNavigationBar:
          items.isEmpty ? null : _buildTotalBar(cart, context),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(int count) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: const Text('My Cart',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(CartProvider cart, List<CartItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 24, color: Colors.grey.shade200),
      itemBuilder: (context, i) => _cartRow(cart, items[i]),
    );
  }

  Widget _cartRow(CartProvider cart, CartItem item) {
    final p = item.product;
    final hasDiscount = p.originalPrice > p.price && p.price > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 80,
            height: 80,
            color: const Color(0xFFF3F3F3),
            child: _thumb(p),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('KWD ${p.price.toInt()}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                  if (hasDiscount) ...[
                    const SizedBox(width: 6),
                    Text('${p.originalPrice.toInt()}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stepper(cart, item),
                  Text('KWD ${item.lineTotal.toInt()}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepper(CartProvider cart, CartItem item) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
          color: const Color(0xFF2962FF),
          borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () => cart.decrease(item.id),
          child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                  item.qty == 1 ? Icons.delete_outline : Icons.remove,
                  color: Colors.white,
                  size: item.qty == 1 ? 17 : 15)),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 22),
          alignment: Alignment.center,
          child: Text('${item.qty}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        GestureDetector(
          onTap: () => cart.add(item.product),
          child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.add, color: Colors.white, size: 15)),
        ),
      ]),
    );
  }

  Widget _thumb(dynamic p) {
    final String imageUrl = p.imageUrl as String;
    final String image = p.image as String;
    final String url = imageUrl.startsWith('http')
        ? imageUrl
        : (image.startsWith('http') ? image : '');

    if (url.isEmpty) {
      return const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 28));
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 28)),
    );
  }

  Widget _buildTotalBar(CartProvider cart, BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total',
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('KWD ${cart.totalPrice.toInt()}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  // Snapshot of the cart, so the success page still shows the
                  // products after the cart is cleared.
                  final orderItems = cart.items.map((i) {
                    final p = i.product;
                    final imageUrl = p.imageUrl ?? '';
                    final image = p.image ?? '';
                    final img = imageUrl.startsWith('http')
                        ? imageUrl
                        : (image.startsWith('http') ? image : '');
                    return <String, dynamic>{
                      'name': p.name,
                      'image': img,
                      'qty': i.qty,
                      'price': p.price,
                    };
                  }).toList();
                  final orderTotal = cart.totalPrice;

                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => AddressScreen(
                        items: orderItems,
                        total: orderTotal,
                        onPlaceOrder: (address, method) async {
                          // Save the order to your backend here if needed.
                          cart.clear();
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Checkout',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _pink, width: 2.5),
            ),
            child: const Center(
              child: Icon(Icons.shopping_cart_outlined,
                  size: 80, color: _pink),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Nothing here yet!',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: _pink)),
          const SizedBox(height: 10),
          Text('Your cart is waiting to be filled',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 36),
          SizedBox(
            width: 260,
            height: 52,
            child: ElevatedButton(
              onPressed: onStartShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Start Shopping',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}