import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mtl_jewellery/services/address_delete_api_service.dart';
import 'package:mtl_jewellery/services/address_edit_api_service.dart';
import 'package:mtl_jewellery/services/address_get_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/address_api_service.dart';

/// Storage key. The profile screen reads the same key to show the count.
const String kSavedAddressesKey = 'saved_addresses';

class SavedAddress {
  final String id;
  final String label; // Home / Work / Other
  final String name;
  final String phone; // 8 digits, +965 is added on display
  final String governorate;
  final String area;
  final String block;
  final String street;
  final String building;
  final String floor;
  final String flat;
  final String landmark;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.governorate,
    required this.area,
    required this.block,
    required this.street,
    required this.building,
    required this.floor,
    required this.flat,
    required this.landmark,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'name': name,
    'phone': phone,
    'governorate': governorate,
    'area': area,
    'block': block,
    'street': street,
    'building': building,
    'floor': floor,
    'flat': flat,
    'landmark': landmark,
  };

  factory SavedAddress.fromJson(Map<String, dynamic> j) => SavedAddress(
    id: (j['id'] ?? '') as String,
    label: (j['label'] ?? 'Home') as String,
    name: (j['name'] ?? '') as String,
    phone: (j['phone'] ?? '') as String,
    governorate: (j['governorate'] ?? '') as String,
    area: (j['area'] ?? '') as String,
    block: (j['block'] ?? '') as String,
    street: (j['street'] ?? '') as String,
    building: (j['building'] ?? '') as String,
    floor: (j['floor'] ?? '') as String,
    flat: (j['flat'] ?? '') as String,
    landmark: (j['landmark'] ?? '') as String,
  );
}

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color _accent = Color(0xFFFFA000);
  static const Color _titleColor = Color(0xFF2B3138);
  static const Color _subtitleColor = Color(0xFF757575);

  List<SavedAddress> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // 1) Show the phone's saved copy straight away
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(kSavedAddressesKey) ?? [];
    final list = <SavedAddress>[];
    for (final s in raw) {
      try {
        list.add(SavedAddress.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _addresses = list;
      _loading = false;
    });

    // 2) Logged in: replace it with the addresses from the server
    try {
      final server = await AddressGetApi.getAll();
      if (server == null) return; // guest: keep the local list
      if (!mounted) return;
      setState(() {
        _addresses = server.map(SavedAddress.fromJson).toList();
      });
      await _persist(); // keeps the phone copy and the profile count in sync
    } on AddressApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      kSavedAddressesKey,
      _addresses.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<void> _openForm({SavedAddress? existing}) async {
    final result = await showModalBottomSheet<SavedAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // keeps the sheet below the status bar
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressForm(existing: existing),
    );
    if (result == null) return;

    var toSave = result;

    if (await AddressApi.isLoggedIn()) {
      try {
        if (existing == null) {
          // New address: save it on the server first
          final saved = await AddressApi.add(result.toJson());
          toSave = SavedAddress.fromJson(saved); // carries the server id
        } else {
          // Edited address: update it on the server
          final saved = await AddressEditApi.edit(existing.id, result.toJson());
          toSave = SavedAddress.fromJson(saved);
        }
      } on AddressApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        return; // not saved, so keep the list unchanged
      }
    }

    if (!mounted) return;
    setState(() {
      final i = _addresses.indexWhere((a) => a.id == toSave.id);
      if (i >= 0) {
        _addresses[i] = toSave;
      } else {
        _addresses.add(toSave);
      }
    });
    await _persist();
  }

  Future<void> _confirmDelete(SavedAddress a) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (yes != true) return;

    // Logged in: delete on the server first
    if (await AddressApi.isLoggedIn()) {
      try {
        await AddressDeleteApi.delete(a.id);
      } on AddressApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        return; // not deleted, so keep it in the list
      }
    }

    if (!mounted) return;
    setState(() => _addresses.removeWhere((x) => x.id == a.id));
    await _persist();
  }

  IconData _labelIcon(String label) {
    switch (label) {
      case 'Work':
        return Icons.work_outline;
      case 'Other':
        return Icons.place_outlined;
      default:
        return Icons.home_outlined;
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
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _accent))
                : _addresses.isEmpty
                ? _emptyState()
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _addressCard(_addresses[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add New Address',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add an address to make checkout faster.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressCard(SavedAddress a) {
    final lineOne = [
      if (a.block.isNotEmpty) 'Block ${a.block}',
      if (a.street.isNotEmpty) 'Street ${a.street}',
      if (a.building.isNotEmpty) 'Building/House ${a.building}',
    ].join(', ');
    final lineTwo = [
      if (a.floor.isNotEmpty) 'Floor ${a.floor}',
      if (a.flat.isNotEmpty) 'Flat ${a.flat}',
    ].join(', ');
    final lineThree =
    [a.area, a.governorate].where((s) => s.isNotEmpty).join(', ');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_labelIcon(a.label), color: _accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  a.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (lineOne.isNotEmpty)
                  Text(
                    lineOne,
                    style: const TextStyle(fontSize: 14, color: _subtitleColor),
                  ),
                if (lineTwo.isNotEmpty)
                  Text(
                    lineTwo,
                    style: const TextStyle(fontSize: 14, color: _subtitleColor),
                  ),
                if (lineThree.isNotEmpty)
                  Text(
                    '$lineThree, Kuwait',
                    style: const TextStyle(fontSize: 14, color: _subtitleColor),
                  ),
                if (a.landmark.isNotEmpty)
                  Text(
                    'Landmark: ${a.landmark}',
                    style: const TextStyle(fontSize: 14, color: _subtitleColor),
                  ),
                const SizedBox(height: 4),
                Text(
                  '+965 ${a.phone}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _titleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (v) {
              if (v == 'edit') _openForm(existing: a);
              if (v == 'delete') _confirmDelete(a);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add / Edit form (bottom sheet) ───────────────────────────────────────────
class _AddressForm extends StatefulWidget {
  final SavedAddress? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  static const Color _accent = Color(0xFFFFA000);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _area;
  late final TextEditingController _block;
  late final TextEditingController _street;
  late final TextEditingController _building;
  late final TextEditingController _floor;
  late final TextEditingController _flat;
  late final TextEditingController _landmark;
  late String _label;
  String? _governorate;

  bool _detecting = false;
  String? _locMsg;
  bool _locIsError = false;

  static const List<String> _governorates = [
    'Capital (Al Asimah)',
    'Hawalli',
    'Farwaniya',
    'Ahmadi',
    'Jahra',
    'Mubarak Al-Kabeer',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _area = TextEditingController(text: e?.area ?? '');
    _block = TextEditingController(text: e?.block ?? '');
    _street = TextEditingController(text: e?.street ?? '');
    _building = TextEditingController(text: e?.building ?? '');
    _floor = TextEditingController(text: e?.floor ?? '');
    _flat = TextEditingController(text: e?.flat ?? '');
    _landmark = TextEditingController(text: e?.landmark ?? '');
    _label = e?.label ?? 'Home';
    _governorate = (e != null && _governorates.contains(e.governorate))
        ? e.governorate
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _area.dispose();
    _block.dispose();
    _street.dispose();
    _building.dispose();
    _floor.dispose();
    _flat.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _setLocMsg(String msg, bool isError) {
    if (!mounted) return;
    setState(() {
      _locMsg = msg;
      _locIsError = isError;
    });
  }

  String? _matchGovernorate(List<String?> parts) {
    final text = parts.whereType<String>().join(' ').toLowerCase();
    if (text.contains('hawall')) return 'Hawalli';
    if (text.contains('farwan')) return 'Farwaniya';
    if (text.contains('ahmadi')) return 'Ahmadi';
    if (text.contains('jahra')) return 'Jahra';
    if (text.contains('mubarak')) return 'Mubarak Al-Kabeer';
    if (text.contains('asimah') ||
        text.contains('capital') ||
        text.contains('kuwait city')) {
      return 'Capital (Al Asimah)';
    }
    return null;
  }

  void _setIfNotEmpty(TextEditingController c, String? value) {
    final v = (value ?? '').trim();
    if (v.isNotEmpty) c.text = v;
  }

  Future<void> _detectLocation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _detecting = true;
      _locMsg = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setLocMsg('Please turn on your phone location (GPS) and try again.', true);
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        _setLocMsg('Location permission was denied.', true);
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        _setLocMsg(
            'Location permission is blocked. Enable it in phone Settings > Apps > Permissions.',
            true);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final marks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isEmpty) {
        _setLocMsg('Could not find an address for your location.', true);
        return;
      }
      final p = marks.first;

      // Delivery is Kuwait only.
      if ((p.isoCountryCode ?? '').toUpperCase() != 'KW') {
        _setLocMsg('Your current location is outside Kuwait.', true);
        return;
      }

      final String area =
          [p.locality, p.subLocality, p.subAdministrativeArea]
              .firstWhere((s) => (s ?? '').trim().isNotEmpty,
              orElse: () => '') ??
              '';

      final blockMatch = RegExp(r'block\s*(\d{1,2})', caseSensitive: false)
          .firstMatch('${p.street} ${p.name} ${p.subLocality}');

      if (!mounted) return;
      setState(() {
        _governorate = _matchGovernorate(
            [p.administrativeArea, p.subAdministrativeArea, p.locality]) ??
            _governorate;
      });
      _setIfNotEmpty(_area, area);
      _setIfNotEmpty(_street, p.thoroughfare);
      _setIfNotEmpty(_building, p.subThoroughfare);
      _setIfNotEmpty(_block, blockMatch?.group(1));

      _setLocMsg(
          'Location detected. Please check the details and fill in any missing block, street or building.',
          false);
    } catch (_) {
      _setLocMsg('Could not get your location. Please try again.', true);
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      SavedAddress(
        id: widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        label: _label,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        governorate: _governorate ?? '',
        area: _area.text.trim(),
        block: _block.text.trim(),
        street: _street.text.trim(),
        building: _building.text.trim(),
        floor: _floor.text.trim(),
        flat: _flat.text.trim(),
        landmark: _landmark.text.trim(),
      ),
    );
  }

  InputDecoration _dec(String label) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(_accent, 1.5),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // keeps everything above the keyboard
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── FIXED HEADER: back arrow + title ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.existing == null
                        ? 'Add New Address'
                        : 'Edit Address',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ── FIXED: Home / Work / Other ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: ['Home', 'Work', 'Other'].map((l) {
                    final selected = _label == l;
                    return ChoiceChip(
                      label: Text(l),
                      selected: selected,
                      selectedColor: _accent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _label = l),
                    );
                  }).toList(),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // ── SCROLLABLE FIELDS ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Full name'),
                      validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      decoration: _dec('Mobile number')
                          .copyWith(prefixText: '+965  '),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Enter your mobile number';
                        if (t.length != 8) return 'Enter 8 digits';
                        if (!RegExp(r'^[2569]').hasMatch(t)) {
                          return 'Kuwait numbers start with 2, 5, 6 or 9';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _detecting ? null : _detectLocation,
                        icon: _detecting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _accent),
                        )
                            : const Icon(Icons.my_location,
                            color: _accent, size: 20),
                        label: Text(
                          _detecting
                              ? 'Detecting location...'
                              : 'Detect my location',
                          style: const TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _accent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_locMsg != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _locMsg!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _locIsError
                              ? Colors.red.shade600
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: 'Kuwait',
                      enabled: false,
                      decoration: _dec('Country'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _governorate,
                      isExpanded: true,
                      decoration: _dec('Governorate'),
                      items: _governorates
                          .map((g) =>
                          DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _governorate = v),
                      validator: (v) =>
                      v == null ? 'Select governorate' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _area,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Area (e.g. Salmiya, Hawally)'),
                      validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter area' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _block,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: _dec('Block'),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Enter block'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _street,
                            textInputAction: TextInputAction.next,
                            decoration: _dec('Street'),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Enter street'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _building,
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Building / House no.'),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Enter building or house no.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _floor,
                            textInputAction: TextInputAction.next,
                            decoration: _dec('Floor (optional)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _flat,
                            textInputAction: TextInputAction.next,
                            decoration: _dec('Flat (optional)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _landmark,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      decoration:
                      _dec('Landmark / delivery note (optional)'),
                    ),
                  ],
                ),
              ),
            ),

            // ── FIXED SAVE BUTTON ──────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Save Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}