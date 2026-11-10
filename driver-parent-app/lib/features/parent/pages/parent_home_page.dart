import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/session/session_storage.dart';
import '../../../core/utils/photo_url.dart';
import '../../../services/child_service.dart';
import '../../../services/tracking_service.dart';
import '../../../services/transport_service.dart';
import '../../../services/incident_service.dart';
import '../models/child_model.dart';
import 'parent_incidents_page.dart';
import '../../../widgets/mobile_location_gate.dart';
import '../../../core/l10n/app_localizations.dart';

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
  List<ChildModel> _children = [];
  Map<String, dynamic>? _tracking;

  // Dialog guard
  bool _arrivedDialogShown = false;
  String? _lastTrackingId;

  Timer? _pollTimer;
  Timer? _incidentPollTimer;

  // Parent incident state
  bool _hasActiveIncident = false;

  // Bottom panel — the kids-chip row can be collapsed by the user, and the
  // recenter/incident buttons float just above whatever height the panel
  // ends up at (it varies with children/conductor/plate content), instead
  // of a fixed offset that the panel could grow tall enough to cover.
  bool _childrenRowExpanded = true;
  final GlobalKey _bottomPanelKey = GlobalKey();
  double _panelHeight = 190;

  void _measurePanelHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final height = _bottomPanelKey.currentContext?.size?.height;
      if (height != null && (height - _panelHeight).abs() > 1) {
        setState(() => _panelHeight = height);
      }
    });
  }


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
    final l10n = AppLocalizations.of(context);
    final asNum = int.tryParse(eta.trim());
    if (asNum != null) return l10n.minToReachHome(asNum);
    return l10n.etaToReachHome(eta);
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

  // Only the children riding the bus this panel is tracking — a parent
  // with children on different buses shouldn't see all of them here.
  List<ChildModel> get _busChildren {
    final rawBusId = _bus?['id'];
    if (rawBusId == null) return const [];
    final busId =
        rawBusId is int ? rawBusId : int.tryParse(rawBusId.toString());
    if (busId == null) return const [];
    return _children.where((c) => c.busId == busId).toList();
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
      _loadIncidentState(),
    ]);

    if (!mounted) return;

    _startPolling();
    _startIncidentPolling();
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
      final children = await ChildService.getMyChildren();
      if (!mounted) return;
      setState(() {
        _children = children;
        if (children.isNotEmpty) {
          _activeChildId = children.first.id;
        }
      });
    } catch (_) {}
  }

  void _startIncidentPolling() {
    _incidentPollTimer?.cancel();

    _incidentPollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadIncidentState(),
    );
  }

  Future<void> _openIncidents() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ParentIncidentsPage(),
      ),
    );

    if (!mounted) return;

    // An incident may have been resolved while the parent
    // was viewing the incident pages.
    await _loadIncidentState();
  }

  Future<void> _loadIncidentState() async {
    try {
      final incidents =
          await IncidentService.getParentIncidents();

      if (!mounted) return;

      final hasActive =
          incidents.any((incident) => incident.isActive);

      if (_hasActiveIncident == hasActive) {
        return;
      }

      setState(() {
        _hasActiveIncident = hasActive;
      });
    } catch (_) {
      /*
      * Keep the previous visual state if the incident
      * status cannot currently be refreshed.
      */
    }
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
    _incidentPollTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final center = _busLatLng ?? _parentLatLng ?? _kigali;

    final content = MobileLocationGate(
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
              bottom: _panelHeight + 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.white,
                    elevation: 4,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: _recenter,
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Center(
                          child: Icon(
                            IconsaxPlusLinear.gps,
                            color: _blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  _ParentIncidentButton(
                    hasActiveIncident: _hasActiveIncident,
                    onTap: _openIncidents,
                  ),
                ],
              ),
            ),

            // ── Bottom conductor panel ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomPanel(
                key: _bottomPanelKey,
                conductor: _conductor,
                bus: _bus,
                journeyActive: _journeyActive,
                children: _busChildren,
                childrenRowExpanded: _childrenRowExpanded,
                onToggleChildrenRow: () => setState(
                  () => _childrenRowExpanded = !_childrenRowExpanded,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    _measurePanelHeight();

    return content;
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
    final l10n = AppLocalizations.of(context);
    final color = arrived ? const Color(0xFF21C260) : const Color(0xFF0D4896);
    final icon = arrived
        ? IconsaxPlusBold.shield_tick
        : IconsaxPlusLinear.clock;
    final label = arrived
        ? l10n.busHasArrived
        : (etaText.isNotEmpty ? etaText : l10n.busOnItsWay);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentIncidentButton extends StatelessWidget {
  final bool hasActiveIncident;
  final VoidCallback onTap;

  const _ParentIncidentButton({
    required this.hasActiveIncident,
    required this.onTap,
  });

  static const _activeRed = Color(0xFFFC4A4A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          hasActiveIncident ? _activeRed : Colors.white,
      elevation: hasActiveIncident ? 7 : 4,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Icon(
              IconsaxPlusBold.warning_2,
              color: hasActiveIncident
                  ? Colors.white
                  : _activeRed,
              size: 21,
            ),
          ),
        ),
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
  final List<ChildModel> children;
  final bool childrenRowExpanded;
  final VoidCallback onToggleChildrenRow;

  const _BottomPanel({
    super.key,
    required this.conductor,
    required this.bus,
    required this.journeyActive,
    required this.children,
    required this.childrenRowExpanded,
    required this.onToggleChildrenRow,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2D40) : const Color(0xFFDCE6F5);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final conductorName =
        conductor?['fullName']?.toString() ?? l10n.noConductorAssigned;
    final conductorPhone = conductor?['phoneNumber']?.toString() ?? '—';
    final conductorPhoto = resolvePhotoProvider(
      conductor?['photoUrl']?.toString(),
    );
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
          // Drag handle — tap or swipe to collapse/expand the kids row
          // below, so it can be hidden instead of just sitting there.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: children.isEmpty ? null : onToggleChildrenRow,
            onVerticalDragEnd: children.isEmpty
                ? null
                : (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity > 100 && childrenRowExpanded) {
                      onToggleChildrenRow();
                    } else if (velocity < -100 && !childrenRowExpanded) {
                      onToggleChildrenRow();
                    }
                  },
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Children row — whose bus this is
          if (children.isNotEmpty)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: !childrenRowExpanded
                  ? const SizedBox(width: double.infinity, height: 0)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: children.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) =>
                                _ChildChip(child: children[i]),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
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
                  backgroundImage: conductorPhoto,
                  child: conductorPhoto == null
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
                        l10n.yourConductor,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        conductorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

// ── Child chip (name + photo) ─────────────────────────────────────────────────

class _ChildChip extends StatefulWidget {
  final ChildModel child;

  const _ChildChip({required this.child});

  @override
  State<_ChildChip> createState() => _ChildChipState();
}

class _ChildChipState extends State<_ChildChip> {
  static const _blue = Color(0xFF0D4896);

  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final childId = widget.child.id;
    if (childId.isEmpty) return;
    try {
      final bytes = await ChildService.getChildPhotoBytes(childId);
      if (mounted) setState(() => _photoBytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFDCE6F5),
            backgroundImage: _photoBytes != null
                ? MemoryImage(_photoBytes!)
                : null,
            child: _photoBytes == null
                ? const Icon(IconsaxPlusLinear.user, color: _blue, size: 22)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            widget.child.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.75),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
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
    final l10n = AppLocalizations.of(context);
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
            Text(
              l10n.busReachedStop,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.busReachedStopBody,
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
                child: Text(
                  l10n.gotIt,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
