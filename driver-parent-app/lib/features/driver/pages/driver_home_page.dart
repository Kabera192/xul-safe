import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/attendance_service.dart';
import '../../../services/child_service.dart';
import '../models/attendance_record_model.dart';
import '../../../services/profile_service.dart';
import '../../../services/transport_service.dart';
import '../models/child_model.dart';
import '../models/driver_profile_model.dart';
import '../models/stop_model.dart';
import '../pages/driver_bus_route_page.dart';
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
  final Set<String> _confirmedStopIds = {};
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
    _seedLastKnownLocation();
    _loadData();
  }

  Future<void> _seedLastKnownLocation() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null && mounted && _driverLatLng == null) {
        setState(() => _driverLatLng = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
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

  Future<void> _showStartJourneyDialog() async {
    if (_children.isEmpty) {
      _showSnack(AppLocalizations.of(context).noChildrenOnBus);
      return;
    }

    final tripType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _StartJourneySheet(
        suggestedType: DateTime.now().hour < 12
            ? 'MORNING_PICKUP'
            : 'AFTERNOON_DROPOFF',
      ),
    );
    if (tripType == null || !mounted) return;
    _beginJourneyFlow(tripType);
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
          confirmLabel: AppLocalizations.of(context).confirmAndStartJourney,
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
      _showSnack(AppLocalizations.of(context).waitingForGps);
      return;
    }
    if (profile == null || bus == null || route == null) {
      _showSnack(AppLocalizations.of(context).busDataNotLoaded);
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
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context).couldNotStartJourney(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _showEndJourneyDialog() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _EndJourneySheet(),
    );
    if (confirmed == true && mounted) _endJourney();
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
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context).couldNotEndJourney(e.toString().replaceFirst('Exception: ', '')));
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

  Future<void> _showAllChildrenSheet() async {
    if (_children.isEmpty) {
      _showSnack(AppLocalizations.of(context).noChildrenOnBusYet);
      return;
    }

    // Step 1: let the driver pick morning or afternoon
    final session = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SessionPickerSheet(),
    );
    if (session == null || !mounted) return;

    // Step 2: open attendance sheet — always BOARDED regardless of session
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StopAttendanceSheet(
        currentStop: null,
        allStops: _stops,
        allChildren: _children,
        session: session,
        forceAction: 'BOARDED',
        confirmLabel: AppLocalizations.of(context).markAsOnboarded,
      ),
    );
  }

  void _openBusRouteSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverBusRoutePage()),
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
                    onRouteSettings: _openBusRouteSettings,
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
            '$plateNumber — ${isOnline ? AppLocalizations.of(context).online : AppLocalizations.of(context).offline}',
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
  final VoidCallback onRouteSettings;

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
    required this.onRouteSettings,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        isDark ? const Color(0xFF1E2D40) : const Color(0xFFE8EFF9);

    final l10n = AppLocalizations.of(context);
    final routeName = route?['name']?.toString() ??
        route?['routeName']?.toString() ??
        l10n.busRoute;
    final routeId = route?['id'];
    final routeLabel =
        routeId != null ? '${l10n.busRoute} $routeId' : l10n.busRoute;

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
                  onSettingsTap: onRouteSettings,
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
                        child: Text(
                          l10n.endJourney,
                          style: const TextStyle(
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
                        child: Text(
                          l10n.startNewJourney,
                          style: const TextStyle(
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
  final VoidCallback onSettingsTap;

  const _RouteRow({
    required this.routeName,
    required this.routeLabel,
    required this.onSurface,
    required this.borderColor,
    required this.isDark,
    required this.onSettingsTap,
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
        GestureDetector(
          onTap: onSettingsTap,
          child: Container(
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
              AppLocalizations.of(context).totalChildren(childCount),
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
    final l10n = AppLocalizations.of(context);
    final label = tripType == 'MORNING_PICKUP'
        ? l10n.morningPickupActive
        : tripType == 'AFTERNOON_DROPOFF'
            ? l10n.afternoonDropoffActive
            : l10n.journeyActive;

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
                Text(
                  AppLocalizations.of(context).currentTargetStop,
                  style: const TextStyle(
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
            child: Text(AppLocalizations.of(context).retry,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Start journey bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StartJourneySheet extends StatelessWidget {
  final String suggestedType;

  const _StartJourneySheet({required this.suggestedType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        isDark ? const Color(0xFF1E2D40) : const Color(0xFFE8EFF9);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            l10n.startJourneySheetTitle,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.startJourneySheetSubtitle,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          _StartJourneyOption(
            icon: IconsaxPlusBold.sun_1,
            iconColor: const Color(0xFFFF9500),
            iconBg: const Color(0xFFFFF3E0),
            title: l10n.morningPickup,
            subtitle: l10n.morningPickupDesc,
            borderColor: borderColor,
            isDark: isDark,
            isSuggested: suggestedType == 'MORNING_PICKUP',
            onTap: () => Navigator.of(context).pop('MORNING_PICKUP'),
          ),
          const SizedBox(height: 12),

          _StartJourneyOption(
            icon: IconsaxPlusBold.moon,
            iconColor: const Color(0xFF0D4896),
            iconBg: const Color(0xFFEEF3FD),
            title: l10n.afternoonDropoff,
            subtitle: l10n.afternoonDropoffDesc,
            borderColor: borderColor,
            isDark: isDark,
            isSuggested: suggestedType == 'AFTERNOON_DROPOFF',
            onTap: () => Navigator.of(context).pop('AFTERNOON_DROPOFF'),
          ),
        ],
      ),
    );
  }
}

class _StartJourneyOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Color borderColor;
  final bool isDark;
  final bool isSuggested;
  final VoidCallback onTap;

  const _StartJourneyOption({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.isDark,
    required this.isSuggested,
    required this.onTap,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tileBg = isDark ? const Color(0xFF1A2A3E) : Colors.white;
    final activeBorder = isSuggested ? _blue : borderColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activeBorder,
            width: isSuggested ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSuggested) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context).suggested,
                            style: const TextStyle(
                              color: _blue,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: onSurface.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// End journey bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EndJourneySheet extends StatelessWidget {
  const _EndJourneySheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Warning icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconsaxPlusBold.warning_2,
              color: Colors.red.shade600,
              size: 26,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context).endJourneyConfirmTitle,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).endJourneyConfirmBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: onSurface,
                      side: BorderSide(
                          color: onSurface.withValues(alpha: 0.18)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      AppLocalizations.of(context).endJourney,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session picker sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SessionPickerSheet extends StatelessWidget {
  const _SessionPickerSheet();

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        isDark ? const Color(0xFF1E2D40) : const Color(0xFFE8EFF9);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            AppLocalizations.of(context).markAttendanceFor,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).whichSession,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Morning option
          _SessionOption(
            icon: IconsaxPlusBold.sun_1,
            iconColor: const Color(0xFFFF9500),
            iconBg: const Color(0xFFFFF3E0),
            title: AppLocalizations.of(context).morning,
            subtitle: AppLocalizations.of(context).morningSessionDesc,
            borderColor: borderColor,
            isDark: isDark,
            onTap: () => Navigator.of(context).pop('MORNING'),
          ),
          const SizedBox(height: 12),

          // Afternoon option
          _SessionOption(
            icon: IconsaxPlusBold.moon,
            iconColor: _blue,
            iconBg: const Color(0xFFEEF3FD),
            title: AppLocalizations.of(context).afternoon,
            subtitle: AppLocalizations.of(context).afternoonSessionDesc,
            borderColor: borderColor,
            isDark: isDark,
            onTap: () => Navigator.of(context).pop('AFTERNOON'),
          ),
        ],
      ),
    );
  }
}

class _SessionOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SessionOption({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tileBg = isDark ? const Color(0xFF1A2A3E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: onSurface.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
