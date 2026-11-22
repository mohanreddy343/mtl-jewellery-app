import 'package:flutter/material.dart';

import '../services/orders_api_service.dart';

class TrackOrderScreen extends StatefulWidget {
  final OrderModel order;
  const TrackOrderScreen({super.key, required this.order});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  static const Color _accent = Color(0xFFFFA000);
  static const Color _titleColor = Color(0xFF2B3138);
  static const Color _subtitleColor = Color(0xFF757575);

  static const steps = [
    'Placed',
    'Confirmed',
    'Shipped',
    'Out for delivery',
    'Delivered',
  ];

  late OrderModel _o;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _o = widget.order;
  }

  bool get _cancelled => _o.status == 'Cancelled';
  bool get _returnRequested => _o.status == 'Return requested';
  bool get _returnApproved => _o.status == 'Return approved';
  bool get _cancelRequested => _o.status == 'Cancel requested';
  bool get _canCancel =>
      _o.status == 'Shipped' || _o.status == 'Out for delivery';
  bool get _canReturn => _o.status == 'Delivered';

  int get _stepIndex {
    if (_returnRequested || _returnApproved) return steps.length - 1;
    final i = steps.indexOf(_o.status);
    return i < 0 ? 0 : i;
  }

  String _money(double v) =>
      'KWD ${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(2)}';

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

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _refresh() async {
    try {
      final list = await OrdersApi.getMyOrders();
      if (list == null || !mounted) return;
      final match = list.where((e) => e.id == _o.id);
      if (match.isNotEmpty) setState(() => _o = match.first);
    } catch (e) {
      if (mounted) _snack(e.toString());
    }
  }

  Future<void> _run(String title, String message, String confirmLabel,
      Future<void> Function() action, String doneMessage) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel)),
        ],
      ),
    );
    if (yes != true) return;

    setState(() => _busy = true);
    try {
      await action();
      await _refresh();
      if (mounted) _snack(doneMessage);
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
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
        title: Text('Order #${_o.id}',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _section('Tracking', _tracking()),
            const SizedBox(height: 14),
            _section('Products', _products()),
            const SizedBox(height: 14),
            _section('Delivery address', _address()),
            const SizedBox(height: 14),
            _section('Order details', _details()),
            const SizedBox(height: 18),
            _actions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _titleColor)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _tracking() {
    if (_cancelRequested) {
      return Row(
        children: [
          const Icon(Icons.hourglass_top, color: _accent),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Cancel request sent. Waiting for approval.',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _titleColor)),
          ),
        ],
      );
    }
    if (_cancelled) {
      return Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Cancel order approved. This order is cancelled.',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red)),
          ),
        ],
      );
    }

    final labels = [
      ...steps,
      if (_returnRequested || _returnApproved) 'Return requested',
      if (_returnApproved) 'Return approved',
    ];
    final current =
    (_returnRequested || _returnApproved) ? labels.length - 1 : _stepIndex;

    return Column(
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    i <= current
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: i <= current ? _accent : Colors.grey.shade400,
                  ),
                  if (i < labels.length - 1)
                    Container(
                      width: 2,
                      height: 30,
                      color: i < current ? _accent : Colors.grey.shade300,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(labels[i],
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: i == current
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: i <= current
                                ? _titleColor
                                : Colors.grey.shade500)),
                    if (i == 0)
                      Text(_fmtDate(_o.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: _subtitleColor)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _products() {
    return Column(
      children: [
        for (final it in _o.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 64,
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
                Text(_money(it.price * it.qty),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: Icon(Icons.image_not_supported_outlined,
        color: Colors.grey.shade500),
  );

  Widget _address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_o.customerName.isNotEmpty)
          Text(_o.customerName,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        if (_o.addressText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('${_o.addressText}, Kuwait',
                style:
                const TextStyle(fontSize: 13, color: _subtitleColor)),
          ),
        if (_o.phone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('+965 ${_o.phone}',
                style: const TextStyle(fontSize: 13)),
          ),
      ],
    );
  }

  Widget _line(String k, String v, {bool bold = false}) => Padding(
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
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
        ),
      ],
    ),
  );

  Widget _details() {
    return Column(
      children: [
        _line('Status', _o.status),
        _line('Ordered on', _fmtDate(_o.createdAt)),
        _line('Payment', _o.paymentMethod),
        _line('Total', _money(_o.total), bold: true),
      ],
    );
  }

  Widget _actions() {
    if (_canCancel) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: _busy
              ? null
              : () => _run(
            'Cancel order',
            'Send a cancel request for this order? It needs admin approval.',
            'Yes, cancel',
                () => OrdersApi.cancelOrder(_o.id),
            'Cancel request sent',
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          child: _busy
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Cancel order',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w700)),
        ),
      );
    }
    if (_canReturn) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _busy
              ? null
              : () => _run(
            'Return order',
            'Do you want to request a return for this order?',
            'Yes, return',
                () => OrdersApi.returnOrder(_o.id),
            'Return requested',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          child: _busy
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : const Text('Return order',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}