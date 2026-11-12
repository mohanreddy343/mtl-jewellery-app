import 'package:flutter/material.dart';
import 'package:mtl_jewellery/providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final double imageHeight;
  final double cardRightMargin;

  const ProductCard({
    super.key,
    required this.product,
    this.imageHeight = 0,
    this.cardRightMargin = 0,
  });

  @override
  Widget build(BuildContext context) => _buildFull(context);

  // ── Full card ──────────────────────────────────────────────────────────────
  Widget _buildFull(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: cardRightMargin),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Image area ─────────────────────────────────────────
          LayoutBuilder(builder: (_, constraints) {
            final imgH =
            imageHeight > 0 ? imageHeight : constraints.maxWidth * 1.1;
            return Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: imgH,
                  width: double.infinity,
                  color: const Color(0xFFF3F3F3),
                  child: _safeImage(
                      image: product.image,
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain),
                ),
              ),

              // Best Seller tag
              if (product.computedDiscount >= 40)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B5D4B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Text('Best Seller',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ),

              // Heart
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border,
                      size: 15, color: Colors.black87),
                ),
              ),

              // Out of stock overlay
              if (!product.isInStock)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('Out of Stock',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),

              // + button / stepper (bottom-right of image)
              if (product.isInStock)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: _CartOverlay(product: product),
                ),
            ]);
          }),

          const SizedBox(height: 8),

          // ── Title ──────────────────────────────────────────────
          Text(product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.3)),

          const SizedBox(height: 6),

          // ── Rating chip ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFFF3F5F8),
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star, size: 12, color: Color(0xFF0B7A2B)),
                SizedBox(width: 3),
                Text('4.7',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                SizedBox(width: 3),
                Text('(51.1K)',
                    style: TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Price row (shrinks to fit, no overflow) ────────────
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('KWD ${product.price.toInt()}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black)),
                if (product.originalPrice > product.price &&
                    product.price > 0) ...[
                  const SizedBox(width: 4),
                  Text('${product.originalPrice.toInt()}',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough)),
                ],
                if (product.computedDiscount > 0) ...[
                  const SizedBox(width: 4),
                  Text('${product.computedDiscount}%',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00A650))),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Express badge ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: const Color(0xFFFFEB00),
                borderRadius: BorderRadius.circular(3)),
            child: const Text('express',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87)),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Image helper ───────────────────────────────────────────────────────────
  Widget _safeImage({
    required String image,
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
  }) {
    bool isValid(String s) =>
        s.isNotEmpty &&
            s != 'no_image.png' &&
            !s.startsWith('catalog/s-') &&
            (s.startsWith('http') || s.startsWith('catalog/products/'));

    String url = '';
    if (isValid(imageUrl)) {
      url = imageUrl;
    } else if (isValid(image)) {
      url = image;
    }

    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        loadingBuilder: (_, child, prog) =>
        prog == null ? child : Container(color: Colors.grey[100]),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: Colors.grey[100],
    child: const Center(
        child:
        Icon(Icons.image_not_supported, color: Colors.grey, size: 32)),
  );
}

// ── "+" button / stepper (reads and writes the shared cart) ──────────────────
class _CartOverlay extends StatelessWidget {
  final dynamic product;
  const _CartOverlay({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.instance;
    final id = product.id.toString();

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final qty = cart.qtyOf(id);

        // Not in cart: white "+" button
        if (qty == 0) {
          return GestureDetector(
            onTap: () => cart.add(product),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 20),
            ),
          );
        }

        // In cart: blue stepper (delete icon when qty == 1, minus otherwise)
        return Container(
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF2962FF),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1))
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () => cart.decrease(id),
              child: Container(
                  width: 32,
                  height: 34,
                  alignment: Alignment.center,
                  child: Icon(
                      qty == 1 ? Icons.delete_outline : Icons.remove,
                      color: Colors.white,
                      size: qty == 1 ? 17 : 15)),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              alignment: Alignment.center,
              child: Text('$qty',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () => cart.add(product),
              child: Container(
                  width: 32,
                  height: 34,
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: Colors.white, size: 15)),
            ),
          ]),
        );
      },
    );
  }
}