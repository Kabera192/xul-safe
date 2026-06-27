import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../models/stop_model.dart';

class DriverEditStopForm extends StatefulWidget {
  final StopModel stop;

  final Future<void> Function({
    required String locationName,
    required double locationLat,
    required double locationLong,
  }) onSave;

  final VoidCallback onCancel;
  final VoidCallback onDeleteTap;
  final VoidCallback onAssignStudentsTap;

  const DriverEditStopForm({
    super.key,
    required this.stop,
    required this.onSave,
    required this.onCancel,
    required this.onDeleteTap,
    required this.onAssignStudentsTap,
  });

  @override
  State<DriverEditStopForm> createState() => _DriverEditStopFormState();
}

class _DriverEditStopFormState extends State<DriverEditStopForm> {
  static const blue = Color(0xFF0D4896);
  static const green = Color(0xFF21C260);
  static const red = Color(0xFFFC4A4A);
  static const stroke = Color(0xFFDCE6F5);
  static const inputBg = Color(0xFFF5F8FB);

  final _nameCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _mapCtrl = MapController();

  Timer? _searchDebounce;
  late LatLng _selectedLocation;

  bool _capturing = false;
  bool _saving = false;
  bool _searching = false;
  String? _error;
  List<_PlaceSuggestion> _suggestions = [];

  int _tab = 0; // 0 = Details, 1 = Edit name, 2 = Location

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.stop.locationName;
    _selectedLocation = LatLng(
      widget.stop.locationLat,
      widget.stop.locationLong,
    );

    _searchCtrl.addListener(() {
      _searchDebounce?.cancel();
      final query = _searchCtrl.text.trim();
      if (query.length < 3) {
        setState(() { _suggestions = []; _searching = false; });
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
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted) return;
    setState(() { _searching = true; _error = null; });

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '5',
        'countrycodes': 'rw',
        'addressdetails': '1',
      });

      final res = await http.get(uri, headers: {'User-Agent': 'buss-app/1.0'});

      if (res.statusCode != 200) throw Exception('Could not search location');

      final decoded = jsonDecode(res.body);
      if (decoded is! List) throw Exception('Unexpected search response');

