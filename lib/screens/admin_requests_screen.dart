import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';

/// Admin: pending cancel or return requests. Approve (Yes) or reject (No).
class AdminRequestsScreen extends StatefulWidget {
  final bool isCancel; // true = cancel orders, false = return orders
  const AdminRequestsScreen({super.key, required this.isCancel});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  static const Color _accent = Color(0xFFFFA000);

  List<AdminRequest> _items = [];
  bool _loading = true;
  String? _error;
  int? _busyId;

  String get _type => widget.isCancel ? 'cancel' : 'return';
  String get _title => widget.isCancel ? 'Cancel orders' : 'Return orders';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final list = await AdminApi.getRequests(_type);
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        _snack(e.toString());
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  String _money(double v) =>
      'KWD ${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(2)}';

  Future<void> _decide(AdminRequest r, bool approve) async {
    final what = widget.isCancel ? 'cancellation' : 'return';
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Approve $what' : 'Reject $what'),
        content: Text(approve
            ? 'Approve the $what for order #${r.id}? The customer will be told it is approved.'
            : 'Reject the $what for order #${r.id}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (yes != true) return;

    setState(() => _busyId = r.id);
    try {
      await AdminApi.decideRequest(r.id, approve);
      if (!mounted) return;
      _snack(approve ? 'Approved' : 'Rejected');
      await _load(silent: true);
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busyId = null);
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
        title: Text(_title,
            style: const TextStyle(
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
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: _items.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No pending requests.')),
        ],
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (_, i) => _card(_items[i]),
      ),
    );
  }

  Widget _card(AdminRequest r) {
    final busy = _busyId == r.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Text('Order #${r.id}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Text(_money(r.total),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${r.createdAt} UTC',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Divider(height: 20),
          for (final it in r.items) _itemRow(it),
          const Divider(height: 20),
          if (r.customerName.isNotEmpty)
            Text(r.customerName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          if (r.phone.isNotEmpty) Text(r.phone),
          if (r.addressText.isNotEmpty)
            Text('${r.addressText}, Kuwait',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Payment: ${r.paymentMethod}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _decide(r, false),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                  child:
                  const Text('No', style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : () => _decide(r, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white),
                  child: busy
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Yes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemRow(RequestItem it) {
    final details = <String>[
      if (it.sku.isNotEmpty) 'SKU ${it.sku}',
      if (it.weight.isNotEmpty) it.weight,
    ].join('  •  ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: it.imageUrl.isEmpty
                  ? _placeholder()
                  : Image.network(it.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder()),
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
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (details.isNotEmpty)
                  Text(details,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                Text('${_money(it.price)}  x ${it.qty}',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade700)),
              ],
            ),
          ),
          Text(_money(it.price * it.qty),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: Icon(Icons.image_not_supported_outlined,
        color: Colors.grey.shade500),
  );
}