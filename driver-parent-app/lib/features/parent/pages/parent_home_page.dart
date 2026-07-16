import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/session/session_storage.dart';
import '../../../services/child_service.dart';
import '../../../services/tracking_service.dart';
import '../../../services/transport_service.dart';
import '../../../widgets/mobile_location_gate.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  static const _blue = Color(0xFF0D4896);
  static const _green = Color(0xFF21C260);
  static const _kigali = LatLng(-1.9441, 30.0619);

  final MapController _mapCtrl = MapController();

  // Location
  StreamSubscription<Position>? _posSub;
  LatLng? _parentLatLng;
  bool _locationFirstFix = false;

  // Assigned conductor (loaded once; always shown even without active journey)
  Map<String, dynamic>? _assignedConductor;
  Map<String, dynamic>? _assignedBus;

  // Live tracking (polled every 10s)
  String? _activeChildId;
  Map<String, dynamic>? _tracking;

  // Dialog guard
  bool _arrivedDialogShown = false;
  String? _lastTrackingId;

  Timer? _pollTimer;

  // ── Derived ──────────────────────────────────────────────────────────────────

  LatLng? get _busLatLng {
    final t = _tracking;
    if (t == null) return null;
    final lat = _toDouble(t['currentLatitude']);
    final lng = _toDouble(t['currentLongitude']);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  bool get _journeyActive {
    final status = (_tracking?['status'] ?? '').toString().toUpperCase();
    return status.isNotEmpty && status != 'NOT_IN_ROUTE';
  }

  bool get _busArrived {
    final bus = _busLatLng;
    final parent = _parentLatLng;
    if (bus == null || parent == null) return false;
    return _distanceMeters(bus, parent) < 200;
  }

  String get _etaText {
    final eta = _tracking?['estimatedArrival']?.toString() ?? '';
    if (eta.isEmpty) return '';
    final asNum = int.tryParse(eta.trim());
    if (asNum != null) return '$asNum min to reach home';
    return '$eta to reach home';
  }

  // Prefer live tracking conductor when journey is active
  Map<String, dynamic>? get _conductor {
    if (_journeyActive) {
      final c = _tracking?['conductor'];
      if (c is Map<String, dynamic>) return c;
    }
    return _assignedConductor;
  }

  Map<String, dynamic>? get _bus {
    if (_journeyActive) {
      final b = _tracking?['bus'];
      if (b is Map<String, dynamic>) return b;
    }
    return _assignedBus;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _startLocationStream(),
      _loadChildren(),
      _loadAssignedBus(),
    ]);
    if (!mounted) return;
    _startPolling();
  }

  Future<void> _startLocationStream() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    ).listen((pos) {
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _parentLatLng = ll);
      if (!_locationFirstFix) {
        _locationFirstFix = true;
        _recenter();
      }
    });
  }

  Future<void> _loadChildren() async {
    try {
      final raw = await ChildService.getMyChildren();
      if (!mounted) return;
      setState(() {
        if (raw.isNotEmpty) {
          _activeChildId = raw.first['id']?.toString();
        }
      });
    } catch (_) {}
  }

  Future<void> _loadAssignedBus() async {
    try {
      final userId = await SessionStorage.getUserId();
      if (userId == null) return;
      final data = await TransportService.getAssignedBusForParent(userId);
      if (!mounted || data == null) return;
      setState(() {
        _assignedConductor = data['conductor'] as Map<String, dynamic>?;
        _assignedBus = data['bus'] as Map<String, dynamic>?;
      });
    } catch (_) {}
  }

  void _startPolling() {
    _pollTracking();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _pollTracking(),
    );
  }

  Future<void> _pollTracking() async {
    final childId = _activeChildId;
    if (childId == null) return;

    final data = await TrackingService.getBusTrackingForChild(childId);
    if (!mounted) return;

    final newId = data?['id']?.toString();
    if (newId != null && newId != _lastTrackingId) {
      _lastTrackingId = newId;
      _arrivedDialogShown = false;
    }

    setState(() => _tracking = data);

    if (_busArrived && !_arrivedDialogShown && data != null) {
      _arrivedDialogShown = true;
      _showBusArrivedDialog();
    }
  }

  void _recenter() {
    final target = _busLatLng ?? _parentLatLng;
    if (target == null) return;
    _mapCtrl.move(target, 15.5);
  }

  void _showBusArrivedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _BusArrivedDialog(),
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final center = _busLatLng ?? _parentLatLng ?? _kigali;

    return MobileLocationGate(
      child: Scaffold(
        body: Stack(
          children: [
            // ── Map ──────────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.bus_app',
                ),

                // Line from bus to parent only when journey active
                if (_busLatLng != null && _parentLatLng != null && _journeyActive)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_busLatLng!, _parentLatLng!],
                        color: _green,
                        strokeWidth: 3.5,
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    if (_parentLatLng != null)
                      Marker(
                        point: _parentLatLng!,
                        width: 54,
                        height: 54,
                        child: const _ParentLocationMarker(),
                      ),
                    // Bus marker only when journey is active
                    if (_busLatLng != null && _journeyActive)
                      Marker(
                        point: _busLatLng!,
                        width: 54,
                        height: 54,
                        child: const _BusMarker(),
                      ),
                  ],
                ),
              ],
            ),

            // ── Status banner (journey active only) ───────────────────────────
            if (_journeyActive)
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _StatusBanner(
                    arrived: _busArrived,
                    etaText: _etaText,
                  ),
                ),
              ),

            // ── Recenter button ───────────────────────────────────────────────
            Positioned(
              right: 14,
              bottom: 190,
              child: Material(
                color: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: _recenter,
                  icon: const Icon(IconsaxPlusLinear.gps, color: _blue),
                  tooltip: 'Recenter',
                ),
              ),
            ),

            // ── Bottom conductor panel ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomPanel(
                conductor: _conductor,
                bus: _bus,
                journeyActive: _journeyActive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  static double _distanceMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final x = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

