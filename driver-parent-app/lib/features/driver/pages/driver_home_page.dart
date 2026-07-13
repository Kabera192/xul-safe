import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../services/attendance_service.dart';
import '../../../services/child_service.dart';
import '../models/attendance_record_model.dart';
import '../../../services/profile_service.dart';
import '../../../services/transport_service.dart';
import '../models/child_model.dart';
import '../models/driver_profile_model.dart';
import '../models/stop_model.dart';
import '../widgets/stop_attendance_sheet.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  static const _blue = Color(0xFF0D4896);
  static const _kigali = LatLng(-1.9441, 30.0619);

  final MapController _mapCtrl = MapController();

  // Location
  StreamSubscription<Position>? _posSub;
  LatLng? _driverLatLng;
  bool _firstFixDone = false;

  // Data
  DriverProfileModel? _profile;
  Map<String, dynamic>? _bus;
  Map<String, dynamic>? _route;
  List<StopModel> _stops = [];
  List<ChildModel> _children = [];
  bool _loading = true;
  String? _error;

  // Journey
  Map<String, dynamic>? _activeJourney;
  Timer? _gpsTimer;

  // Attendance popup state
  final Set<int> _confirmedStopIds = {};
  bool _popupShowing = false;

  bool get _journeyActive => _activeJourney != null;
  String? get _journeyId => _activeJourney?['id']?.toString();
  String get _tripType => _activeJourney?['tripType']?.toString() ?? '';
  String get _session =>
      _tripType == 'MORNING_PICKUP' ? 'MORNING' : 'AFTERNOON';

  int get _nearestStopIndex {
    final driver = _driverLatLng;
    if (driver == null || _stops.isEmpty) return 0;
    int nearestIdx = 0;
    double minDist = double.infinity;
    for (int i = 0; i < _stops.length; i++) {
      final d = _distanceMeters(
          driver, LatLng(_stops[i].locationLat, _stops[i].locationLong));
      if (d < minDist) {
        minDist = d;
        nearestIdx = i;
      }
    }
    return nearestIdx;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startLocationStream();
    _loadData();
  }

  void _startLocationStream() {
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _driverLatLng = ll);
      if (!_firstFixDone) {
        _firstFixDone = true;
        _recenter();
      }
      _checkStopProximity();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ProfileService.getMyProfile(),
        TransportService.getMyBus(),
        TransportService.getMyRoute(),
        TransportService.getMyStops(),
        ChildService.getMyBusChildren(),
      ]);

      final profileRaw = results[0] as Map<String, dynamic>;
      final busRaw = results[1] as Map<String, dynamic>;
      final routeRaw = results[2] as Map<String, dynamic>;
      final stopsRaw = results[3] as List<Map<String, dynamic>>;
      final childrenRaw = results[4] as List<Map<String, dynamic>>;

      final stops = stopsRaw.map(StopModel.fromApiResponse).toList();
      stops.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      final children = childrenRaw.map(ChildModel.fromApiResponse).toList();

      if (!mounted) return;
      setState(() {
        _profile = DriverProfileModel.fromApiResponse(profileRaw);
        _bus = busRaw;
        _route = routeRaw;
        _stops = stops;
        _children = children;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _recenter() {
    final target = _driverLatLng;
    if (target == null) return;
    _mapCtrl.move(target, 15.5);
  }

  // ── Proximity check ───────────────────────────────────────────────────────────

  void _checkStopProximity() {
    if (!_journeyActive || _popupShowing || _stops.isEmpty) return;
    final driver = _driverLatLng;
    if (driver == null) return;

    for (final stop in _stops) {
      if (_confirmedStopIds.contains(stop.id)) continue;
      final dist = _distanceMeters(
          driver, LatLng(stop.locationLat, stop.locationLong));
      if (dist <= 350) {
        _showAttendancePopup(stop);
        break;
      }
    }
  }

  Future<void> _showAttendancePopup(StopModel stop,
      {String confirmLabel = 'Confirm'}) async {
    if (_popupShowing || !mounted) return;
    _popupShowing = true;
    AttendanceService.notifyStopArrival(stopId: stop.id, session: _session);

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StopAttendanceSheet(
        currentStop: stop,
        allStops: _stops,
        allChildren: _children,
        session: _session,
        confirmLabel: confirmLabel,
      ),
    );

    _confirmedStopIds.add(stop.id);
    _popupShowing = false;
  }

  // ── Journey control ───────────────────────────────────────────────────────────

  void _showStartJourneyDialog() {
    if (_children.isEmpty) {
      _showSnack('No children are assigned to this bus yet.');
      return;
    }

    final hour = DateTime.now().hour;
    final suggestedType =
        hour < 12 ? 'MORNING_PICKUP' : 'AFTERNOON_DROPOFF';
    final suggestedLabel =
        hour < 12 ? 'Morning Pickup' : 'Afternoon Drop-off';
    final otherLabel =
        hour < 12 ? 'Afternoon Drop-off' : 'Morning Pickup';
    final otherType =
        hour < 12 ? 'AFTERNOON_DROPOFF' : 'MORNING_PICKUP';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Start a new journey',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
          'Your GPS location will be shared with parents in real time.\n\nSuggested trip: $suggestedLabel',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _beginJourneyFlow(otherType);
            },
            child: Text(otherLabel,
                style: const TextStyle(fontSize: 13)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _beginJourneyFlow(suggestedType);
            },
            child: Text(suggestedLabel,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _beginJourneyFlow(String tripType) async {
    if (tripType == 'MORNING_PICKUP') {
      await _startJourney(tripType);
      return;
    }

    // Afternoon: check morning boarding records first
    List<AttendanceRecordModel> morningRecords = [];
    try {
      morningRecords = await AttendanceService.getSessionAttendance(
        date: DateTime.now(),
        session: 'MORNING',
      );
    } catch (_) {}

    final alreadyRecorded = morningRecords.any((r) => r.boarded);

    if (!alreadyRecorded) {
      // No morning boarding recorded — ask driver to confirm who's on the bus
      if (!mounted) return;
      final absentIds = morningRecords
          .where((r) => r.isAbsent)
          .map((r) => r.childId)
          .toSet();
      final childrenForPopup =
          _children.where((c) => !absentIds.contains(c.id)).toList();

      _popupShowing = true;
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => StopAttendanceSheet(
          currentStop: null,
          allStops: _stops,
          allChildren: childrenForPopup,
          session: 'MORNING',
          confirmLabel: 'Confirm & Start Journey',
        ),
      );
      _popupShowing = false;
    }

    if (!mounted) return;
    await _startJourney(tripType);
  }

  Future<void> _startJourney(String tripType) async {
    final driver = _driverLatLng;
    final profile = _profile;
    final bus = _bus;
    final route = _route;

    if (driver == null) {
      _showSnack('Waiting for GPS fix — try again in a moment.');
      return;
    }
    if (profile == null || bus == null || route == null) {
      _showSnack('Bus data not loaded. Tap refresh and try again.');
      return;
    }

    try {
      final result = await TransportService.startBusJourney(
        tripType: tripType,
        conductorId: profile.driverId,
        busId: _toInt(bus['id']),
        routeId: _toInt(route['id']),
        latitude: driver.latitude,
        longitude: driver.longitude,
      );
      if (!mounted) return;
      setState(() => _activeJourney = result);
      _startGpsSharing();
    } catch (e) {
      _showSnack('Could not start journey: $e');
    }
  }

  void _showEndJourneyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('End Journey',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text(
          'Are you sure you want to end the current journey? GPS sharing will stop immediately.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _endJourney();
            },
            child: const Text('End Journey'),
          ),
        ],
      ),
    );
  }

  Future<void> _endJourney() async {
    final id = _journeyId;
    if (id == null) return;
    try {
      await TransportService.endBusJourney(id);
      if (!mounted) return;
      _gpsTimer?.cancel();
      setState(() {
        _activeJourney = null;
        _confirmedStopIds.clear();
      });
    } catch (e) {
      _showSnack('Could not end journey: $e');
    }
  }

  void _startGpsSharing() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _uploadLocation();
      _checkStopProximity();
    });
  }

  Future<void> _uploadLocation() async {
    final id = _journeyId;
    final ll = _driverLatLng;
    if (id == null || ll == null) return;
    try {
      await TransportService.updateBusLocation(
        journeyId: id,
        latitude: ll.latitude,
        longitude: ll.longitude,
      );
    } catch (_) {}
  }

  void _showAllChildrenSheet() {
    if (_children.isEmpty) {
      _showSnack('No children assigned to this bus yet.');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StopAttendanceSheet(
        currentStop: null,
        allStops: _stops,
        allChildren: _children,
        session: _session.isEmpty ? 'MORNING' : _session,
        confirmLabel: 'Save Attendance',
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _gpsTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nearestIdx = _journeyActive ? _nearestStopIndex : -1;
    final nearestStop =
        (_journeyActive && _stops.isNotEmpty) ? _stops[nearestIdx] : null;

    final center = _driverLatLng ??
        (_stops.isNotEmpty
            ? LatLng(_stops.first.locationLat, _stops.first.locationLong)
            : _kigali);

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bus_app',
              ),

              // Route polyline (journey active only)
              if (_journeyActive && _stops.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _stops
                          .map((s) =>
                              LatLng(s.locationLat, s.locationLong))
                          .toList(),
                      color: _blue.withValues(alpha: 0.4),
                      strokeWidth: 3.0,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // Stop markers (journey active only)
                  if (_journeyActive)
                    ..._stops.asMap().entries.map((e) {
                      final isCurrent = e.key == nearestIdx;
                      return Marker(
                        point: LatLng(
                            e.value.locationLat, e.value.locationLong),
                        width: 34,
                        height: 34,
                        child: _StopMarker(
                            number: e.key + 1, isCurrent: isCurrent),
                      );
                    }),

                  // Driver marker (always)
                  if (_driverLatLng != null)
                    Marker(
                      point: _driverLatLng!,
                      width: 48,
                      height: 48,
                      child: const _DriverMarker(),
                    ),
                ],
              ),
            ],
          ),

          // ── Top status pill ───────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _StatusPill(
                  plateNumber:
                      _bus?['plateNumber']?.toString() ?? '—',
                  isOnline: _journeyActive,
                ),
              ),
            ),
          ),

          // ── Recenter button + bottom info card (stacked so button is always
          //    above the card regardless of card height) ──────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Recenter button pinned to right, 10px above the card
                Padding(
                  padding: const EdgeInsets.only(right: 14, bottom: 10),
                  child: _RecenterButton(onTap: _recenter, isDark: isDark),
                ),

                // Card with horizontal margins
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _DriverInfoCard(
                    loading: _loading,
                    error: _error,
                    bus: _bus,
                    route: _route,
                    childCount: _children.length,
                    journeyActive: _journeyActive,
                    tripType: _tripType,
                    nearestStop: nearestStop,
                    nearestStopNumber: nearestIdx + 1,
                    onStartJourney: _showStartJourneyDialog,
                    onEndJourney: _showEndJourneyDialog,
                    onRefresh: _loadData,
                    onShowChildren: _showAllChildrenSheet,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pill (top)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String plateNumber;
  final bool isOnline;

  const _StatusPill({required this.plateNumber, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final bg = isOnline
        ? const Color(0xFF21C260)
        : const Color(0xFF4A5568);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline
                ? IconsaxPlusBold.location_tick
                : IconsaxPlusLinear.slash,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '$plateNumber — ${isOnline ? 'online' : 'offline'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recenter button
// ─────────────────────────────────────────────────────────────────────────────

class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _RecenterButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1A2530) : Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Icon(
              IconsaxPlusLinear.refresh,
              color: Color(0xFF0D4896),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Driver location marker
// ─────────────────────────────────────────────────────────────────────────────

class _DriverMarker extends StatelessWidget {
  const _DriverMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF0D4896),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stop marker (shown only during active journey)
// ─────────────────────────────────────────────────────────────────────────────

class _StopMarker extends StatelessWidget {
  final int number;
  final bool isCurrent;

  const _StopMarker({required this.number, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final bg =
        isCurrent ? const Color(0xFFFF6B35) : const Color(0xFF0D4896);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
              color: bg.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text('$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom info card
// ─────────────────────────────────────────────────────────────────────────────

class _DriverInfoCard extends StatelessWidget {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? bus;
  final Map<String, dynamic>? route;
  final int childCount;
  final bool journeyActive;
  final String tripType;
  final StopModel? nearestStop;
  final int nearestStopNumber;
  final VoidCallback onStartJourney;
  final VoidCallback onEndJourney;
  final VoidCallback onRefresh;
  final VoidCallback onShowChildren;

  const _DriverInfoCard({
    required this.loading,
    required this.error,
    required this.bus,
    required this.route,
    required this.childCount,
    required this.journeyActive,
    required this.tripType,
    required this.nearestStop,
    required this.nearestStopNumber,
    required this.onStartJourney,
    required this.onEndJourney,
    required this.onRefresh,
    required this.onShowChildren,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        isDark ? const Color(0xFF1E2D40) : const Color(0xFFE8EFF9);

    final routeName = route?['name']?.toString() ??
        route?['routeName']?.toString() ??
        'Bus route';
    final routeId = route?['id'];
    final routeLabel =
        routeId != null ? 'Bus route $routeId' : 'Bus route';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else if (error != null) ...[
              _ErrorRow(
                  error: error!, onRetry: onRefresh, onSurface: onSurface),
              const SizedBox(height: 16),
            ] else ...[
              // ── Journey active state ───────────────────────────────────────
              if (journeyActive) ...[
                _JourneyActiveChip(tripType: tripType),
                const SizedBox(height: 12),
                if (nearestStop != null)
                  _CurrentStopRow(
                    stop: nearestStop!,
                    number: nearestStopNumber,
                    onSurface: onSurface,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),
                const SizedBox(height: 12),
              ] else ...[
                // ── Route info row ─────────────────────────────────────────
                _RouteRow(
                  routeName: routeName,
                  routeLabel: routeLabel,
                  onSurface: onSurface,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                // ── Children count row ─────────────────────────────────────
                _ChildrenRow(
                  childCount: childCount,
                  onSurface: onSurface,
                  isDark: isDark,
                  onTap: onShowChildren,
                ),
                const SizedBox(height: 14),
              ],

              // ── Action button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: journeyActive
                    ? ElevatedButton(
                        onPressed: onEndJourney,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'End Journey',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onStartJourney,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Start a new journey',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final String routeName;
  final String routeLabel;
  final Color onSurface;
  final Color borderColor;
  final bool isDark;

  const _RouteRow({
    required this.routeName,
    required this.routeLabel,
    required this.onSurface,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Blue circle icon
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF0D4896),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            IconsaxPlusBold.routing,
            color: Colors.white,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        // Route name + label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routeName,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                routeLabel,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Settings circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2D40)
                : const Color(0xFFF1F5FA),
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconsaxPlusLinear.setting_2,
            color: onSurface.withValues(alpha: 0.4),
            size: 17,
          ),
        ),
      ],
    );
  }
}

class _ChildrenRow extends StatelessWidget {
  final int childCount;
  final Color onSurface;
  final bool isDark;
  final VoidCallback onTap;

  const _ChildrenRow({
    required this.childCount,
    required this.onSurface,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileBg = isDark
        ? const Color(0xFF162035)
        : const Color(0xFFEEF3FD);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            IconsaxPlusLinear.people,
            color: Color(0xFF0D4896),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$childCount Total children',
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            IconsaxPlusLinear.setting_4,
            color: const Color(0xFF0D4896).withValues(alpha: 0.7),
            size: 18,
          ),
        ],
      ),
    ),
    );
  }
}

class _JourneyActiveChip extends StatelessWidget {
  final String tripType;

  const _JourneyActiveChip({required this.tripType});

  @override
  Widget build(BuildContext context) {
    final label = tripType == 'MORNING_PICKUP'
        ? 'Morning Pickup — GPS Sharing Active'
        : tripType == 'AFTERNOON_DROPOFF'
            ? 'Afternoon Drop-off — GPS Sharing Active'
            : 'Journey Active — GPS Sharing';

    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF21C260),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(IconsaxPlusBold.location_tick,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentStopRow extends StatelessWidget {
  final StopModel stop;
  final int number;
  final Color onSurface;
  final Color borderColor;
  final bool isDark;

  const _CurrentStopRow({
    required this.stop,
    required this.number,
    required this.onSurface,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tileBg =
        isDark ? const Color(0xFF1A2A3E) : const Color(0xFFF5F8FE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.locationName.isNotEmpty
                      ? stop.locationName
                      : 'Stop $number',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Current target stop',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            IconsaxPlusLinear.location,
            color: Color(0xFFFF6B35),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final Color onSurface;

  const _ErrorRow(
      {required this.error,
      required this.onRetry,
      required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(IconsaxPlusLinear.warning_2,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                  color: onSurface.withValues(alpha: 0.7), fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
