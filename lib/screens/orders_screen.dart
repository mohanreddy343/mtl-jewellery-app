import 'package:flutter/material.dart';
import 'package:mtl_jewellery/screens/track_order_screen.dart';

import '../services/orders_api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color _accent = Color(0xFFFFA000);
  static const Color _titleColor = Color(0xFF2B3138);
  static const Color _subtitleColor = Color(0xFF757575);

  List<OrderModel> _orders = [];
  bool _loading = true;
  bool _guest = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await OrdersApi.getMyOrders();
      if (!mounted) return;
      setState(() {
        _guest = list == null;
        _orders = list ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // createdAt comes from SQLite in UTC
  String _fmtDate(String s) {
    final d = DateTime.tryParse('${s.replaceFirst(' ', 'T')}Z')?.toLocal();
    if (d == null) return s;
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
      'Oct', 'Nov', 'Dec'];
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} ${d.year}, $h12:$min $ampm';
  }

  String _money(double v) =>
      'KWD ${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Your Orders',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
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
    if (_guest) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Please log in to see your orders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: _subtitleColor)),
        ),
      );
    }
    if (_orders.isEmpty) {
      return const Center(
        child: Text('No orders yet.',
            style: TextStyle(fontSize: 16, color: _subtitleColor)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _orderCard(_orders[i]),
      ),
    );
  }

  Widget _orderCard(OrderModel o) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${o.id}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _titleColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(o.status,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _accent)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_fmtDate(o.createdAt),
                    style: const TextStyle(
                        fontSize: 13, color: _subtitleColor)),
                const SizedBox(height: 2),
                Text('Payment: ${o.paymentMethod}',
                    style: const TextStyle(
                        fontSize: 13, color: _subtitleColor)),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          for (final it in o.items) _itemRow(o, it),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Total: ${_money(o.total)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _titleColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(OrderModel o, OrderItem it) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: it.imageUrl.isEmpty
                      ? _imgPlaceholder()
                      : Image.network(it.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _titleColor)),
                    const SizedBox(height: 4),
                    Text('${_money(it.price)}  x ${it.qty}',
                        style: const TextStyle(
                            fontSize: 13, color: _subtitleColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDetails(o, it),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _accent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Product details',
                      style: TextStyle(
                          color: _accent, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TrackOrderScreen(order: o)),
                    );
                    _load(); // refresh the list after a cancel or return
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Track order',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: Colors.grey.shade200,
    child: Icon(Icons.image_not_supported_outlined,
        color: Colors.grey.shade500),
  );

  void _showDetails(OrderModel o, OrderItem it) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: it.imageUrl.isEmpty
                      ? _imgPlaceholder()
                      : Image.network(it.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(it.name,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _line('Price', _money(it.price)),
            _line('Quantity', '${it.qty}'),
            _line('Item total', _money(it.price * it.qty)),
            _line('Payment', o.paymentMethod),
            _line('Ordered on', _fmtDate(o.createdAt)),
            _line('Order', '#${o.id}'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _line(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k,
            style:
            const TextStyle(fontSize: 14, color: _subtitleColor)),
        Flexible(
          child: Text(v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );

  void _showTrack(OrderModel o) {
    const steps = [
      'Placed',
      'Confirmed',
      'Shipped',
      'Out for delivery',
      'Delivered',
    ];
    final current =
    steps.indexWhere((s) => s.toLowerCase() == o.status.toLowerCase());
    final done = current < 0 ? 0 : current;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track order #${o.id}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      i <= done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: i <= done ? _accent : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Text(steps[i],
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            i == done ? FontWeight.w700 : FontWeight.w500,
                            color: i <= done
                                ? _titleColor
                                : Colors.grey.shade500)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}