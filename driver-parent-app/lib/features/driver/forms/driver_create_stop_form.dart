import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class DriverCreateStopForm extends StatefulWidget {
  final Future<void> Function({
    required String locationName,
    required double locationLat,
    required double locationLong,
  }) onSave;

  final VoidCallback onCancel;

  const DriverCreateStopForm({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<DriverCreateStopForm> createState() => _DriverCreateStopFormState();
}

class _DriverCreateStopFormState extends State<DriverCreateStopForm> {
  static const blue = Color(0xFF0D4896);
  static const green = Color(0xFF21C260);

  final _detailCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _mapCtrl = MapController();

  Timer? _searchDebounce;

  LatLng? _currentLocation;
  LatLng? _selectedLocation;

  bool _capturing = false;
  bool _saving = false;
  bool _searching = false;

  String? _error;

  List<_PlaceSuggestion> _suggestions = [];

  static const LatLng _kigaliFallback = LatLng(-1.9441, 30.0619);

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();

    _searchCtrl.addListener(() {
      _searchDebounce?.cancel();

      final query = _searchCtrl.text.trim();

      if (query.length < 3) {
        setState(() {
          _suggestions = [];
          _searching = false;
        });
        return;
      }

      _searchDebounce = Timer(const Duration(milliseconds: 550), () {
        _searchPlaces(query);
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _detailCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final p = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;

      setState(() {
        _currentLocation = p;
        _selectedLocation = p;
      });

      _moveMap(p);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedLocation = _kigaliFallback;
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted) return;

    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'json',
          'limit': '5',
          'countrycodes': 'rw',
          'addressdetails': '1',
        },
      );

      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'buss-app/1.0',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('Could not search location');
      }

      final decoded = jsonDecode(res.body);

      if (decoded is! List) {
        throw Exception('Unexpected search response');
      }

      final suggestions = decoded
          .whereType<Map<String, dynamic>>()
          .map(_PlaceSuggestion.fromJson)
          .where((place) => place.name.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _suggestions = suggestions;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _suggestions = [];
        _searching = false;
        _error = 'Could not search location';
      });
    }
  }

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _capturing = true;
      _error = null;
    });

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final p = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;

      setState(() {
        _currentLocation = p;
        _selectedLocation = p;
        _suggestions = [];
        _capturing = false;
      });

      _moveMap(p);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _capturing = false;
        _error = 'Could not capture current location';
      });
    }
  }

  void _selectSuggestion(_PlaceSuggestion place) {
    final p = LatLng(place.lat, place.lon);

    setState(() {
      _selectedLocation = p;
      _searchCtrl.text = place.name;
      _suggestions = [];
      _error = null;
    });

    _moveMap(p);
  }

  void _moveMap(LatLng p) {
    _mapCtrl.move(p, 16.5);
  }

  Future<void> _save() async {
    final detail = _detailCtrl.text.trim();
    final selected = _selectedLocation;

    if (detail.isEmpty) {
      setState(() {
        _error = 'Stop detail is required';
      });
      return;
    }

    if (selected == null) {
      setState(() {
        _error = 'Please capture or select a location first';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSave(
        locationName: detail,
        locationLat: selected.latitude,
        locationLong: selected.longitude,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedLocation ?? _currentLocation ?? _kigaliFallback;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: _saving ? null : widget.onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF1FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          _InputBox(
            controller: _detailCtrl,
            hintText: 'Enter a small detail',
            icon: IconsaxPlusLinear.edit_2,
          ),

          const SizedBox(height: 10),

          _InputBox(
            controller: _searchCtrl,
            hintText: 'Search a place name',
            icon: IconsaxPlusLinear.search_normal_1,
          ),

          if (_searching) ...[
            const SizedBox(height: 8),
            const Text(
              'Searching location…',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SuggestionList(
              suggestions: _suggestions,
              onTap: _selectSuggestion,
            ),
          ],

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 214,
              child: FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 16.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (_, point) {
                    setState(() {
                      _selectedLocation = point;
                      _suggestions = [];
                      _error = null;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.bus_app',
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 70,
                          height: 70,
                          child: const _SelectedLocationMarker(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (_error != null) ...[
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed:
                  (_capturing || _saving) ? null : _captureCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                elevation: 0,
                disabledBackgroundColor: green.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                _capturing ? 'Capturing…' : 'Capture my current location',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                elevation: 0,
                disabledBackgroundColor: blue.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                _saving ? 'Saving…' : 'Save bus stop',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<_PlaceSuggestion> suggestions;
  final void Function(_PlaceSuggestion place) onTap;

  const _SuggestionList({
    required this.suggestions,
    required this.onTap,
  });

  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 140),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: stroke, width: 1),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          color: stroke,
        ),
        itemBuilder: (context, index) {
          final place = suggestions[index];

          return InkWell(
            onTap: () => onTap(place),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF233A5A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const _InputBox({
    required this.controller,
    required this.hintText,
    required this.icon,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);
  static const inputBg = Color(0xFFF5F8FB);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.black45,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: Icon(
          icon,
          color: blue,
          size: 18,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: stroke, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: blue, width: 1.2),
        ),
      ),
    );
  }
}

class _SelectedLocationMarker extends StatelessWidget {
  const _SelectedLocationMarker();

  static const green = Color(0xFF21C260);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: green.withOpacity(0.20),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PlaceSuggestion {
  final String name;
  final double lat;
  final double lon;

  const _PlaceSuggestion({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory _PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return _PlaceSuggestion(
      name: (json['display_name'] ?? '').toString(),
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      lon: double.tryParse(json['lon']?.toString() ?? '') ?? 0.0,
    );
  }
}