// ── Status banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final bool arrived;
  final String etaText;

  const _StatusBanner({required this.arrived, required this.etaText});

  @override
  Widget build(BuildContext context) {
    final color = arrived ? const Color(0xFF21C260) : const Color(0xFF0D4896);
    final icon = arrived
        ? IconsaxPlusBold.shield_tick
        : IconsaxPlusLinear.clock;
    final label = arrived
        ? 'Bus has arrived'
        : (etaText.isNotEmpty ? etaText : 'Bus is on its way');

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bus marker ────────────────────────────────────────────────────────────────

class _BusMarker extends StatelessWidget {
  const _BusMarker();

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            IconsaxPlusBold.bus,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Parent location marker ────────────────────────────────────────────────────

class _ParentLocationMarker extends StatelessWidget {
  const _ParentLocationMarker();

  static const _green = Color(0xFF21C260);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Bottom conductor panel ────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final Map<String, dynamic>? conductor;
  final Map<String, dynamic>? bus;
  final bool journeyActive;

  const _BottomPanel({
    required this.conductor,
    required this.bus,
    required this.journeyActive,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2D40) : const Color(0xFFDCE6F5);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final conductorName =
        conductor?['fullName']?.toString() ?? 'No conductor assigned';
    final conductorPhone = conductor?['phoneNumber']?.toString() ?? '—';
    final conductorPhoto = conductor?['photoUrl']?.toString();
    final plateNumber = bus?['plateNumber']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Conductor card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A2530)
                  : const Color(0xFFF5F8FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFDCE6F5),
                  backgroundImage: (conductorPhoto != null &&
                          conductorPhoto.isNotEmpty)
                      ? NetworkImage(conductorPhoto)
                      : null,
                  child: (conductorPhoto == null || conductorPhoto.isEmpty)
                      ? const Icon(IconsaxPlusLinear.user,
                          color: _blue, size: 22)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your conductor',
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        conductorName,
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (journeyActive)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(IconsaxPlusLinear.send_2,
                        color: _blue, size: 18),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Phone + optional plate row — always shown when conductor is known
          if (conductor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  if (plateNumber != null && plateNumber.isNotEmpty) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(IconsaxPlusLinear.bus,
                              color: _blue, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            plateNumber,
                            style: TextStyle(
                              color: onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 22, color: borderColor),
                  ],
                  Expanded(
                    child: Row(
                      mainAxisAlignment: (plateNumber != null &&
                              plateNumber.isNotEmpty)
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Icon(IconsaxPlusLinear.call,
                            color: _blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          conductorPhone,
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bus arrived dialog ────────────────────────────────────────────────────────

class _BusArrivedDialog extends StatelessWidget {
  const _BusArrivedDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconsaxPlusBold.location,
                color: Color(0xFFE53935),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Bus has reached the bus stop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'The bus has arrived at the bus stop, pick up your kids from the bus stop as soon as possible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D4896),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
