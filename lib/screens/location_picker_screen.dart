import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mtl_jewellery/config/app_colors.dart';

/// Result returned when the user confirms a location.
class PickedLocation {
  final double lat;
  final double lng;
  final String title; // short, e.g. "Salmiya"
  final String full; // full text for the address bar

  const PickedLocation({
    required this.lat,
    required this.lng,
    required this.title,
    required this.full,
  });
}

/// Full-screen map. The user moves the map under a fixed pin and taps
/// "Confirm location". Map: OpenStreetMap tiles.
/// Address text: Nominatim first, then the phone's own geocoder as a backup.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _accent = AppColors.buttonPrimary;
  static const _kuwaitCity = LatLng(29.3759, 47.9774);

  // IMPORTANT: put your app name and a REAL email you check here.
  // Nominatim blocks requests with a missing or placeholder User-Agent.
  static const _userAgent = 'KliqpikApp/1.0 (srimohanreddy6161@gmail.com)';

  final MapController _map = MapController();
  Timer? _debounce;
  int _requestId = 0;
  LatLng _center = _kuwaitCity;
  LatLng? _lastLookup;

  bool _loading = false;
  bool _locating = false;
  bool _insideKuwait = true;
  String _title = '';
  String _full = 'Move the map to choose your location';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAtMyLocation());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _map.dispose();
    super.dispose();
  }

  // Start on the user's real position. Kuwait City is only the fallback
  // when location is off or permission is denied.
  Future<void> _startAtMyLocation() async {
    final found = await _goToMyLocation();
    if (!found && mounted) _lookup(_kuwaitCity);
  }

  // ── Map events ─────────────────────────────────────────────────────────────
  void _onMapEvent(MapEvent e) {
    _center = e.camera.center;
    // Look up the address once the map has stopped moving.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () => _lookup(_center));
  }

  // ── Address lookup ─────────────────────────────────────────────────────────
  Future<void> _lookup(LatLng p) async {
    // Skip if the pin has barely moved.
    if (_lastLookup != null &&
        const Distance().as(LengthUnit.Meter, _lastLookup!, p) < 8) {
      return;
    }
    _lastLookup = p;

    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    // 1) Nominatim (OpenStreetMap)
    var ok = await _lookupNominatim(p, id);
    // 2) Backup: the phone's own geocoder
    if (!ok && mounted && id == _requestId) ok = await _lookupDevice(p, id);

    if (!mounted || id != _requestId) return;
    if (!ok) {
      setState(() {
        _loading = false;
        _error = 'Could not load the address. Move the map and try again.';
      });
    }
  }

  Future<bool> _lookupNominatim(LatLng p, int id) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': '${p.latitude}',
        'lon': '${p.longitude}',
        'addressdetails': '1',
        'accept-language': 'en',
      });
      final res = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));

      if (!mounted || id != _requestId) return true; // stale, ignore
      if (res.statusCode != 200) {
        debugPrint('NOMINATIM status ${res.statusCode}: ${res.body}');
        return false;
      }

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final a = (j['address'] as Map<String, dynamic>?) ?? {};

      String pick(List<String> keys) {
        for (final k in keys) {
          final v = a[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return '';
      }

      _applyResult(
        area: pick([
          'suburb', 'neighbourhood', 'city_district', 'quarter',
          'town', 'city', 'village',
        ]),
        road: pick(['road', 'pedestrian', 'highway']),
        gov: pick(['state', 'county', 'region']),
        inKuwait: ((a['country_code'] as String?) ?? '').toLowerCase() == 'kw',
        fallbackFull: (j['display_name'] as String?) ?? 'Unnamed location',
      );
      return true;
    } catch (e) {
      debugPrint('NOMINATIM error: $e');
      return false;
    }
  }

  Future<bool> _lookupDevice(LatLng p, int id) async {
    try {
      final marks =
      await geo.placemarkFromCoordinates(p.latitude, p.longitude);
      if (!mounted || id != _requestId) return true; // stale, ignore
      if (marks.isEmpty) return false;
      final m = marks.first;

      String first(List<String?> v) {
        for (final s in v) {
          if ((s ?? '').trim().isNotEmpty) return s!.trim();
        }
        return '';
      }

      _applyResult(
        area: first([m.subLocality, m.locality, m.subAdministrativeArea]),
        road: first([m.thoroughfare, m.street]),
        gov: first([m.administrativeArea]),
        inKuwait: (m.isoCountryCode ?? '').toUpperCase() == 'KW',
        fallbackFull: 'Unnamed location',
      );
      return true;
    } catch (e) {
      debugPrint('DEVICE GEOCODER error: $e');
      return false;
    }
  }

  void _applyResult({
    required String area,
    required String road,
    required String gov,
    required bool inKuwait,
    required String fallbackFull,
  }) {
    if (!mounted) return;
    final parts = [road, area, gov].where((s) => s.isNotEmpty).toList();
    setState(() {
      _loading = false;
      _insideKuwait = inKuwait;
      _title = area.isNotEmpty ? area : (road.isNotEmpty ? road : 'Kuwait');
      _full = parts.isEmpty ? fallbackFull : parts.join(', ');
      _error =
      inKuwait ? null : 'This location is outside Kuwait. Please move the pin.';
    });
  }

  // ── My location ────────────────────────────────────────────────────────────
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _goToMyLocation({bool silent = false}) async {
    if (_locating) return false;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!silent) _toast('Please turn on location services');
        return false;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!silent) _toast('Location permission is needed to find you');
        return false;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _map.move(LatLng(pos.latitude, pos.longitude), 16);
      return true;
    } catch (_) {
      if (!silent) _toast('Could not get your location');
      return false;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirm() {
    Navigator.pop(
      context,
      PickedLocation(
        lat: _center.latitude,
        lng: _center.longitude,
        title: _title,
        full: _full,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final canConfirm = !_loading && _insideKuwait && _error == null;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _kuwaitCity,
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 18,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mtl_jewellery',
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Fixed pin in the middle (its tip is at the exact center)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 44),
                child: Icon(Icons.location_on, size: 48, color: _accent),
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // My-location button
          Positioned(
            right: 16,
            bottom: 210,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: IconButton(
                icon: _locating
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _accent))
                    : const Icon(Icons.my_location, color: _accent),
                onPressed: _locating ? null : () => _goToMyLocation(),
              ),
            ),
          ),

          // Bottom panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELIVER TO',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: _accent, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _loading
                              ? const Text('Finding address...',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54))
                              : Text(
                            _error ?? _full,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _error != null
                                  ? Colors.red.shade600
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: canConfirm ? _confirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: _accent.withOpacity(0.4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Confirm location',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}