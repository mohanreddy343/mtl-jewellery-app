import 'package:flutter/material.dart';

/// Payment screen. Only Cash on Delivery is available.
/// After "Place Order" it shows a full-screen order success page with the
/// address, product details and total. "Continue Shopping" goes to home.
class PaymentScreen extends StatefulWidget {
  final Map<String, String> address;
  final List<Map<String, dynamic>> items; // keys: name, image, qty, price
  final double total;
  final Future<void> Function(String method)? onPlaceOrder;

  const PaymentScreen({
    super.key,
    required this.address,
    required this.items,
    required this.total,
    this.onPlaceOrder,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _pink = Color(0xFFFF9800);
  static const _cod = 'Cash on Delivery';

  String _selected = _cod;
  bool _orderPlaced = false;
  bool _placing = false;

  String get _addressLine {
    final a = widget.address;
    final parts = <String>[
      a['area'] ?? '',
      if ((a['block'] ?? '').isNotEmpty) 'Block ${a['block']}',
      if ((a['street'] ?? '').isNotEmpty) 'Street ${a['street']}',
      if ((a['avenue'] ?? '').isNotEmpty) 'Avenue ${a['avenue']}',
      if ((a['building'] ?? '').isNotEmpty) 'Building ${a['building']}',
      if ((a['floor'] ?? '').isNotEmpty) 'Floor ${a['floor']}',
      if ((a['flat'] ?? '').isNotEmpty) 'Flat ${a['flat']}',
      a['governorate'] ?? '',
    ].where((e) => e.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    try {
      await widget.onPlaceOrder?.call(_selected);
      if (!mounted) return;
      setState(() => _orderPlaced = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not place order. Try again.')),
      );
    }
  }

  void _goHome() {
    // Goes back to the first route (home). If home is a named route, use:
    // Navigator.of(context, rootNavigator: true)
    //     .pushNamedAndRemoveUntil('/home', (r) => false);
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/home', (route) => false);
  }

  String _price(num v) => 'KWD ${v.toInt()}';

  // ── Order success (full screen) ────────────────────────────────────────────
  Widget _buildSuccess(BuildContext context) {
    final a = widget.address;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 16),
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text('Order placed successfully!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text('Payment: $_selected',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ),
                    const SizedBox(height: 24),

                    // Delivery address
                    const Text('Delivery address',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 20, color: _pink),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${a['label'] ?? ''} • ${a['name'] ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(a['phone'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700)),
                                const SizedBox(height: 4),
                                Text(_addressLine,
                                    style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: Colors.grey.shade800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Order summary
                    const SizedBox(height: 20),
                    const Text('Order summary',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    if (widget.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No product details received'),
                      ),
                    ...widget.items.map((item) {
                      final qty = (item['qty'] ?? 1) as num;
                      final price = (item['price'] ?? 0) as num;
                      final image = (item['image'] ?? '').toString();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: image.isEmpty
                                    ? Container(color: Colors.grey.shade200)
                                    : Image.network(image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                            color: Colors.grey.shade200)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item['name'] ?? ''}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('Qty: $qty',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Text(_price(price * qty),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        Text(_price(widget.total),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),

              // Continue shopping
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('Continue Shopping',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Order summary (used on the payment form) ──────────────────────────────
  Widget _orderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order summary',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 8),
        if (widget.items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No product details received'),
          ),
        ...widget.items.map((item) {
          final qty = num.tryParse('${item['qty'] ?? 1}') ?? 1;
          final price = num.tryParse('${item['price'] ?? 0}') ?? 0;
          final image = (item['image'] ?? '').toString();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: image.isEmpty
                        ? Container(color: Colors.grey.shade200)
                        : Image.network(image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade200)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['name'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Qty: $qty',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(_price(price * qty),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text(_price(widget.total),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.green)),
          ],
        ),
      ],
    );
  }

  // ── Payment form ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_orderPlaced) return _buildSuccess(context);
    final a = widget.address;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Payment',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // Address summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: _pink),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${a['label'] ?? ''} • ${a['name'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(a['phone'] ?? '',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Text(_addressLine,
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: Colors.grey.shade800)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 30)),
                  child: const Text('Change',
                      style: TextStyle(
                          color: _pink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _orderSummary(),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Payment method',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87)),
          ),

          // Cash on delivery option
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _selected = _cod),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _selected == _cod ? _pink : Colors.grey.shade300,
                    width: _selected == _cod ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payments_outlined,
                        color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(_cod,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Pay in cash when your order arrives',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(
                    _selected == _cod
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _selected == _cod ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, -2)),
            ],
          ),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placing ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: _placing
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('Place Order',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}