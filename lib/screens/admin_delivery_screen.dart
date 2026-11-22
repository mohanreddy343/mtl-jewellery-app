import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';

/// Admin: delivery charge per governorate and an optional free-delivery limit.
class AdminDeliveryScreen extends StatefulWidget {
  const AdminDeliveryScreen({super.key});

  @override
  State<AdminDeliveryScreen> createState() => _AdminDeliveryScreenState();
}

class _AdminDeliveryScreenState extends State<AdminDeliveryScreen> {
  static const Color _accent = Color(0xFFFFA000);

  final Map<String, TextEditingController> _chargeCtrls = {};
  final TextEditingController _freeAbove = TextEditingController();
  List<String> _governorates = [];

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _chargeCtrls.values) {
      c.dispose();
    }
    _freeAbove.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cfg = await AdminApi.getDelivery();
      if (!mounted) return;
      for (final c in _chargeCtrls.values) {
        c.dispose();
      }
      _chargeCtrls.clear();
      for (final c in cfg.charges) {
        _chargeCtrls[c.governorate] =
            TextEditingController(text: kwd(c.charge));
      }
      _governorates = cfg.charges.map((c) => c.governorate).toList();
      _freeAbove.text = cfg.freeAbove == 0 ? '' : kwd(cfg.freeAbove);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final charges = <DeliveryCharge>[];
    for (final g in _governorates) {
      final text = _chargeCtrls[g]!.text.trim();
      final value = text.isEmpty ? 0.0 : double.tryParse(text);
      if (value == null || value < 0) {
        _toast('Enter a valid charge for $g');
        return;
      }
      charges.add(DeliveryCharge(g, value));
    }
    final freeText = _freeAbove.text.trim();
    final free = freeText.isEmpty ? 0.0 : double.tryParse(freeText);
    if (free == null || free < 0) {
      _toast('Enter a valid free-delivery amount');
      return;
    }

    setState(() => _saving = true);
    try {
      await AdminApi.saveDelivery(
          DeliveryConfig(charges: charges, freeAbove: free));
      if (!mounted) return;
      setState(() => _saving = false);
      _toast('Delivery charges saved');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast(e.toString());
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        title: const Text('Delivery charges',
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Charge per governorate (KWD)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final g in _governorates)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _chargeCtrls[g],
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: g,
                prefixText: 'KWD ',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text('Free delivery',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
          controller: _freeAbove,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Free delivery above (KWD)',
            helperText: 'Leave empty to turn free delivery off',
            prefixText: 'KWD ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
            ),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Text('Save'),
          ),
        ),
      ],
    );
  }
}