      final suggestions = decoded
          .whereType<Map<String, dynamic>>()
          .map(_PlaceSuggestion.fromJson)
          .where((p) => p.name.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() { _suggestions = suggestions; _searching = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _suggestions = []; _searching = false; _error = 'Could not search location'; });
    }
  }

  Future<void> _captureCurrentLocation() async {
    setState(() { _capturing = true; _error = null; });

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final p = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() { _selectedLocation = p; _suggestions = []; _capturing = false; });
      _moveMap(p);
    } catch (_) {
      if (!mounted) return;
      setState(() { _capturing = false; _error = 'Could not capture current location'; });
    }
  }

  void _selectSuggestion(_PlaceSuggestion place) {
    final p = LatLng(place.lat, place.lon);
    setState(() { _selectedLocation = p; _searchCtrl.text = place.name; _suggestions = []; _error = null; });
    _moveMap(p);
  }

  void _moveMap(LatLng p) {
    // Only move the controller when the Location tab's FlutterMap is in the tree.
    if (_tab != 2) return;
    try { _mapCtrl.move(p, 16.5); } catch (_) {}
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() { _error = 'Stop name is required'; _tab = 1; });
      return;
    }
    setState(() { _saving = true; _error = null; });

    try {
      await widget.onSave(
        locationName: name,
        locationLat: _selectedLocation.latitude,
        locationLong: _selectedLocation.longitude,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : const Color(0xFFF5F8FB);
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Back button ──────────────────────────────────────────────────
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: _saving ? null : widget.onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3050) : const Color(0xFFEBF1FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new, size: 16, color: onSurface),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Tab selector ─────────────────────────────────────────────────
          _TabSelector(
            active: _tab,
            tabs: const ['Details', 'Edit name', 'Location'],
            onTap: (i) => setState(() { _tab = i; _error = null; }),
          ),

          const SizedBox(height: 16),

          // ── Tab 0: Details ───────────────────────────────────────────────
          if (_tab == 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stop name',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stop.locationName.isEmpty
                        ? 'No name set'
                        : widget.stop.locationName,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 12),
                  Text(
                    'Coordinates',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.stop.locationLat.toStringAsFixed(6)}, '
                    '${widget.stop.locationLong.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 16.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bus_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 70,
                          height: 70,
                          child: const _LocationMarker(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _SquareActionButton(
                  color: red,
                  icon: IconsaxPlusLinear.trash,
                  onTap: _saving ? null : widget.onDeleteTap,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : widget.onAssignStudentsTap,
                      icon: const Icon(IconsaxPlusLinear.profile_2user, size: 17, color: Colors.white),
                      label: const Text(
                        'Assign students',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ── Tab 1: Edit name ─────────────────────────────────────────────
          if (_tab == 1) ...[
            TextField(
              controller: _nameCtrl,
              enabled: !_saving,
              textInputAction: TextInputAction.done,
              style: TextStyle(color: onSurface, fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1A2530) : inputBg,
                hintText: 'Enter stop name or detail',
                hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.4), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: blue, width: 1.2),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
            ],

            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  disabledBackgroundColor: blue.withValues(alpha: 0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Text(
                  _saving ? 'Saving…' : 'Save name',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],

          // ── Tab 2: Location ──────────────────────────────────────────────
          if (_tab == 2) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    enabled: !_saving,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: onSurface, fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1A2530) : inputBg,
                      hintText: 'Search a place name',
                      hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.4), fontSize: 13),
                      suffixIcon: Icon(IconsaxPlusLinear.search_normal_1, color: blue, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: borderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: blue, width: 1.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SquareActionButton(
                  color: green,
                  icon: IconsaxPlusLinear.gps,
                  onTap: (_capturing || _saving) ? null : _captureCurrentLocation,
                ),
              ],
            ),

            if (_searching) ...[
              const SizedBox(height: 8),
              Text(
                'Searching location…',
                style: TextStyle(color: onSurface.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],

            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SuggestionList(suggestions: _suggestions, onTap: _selectSuggestion, isDark: isDark, borderColor: borderColor),
            ],

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 200,
                child: FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 16.5,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    onTap: (_, point) {
                      setState(() { _selectedLocation = point; _suggestions = []; _error = null; });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bus_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 70,
                          height: 70,
                          child: const _LocationMarker(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
            ],

            const SizedBox(height: 12),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  disabledBackgroundColor: blue.withValues(alpha: 0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Text(
                  _saving ? 'Saving…' : 'Save location',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Tab selector ──────────────────────────────────────────────────────────────

class _TabSelector extends StatelessWidget {
  final int active;
  final List<String> tabs;
  final void Function(int) onTap;

  const _TabSelector({
    required this.active,
    required this.tabs,
    required this.onTap,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        for (int i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                decoration: BoxDecoration(
                  color: i == active
                      ? blue
                      : (isDark ? const Color(0xFF1A2530) : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: i == active
                        ? blue
                        : (isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5)),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: i == active
                          ? Colors.white
                          : (isDark ? const Color(0xFF93B5E8) : blue),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SquareActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _SquareActionButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<_PlaceSuggestion> suggestions;
  final void Function(_PlaceSuggestion) onTap;
  final bool isDark;
  final Color borderColor;

  const _SuggestionList({
    required this.suggestions,
    required this.onTap,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      constraints: const BoxConstraints(maxHeight: 140),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2530) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
        itemBuilder: (context, index) {
          final place = suggestions[index];
          return InkWell(
            onTap: () => onTap(place),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.75),
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

class _LocationMarker extends StatelessWidget {
  const _LocationMarker();

  static const green = Color(0xFF21C260);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.20),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(color: green, shape: BoxShape.circle),
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
