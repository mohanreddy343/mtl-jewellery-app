import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';

/// Admin: all orders, with buttons to change the tracking status.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const Color _accent = Color(0xFFFFA000);

  List<AdminOrder> _orders = [];
  bool _loading = true;
  String? _error;
  int? _savingId;

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
      final list = await AdminApi.getOrders();
      if (!mounted) return;
      setState(() {
        _orders = list;
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

  Future<void> _setStatus(AdminOrder o, String status) async {
    if (o.status == status || _savingId != null) return;
    setState(() => _savingId = o.id);
    try {
      await AdminApi.setOrderStatus(o.id, status);
      if (!mounted) return;
      setState(() {
        o.status = status;
        _savingId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingId = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
        title: const Text('Manage Orders',
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
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders yet.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _card(_orders[i]),
      ),
    );
  }

  Widget _card(AdminOrder o) {
    final saving = _savingId == o.id;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${o.id}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text('KWD ${o.total == o.total.roundToDouble() ? o.total.toInt() : o.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${o.createdAt} UTC  •  ${o.paymentMethod}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('${o.customerName}  ${o.phone}',
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (o.addressText.isNotEmpty)
            Text(o.addressText,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text(o.items.join(', '), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: AdminApi.statuses.map((s) {
              final selected = o.status == s;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                showCheckmark: false,
                selectedColor: _accent,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87),
                onSelected: saving ? null : (_) => _setStatus(o, s),
              );
            }).toList(),
          ),
          if (saving)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(color: _accent),
            ),
        ],
      ),
    );
  }
}