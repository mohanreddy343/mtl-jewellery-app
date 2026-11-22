import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mtl_jewellery/screens/payment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../saved_addresses_screen.dart';
import '../services/address_api_service.dart';

/// Kuwait delivery address form.
/// Kuwait addresses are written as: Governorate > Area > Block > Street >
/// (Avenue/Jada) > Building/House > Floor > Flat. There is no street-number
/// system like other countries, and the PACI number is the official
/// address ID (optional here).
///
/// After the address is confirmed, the payment screen opens. When the user
/// taps "Place Order" there, [onPlaceOrder] is called with the address and
/// the payment method, and the order success page is shown.
class AddressScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items; // keys: name, image, qty, price
  final double total;
  final Future<void> Function(Map<String, String> address, String method)?
  onPlaceOrder;

  const AddressScreen({
    super.key,
    required this.items,
    required this.total,
    this.onPlaceOrder,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  static const _pink = Color(0xFFFF9800);

  // Governorate -> areas
  static const Map<String, List<String>> _areas = {
    'Capital (Al Asimah)': [
      'Kuwait City', 'Sharq', 'Dasman', 'Mirqab', 'Salhiya', 'Qibla',
      'Abdullah Al-Salem', 'Daiya', 'Shamiya', 'Rawda', 'Adailiya',
      'Khaldiya', 'Kaifan', 'Faiha', 'Qadsiya', 'Mansouriya', 'Nuzha',
      'Shuwaikh', 'Sulaibikhat', 'Doha', 'Yarmouk', 'Qortuba', 'Surra',
    ],
    'Hawalli': [
      'Hawalli', 'Salmiya', 'Jabriya', 'Rumaithiya', 'Salwa', 'Bayan',
      'Mishref', 'Shaab', 'Bidaa', 'Maidan Hawalli', 'Siddiq', 'Zahra',
      'Hateen', 'Salam', 'Shuhada',
    ],
    'Farwaniya': [
      'Farwaniya', 'Khaitan', 'Jleeb Al-Shuyoukh', 'Abraq Khaitan',
      'Andalus', 'Ardiya', 'Rabiya', 'Omariya', 'Rigai',
      'Sabah Al-Nasser', 'Ishbiliya', 'Dajeej', 'Firdous',
    ],
    'Ahmadi': [
      'Ahmadi', 'Fahaheel', 'Mangaf', 'Abu Halifa', 'Fintas', 'Mahboula',
      'Riqqa', 'Sabahiya', 'Hadiya', 'Egaila', 'Wafra', 'Fahad Al-Ahmad',
      'Ali Sabah Al-Salem', 'Sabah Al-Ahmad', 'Jaber Al-Ali', 'Dhaher',
    ],
    'Jahra': [
      'Jahra', 'Naseem', 'Qasr', 'Saad Al-Abdullah', 'Sulaibiya', 'Oyoun',
      'Waha', 'Taima', 'Nahda', 'Amghara',
    ],
    'Mubarak Al-Kabeer': [
      'Mubarak Al-Kabeer', 'Qurain', 'Qusour', 'Adan', 'Sabah Al-Salem',
      'Messila', 'Funaitees', 'Abu Fatira', 'Abu Al Hasaniya',
    ],
  };

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _block = TextEditingController();
  final _street = TextEditingController();
  final _avenue = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  final _flat = TextEditingController();
  final _paci = TextEditingController();
  final _notes = TextEditingController();

  String? _governorate;
  String? _area;
  String _label = 'Home';
  bool _locating = false;

  List<SavedAddress> _saved = [];
  String? _selectedSavedId;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(kSavedAddressesKey) ?? [];
    final list = <SavedAddress>[];
    for (final s in raw) {
      try {
        list.add(SavedAddress.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _saved = list);
  }

  void _applySaved(SavedAddress a) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedSavedId = a.id;
      _label = a.label;
      _name.text = a.name;
      _phone.text = a.phone;
      _governorate = _areas.containsKey(a.governorate) ? a.governorate : null;
      _area = (_governorate != null && a.area.isNotEmpty) ? a.area : null;
      _block.text = a.block;
      _street.text = a.street;
      _avenue.clear();
      _building.text = a.building;
      _floor.text = a.floor;
      _flat.text = a.flat;
      _notes.text = a.landmark;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name, _phone, _block, _street, _avenue, _building, _floor, _flat,
      _paci, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Delivery Address',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (_saved.isNotEmpty) ...[
              _sectionTitle('Saved addresses'),
              _savedAddressesList(),
              const SizedBox(height: 20),
            ],
            _infoBanner(),
            const SizedBox(height: 16),

            _sectionTitle('Contact'),
            _field('Full name', _name,
                type: TextInputType.name,
                caps: TextCapitalization.words),
            const SizedBox(height: 12),
            _phoneField(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _locating ? null : _detectLocation,
                icon: _locating
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _pink))
                    : const Icon(Icons.my_location, color: _pink, size: 20),
                label: Text(
                    _locating ? 'Detecting...' : 'Detect my location',
                    style: const TextStyle(
                        color: _pink, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _pink),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Address'),
            _pickerField(
              label: 'Governorate',
              value: _governorate,
              options: _areas.keys.toList(),
              onSelected: (v) => setState(() {
                if (_governorate != v) _area = null;
                _governorate = v;
              }),
            ),
            const SizedBox(height: 12),
            _pickerField(
              label: 'Area',
              value: _area,
              options: _governorate == null ? const [] : _areas[_governorate]!,
              enabled: _governorate != null,
              disabledHint: 'Select governorate first',
              onSelected: (v) => setState(() => _area = v),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field('Block', _block,
                      type: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _field('Street', _street),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field('Avenue (Jada)', _avenue, required: false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('Building / House', _building),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field('Floor', _floor, required: false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('Flat / Apt', _flat, required: false),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _field(
              'PACI number (optional)',
              _paci,
              required: false,
              type: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              extra: (v) => (v != null && v.isNotEmpty && v.length != 8)
                  ? 'PACI number is 8 digits'
                  : null,
            ),
            const SizedBox(height: 12),
            _field('Delivery notes (optional)', _notes,
                required: false,
                maxLines: 2,
                action: TextInputAction.done,
                hint: 'e.g. Near the mosque, call on arrival'),

            const SizedBox(height: 20),
            _sectionTitle('Save as'),
            Row(
              children: ['Home', 'Work', 'Other'].map((l) {
                final selected = _label == l;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(l),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: _pink,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600),
                    side: BorderSide(
                        color: selected ? _pink : Colors.grey.shade300),
                    onSelected: (_) => setState(() => _label = l),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Confirm Address',
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

  // ── Location ───────────────────────────────────────────────────────────────
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'\bal[-\s]'), '')
      .replaceAll(RegExp(r'[^a-z]'), '');

  Future<void> _detectLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast('Please turn on location services');
        await Geolocator.openLocationSettings();
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        _toast('Location permission denied');
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        _toast('Enable location permission from app settings');
        await Geolocator.openAppSettings();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      await setLocaleIdentifier('en_US');
      final marks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isEmpty) {
        _toast('Could not find an address for your location');
        return;
      }
      _applyPlacemark(marks.first);
    } catch (_) {
      _toast('Could not detect location. Please fill the address manually.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _applyPlacemark(Placemark p) {
    final candidates = <String>[
      p.subLocality ?? '',
      p.locality ?? '',
      p.subAdministrativeArea ?? '',
      p.name ?? '',
    ].where((e) => e.trim().isNotEmpty).toList();

    String? foundGov;
    String? foundArea;

    // 1) exact match, 2) "contains" match (longest area name wins)
    for (final c in candidates) {
      final nc = _norm(c);
      for (final e in _areas.entries) {
        for (final a in e.value) {
          if (_norm(a) == nc) {
            foundGov = e.key;
            foundArea = a;
            break;
          }
        }
        if (foundArea != null) break;
      }
      if (foundArea != null) break;
    }
    if (foundArea == null) {
      var bestLen = 0;
      for (final c in candidates) {
        final nc = _norm(c);
        for (final e in _areas.entries) {
          for (final a in e.value) {
            final na = _norm(a);
            if (na.length >= 6 && nc.contains(na) && na.length > bestLen) {
              bestLen = na.length;
              foundGov = e.key;
              foundArea = a;
            }
          }
        }
      }
    }

    // Fallback: governorate from administrativeArea only
    if (foundGov == null) {
      final g = _norm(p.administrativeArea ?? '');
      if (g.contains('hawal')) foundGov = 'Hawalli';
      else if (g.contains('ahmad')) foundGov = 'Ahmadi';
      else if (g.contains('farwan')) foundGov = 'Farwaniya';
      else if (g.contains('jahra')) foundGov = 'Jahra';
      else if (g.contains('mubarak')) foundGov = 'Mubarak Al-Kabeer';
      else if (g.contains('capital') || g.contains('asimah')) {
        foundGov = 'Capital (Al Asimah)';
      }
    }

    // Block / street / building (only if the geocoder returned them)
    final all = '${p.name} ${p.street} ${p.thoroughfare} ${p.subLocality}';
    final blockMatch =
    RegExp(r'block\s*(\d{1,2})', caseSensitive: false).firstMatch(all);
    final street = (p.thoroughfare ?? '').trim();

    setState(() {
      if (foundGov != null) {
        _governorate = foundGov;
        _area = foundArea;
      }
      if (blockMatch != null) _block.text = blockMatch.group(1)!;
      if (street.isNotEmpty && !street.contains('+')) _street.text = street;
      final b = (p.subThoroughfare ?? '').trim();
      if (b.isNotEmpty) _building.text = b;
    });

    _toast(foundArea != null
        ? 'Location detected. Please check block, street and building.'
        : 'Partly detected. Please complete the missing fields.');
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    String v(TextEditingController c) => c.text.trim();

    final address = <String, String>{
      'label': _label,
      'name': v(_name),
      'phone': '+965 ${v(_phone)}',
      'governorate': _governorate ?? '',
      'area': _area ?? '',
      'block': v(_block),
      'street': v(_street),
      'avenue': v(_avenue),
      'building': v(_building),
      'floor': v(_floor),
      'flat': v(_flat),
      'paci': v(_paci),
      'notes': v(_notes),
    };

    // Save to "Saved Addresses" (server if logged in, phone if guest)
    await _saveToSavedAddresses();
    if (!mounted) return;

    // Payment screen shows the order success page after "Place Order",
    // and "Continue Shopping" takes the user to the home page.
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          address: address,
          items: widget.items,
          total: widget.total,
          onPlaceOrder: (method) async {
            await widget.onPlaceOrder?.call(address, method);
          },
        ),
      ),
    );
  }
  // ── Save to Saved Addresses ────────────────────────────────────────────────
  Future<void> _saveToSavedAddresses() async {
    String v(TextEditingController c) => c.text.trim();

    final draft = SavedAddress(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: _label,
      name: v(_name),
      phone: v(_phone), // 8 digits, same as the Saved Addresses screen
      governorate: _governorate ?? '',
      area: _area ?? '',
      block: v(_block),
      street: v(_street),
      building: v(_building),
      floor: v(_floor),
      flat: v(_flat),
      landmark: v(_notes),
    );

    try {
      // Read the current local list
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(kSavedAddressesKey) ?? [];
      final list = <SavedAddress>[];
      for (final s in raw) {
        try {
          list.add(
              SavedAddress.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (_) {}
      }

      // Already saved? Then do nothing (e.g. user picked a saved card)
      final exists = list.any((a) =>
      a.phone == draft.phone &&
          a.governorate == draft.governorate &&
          a.area == draft.area &&
          a.block == draft.block &&
          a.street == draft.street &&
          a.building == draft.building &&
          a.floor == draft.floor &&
          a.flat == draft.flat);
      if (exists) return;

      var toSave = draft;
      if (await AddressApi.isLoggedIn()) {
        final saved = await AddressApi.add(draft.toJson());
        toSave = SavedAddress.fromJson(saved); // carries the server id
      }

      list.add(toSave);
      await prefs.setStringList(
        kSavedAddressesKey,
        list.map((a) => jsonEncode(a.toJson())).toList(),
      );
      if (mounted) setState(() => _saved = list);
    } on AddressApiException catch (e) {
      _toast(e.message); // saving failed, but checkout continues
    } catch (_) {}
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────
  Widget _savedAddressesList() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _saved.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _savedCard(_saved[i]),
      ),
    );
  }

  Widget _savedCard(SavedAddress a) {
    final selected = _selectedSavedId == a.id;
    final line = [
      if (a.block.isNotEmpty) 'Block ${a.block}',
      if (a.street.isNotEmpty) 'Street ${a.street}',
      if (a.building.isNotEmpty) 'Bldg ${a.building}',
      if (a.area.isNotEmpty) a.area,
      if (a.governorate.isNotEmpty) a.governorate,
    ].join(', ');
    final icon = a.label == 'Work'
        ? Icons.work_outline
        : a.label == 'Other'
        ? Icons.place_outlined
        : Icons.home_outlined;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _applySaved(a),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _pink : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: _pink),
                const SizedBox(width: 6),
                Text(a.label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                const Spacer(),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? _pink : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(a.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Expanded(
              child: Text(line,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, height: 1.3, color: Colors.grey.shade700)),
            ),
            const SizedBox(height: 4),
            Text('+965 ${a.phone}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: _pink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kuwait addresses use Governorate, Area, Block, Street and '
                  'Building. Fill them in the same order as on your PACI card.',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade800, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black87)),
  );

  InputDecoration _dec(String label, {String? hint, Widget? prefix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefix: prefix,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(_pink, 1.5),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 1.5),
      disabledBorder: border(Colors.grey.shade200),
    );
  }

  Widget _field(
      String label,
      TextEditingController c, {
        bool required = true,
        TextInputType? type,
        List<TextInputFormatter>? formatters,
        String? Function(String?)? extra,
        String? hint,
        int maxLines = 1,
        TextInputAction action = TextInputAction.next,
        TextCapitalization caps = TextCapitalization.sentences,
      }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      inputFormatters: formatters,
      maxLines: maxLines,
      textInputAction: action,
      textCapitalization: caps,
      style: const TextStyle(fontSize: 14),
      decoration: _dec(label, hint: hint),
      validator: (v) {
        final t = (v ?? '').trim();
        if (required && t.isEmpty) return 'Required';
        return extra?.call(t);
      },
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 14),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: _dec(
        'Mobile number',
        prefix: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text('+965',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ),
      ),
      validator: (v) {
        final t = (v ?? '').trim();
        if (t.isEmpty) return 'Required';
        if (t.length != 8) return 'Enter 8 digits';
        if (!RegExp(r'^[2569]').hasMatch(t)) {
          return 'Kuwait numbers start with 2, 5, 6 or 9';
        }
        return null;
      },
    );
  }

  Widget _pickerField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String> onSelected,
    bool enabled = true,
    String? disabledHint,
  }) {
    return FormField<String>(
      validator: (_) => value == null ? 'Please select $label' : null,
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled
              ? () async {
            FocusScope.of(context).unfocus();
            final r = await _showPicker(label, options, value);
            if (r != null) {
              onSelected(r);
              state.didChange(r);
            }
          }
              : null,
          child: InputDecorator(
            isEmpty: value == null,
            decoration: _dec(label).copyWith(
              errorText: state.errorText,
              hintText: enabled ? null : disabledHint,
              enabled: enabled,
              suffixIcon: const Icon(Icons.keyboard_arrow_down),
            ),
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showPicker(
      String title, List<String> options, String? selected) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.65),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select $title',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final o = options[i];
                    final isSel = o == selected;
                    return ListTile(
                      title: Text(o,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                              isSel ? FontWeight.w700 : FontWeight.w400,
                              color: isSel ? _pink : Colors.black87)),
                      trailing: isSel
                          ? const Icon(Icons.check, color: _pink, size: 20)
                          : null,
                      onTap: () => Navigator.pop(sheetCtx, o),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}