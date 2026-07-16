import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/attendance_service.dart';
import '../../../services/child_service.dart';
import '../../../services/transport_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_children_attendance_form.dart';
import '../models/attendance_record_model.dart';
import '../models/stop_model.dart';

class DriverChildrenAttendancePage extends StatefulWidget {
  final bool isActive;

  const DriverChildrenAttendancePage({
    super.key,
    required this.isActive,
  });

  @override
  State<DriverChildrenAttendancePage> createState() =>
      _DriverChildrenAttendancePageState();
}

class _DriverChildrenAttendancePageState
    extends State<DriverChildrenAttendancePage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();

  Map<String, AttendanceRecordModel> _morningRecords = {};
  Map<String, AttendanceRecordModel> _afternoonRecords = {};

  Set<String> _absentMorningIds = {};
  Set<String> _absentAfternoonIds = {};
  Set<String> _previousAbsentAllIds = {};

  final Set<String> _togglingKeys = {};

  List<StopModel> _stops = [];
  Map<String, Set<int>> _childStopMap = {};
  Map<String, String> _childStopNameMap = {};
  int _totalChildCount = 0;
  int? _selectedStopId;

  @override
  void didUpdateWidget(covariant DriverChildrenAttendancePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
      _loadAttendance();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
    }
  }

  Future<void> _loadAttendance() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        AttendanceService.getSessionAttendance(
            date: _selectedDate, session: 'MORNING'),
        AttendanceService.getSessionAttendance(
            date: _selectedDate, session: 'AFTERNOON'),
        ChildService.getAbsentChildren(
                date: _selectedDate, journey: 'MORNING')
            .onError((_, __) => <Map<String, dynamic>>[]),
        ChildService.getAbsentChildren(
                date: _selectedDate, journey: 'AFTERNOON')
            .onError((_, __) => <Map<String, dynamic>>[]),
        TransportService.getMyStops()
            .onError((_, __) => <Map<String, dynamic>>[]),
        ChildService.getMyBusChildren()
            .onError((_, __) => <Map<String, dynamic>>[]),
      ]);

      if (!mounted) return;

      final morningRecs = results[0] as List<AttendanceRecordModel>;
      final afternoonRecs = results[1] as List<AttendanceRecordModel>;
      final absentMorningList = results[2] as List<Map<String, dynamic>>;
      final absentAfternoonList = results[3] as List<Map<String, dynamic>>;
      final rawStops = results[4] as List<Map<String, dynamic>>;
      final rawChildren = results[5] as List<Map<String, dynamic>>;

      final stops = rawStops
          .map((s) => StopModel.fromApiResponse(s))
          .where((s) => s.locationName.isNotEmpty)
          .toList();

      final childStopMap = <String, Set<int>>{};
      final childStopNameMap = <String, String>{};
      for (final c in rawChildren) {
        final childId = (c['id'] ?? '').toString();
        if (childId.isEmpty || childId == '0') continue;
        final ids = <int>{};
        final pickup = c['pickupStopId'];
        final dropoff = c['dropoffStopId'];
        if (pickup != null) {
          final v = int.tryParse(pickup.toString()) ?? 0;
          if (v > 0) ids.add(v);
        }
        if (dropoff != null) {
          final v = int.tryParse(dropoff.toString()) ?? 0;
          if (v > 0) ids.add(v);
        }
        if (ids.isNotEmpty) childStopMap[childId] = ids;
        final stopName = (c['pickupStopName'] ?? c['dropoffStopName'])?.toString();
        if (stopName != null && stopName.isNotEmpty) {
          childStopNameMap[childId] = stopName;
        }
      }

      final newAbsentMorning = <String>{};
      for (final c in absentMorningList) {
        final id = (c['childId'] ?? c['id'])?.toString().trim() ?? '';
        if (id.isNotEmpty) newAbsentMorning.add(id);
      }
      final newAbsentAfternoon = <String>{};
      for (final c in absentAfternoonList) {
        final id = (c['childId'] ?? c['id'])?.toString().trim() ?? '';
        if (id.isNotEmpty) newAbsentAfternoon.add(id);
      }

      final newAbsentAll = {...newAbsentMorning, ...newAbsentAfternoon};
      final revoked = _previousAbsentAllIds.difference(newAbsentAll);

      setState(() {
        _absentMorningIds = newAbsentMorning;
        _absentAfternoonIds = newAbsentAfternoon;
        _previousAbsentAllIds = newAbsentAll;
        _morningRecords = {
          for (final r in morningRecs)
            r.childId: newAbsentMorning.contains(r.childId)
                ? r.copyWith(isAbsent: true)
                : r,
        };
        _afternoonRecords = {
          for (final r in afternoonRecs)
            r.childId: newAbsentAfternoon.contains(r.childId)
                ? r.copyWith(isAbsent: true)
                : r,
        };
        _stops = stops;
        _childStopMap = childStopMap;
        _childStopNameMap = childStopNameMap;
        _totalChildCount = rawChildren.length;
      });

      if (revoked.isNotEmpty && mounted) {
        _notifyAbsenceRevocations(revoked);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _refreshShownForm();
      }
    }
  }

  void _notifyAbsenceRevocations(Set<String> revokedIds) {
    final nameMap = {
      for (final r in [
        ..._morningRecords.values,
        ..._afternoonRecords.values,
      ])
        r.childId: r.childName,
    };
    for (final id in revokedIds) {
      final name = nameMap[id];
      if (name == null || name.isEmpty) continue;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name is now available for pickup'),
          backgroundColor: const Color(0xFF21C260),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));
      if (!mounted || !widget.isActive) return;
      _showCurrentForm();
    });
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled || !widget.isActive) return;
    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.78;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: DriverChildrenAttendanceForm(
          loading: _loading,
          error: _error,
          morningRecords: Map.unmodifiable(_morningRecords),
          afternoonRecords: Map.unmodifiable(_afternoonRecords),
          absentMorningIds: Set.unmodifiable(_absentMorningIds),
          absentAfternoonIds: Set.unmodifiable(_absentAfternoonIds),
          togglingKeys: Set.unmodifiable(_togglingKeys),
          onMarkAction: _handleToggle,
          stops: _stops,
          childStopMap: _childStopMap,
          childStopNameMap: _childStopNameMap,
          selectedStopId: _selectedStopId,
          onStopSelected: _onStopSelected,
        ),
      ),
    );
  }

  Future<void> _handleToggle(
      AttendanceRecordModel record, String action, bool newValue) async {
    final key = '${record.childId}:${record.session}:$action';
    if (_togglingKeys.contains(key)) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final optimistic = action == 'BOARDED'
        ? record.copyWith(
            boarded: newValue, boardedAt: newValue ? now : null)
        : record.copyWith(
            droppedOff: newValue, droppedOffAt: newValue ? now : null);

    setState(() {
      _togglingKeys.add(key);
      _applyRecord(optimistic);
    });
    _refreshShownForm();

    try {
      final updated = await AttendanceService.markAttendance(
        childId: record.childId,
        date: _selectedDate,
        session: record.session,
        action: action,
        confirmed: newValue,
      );

      if (!mounted) return;
      setState(
          () => _applyRecord(updated.copyWith(isAbsent: record.isAbsent)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _applyRecord(record));
    } finally {
      if (mounted) {
        setState(() => _togglingKeys.remove(key));
        _refreshShownForm();
      }
    }
  }

  void _applyRecord(AttendanceRecordModel record) {
    if (record.session == 'MORNING') {
      _morningRecords = Map.of(_morningRecords)..[record.childId] = record;
    } else {
      _afternoonRecords =
          Map.of(_afternoonRecords)..[record.childId] = record;
    }
  }

  void _onStopSelected(int? stopId) {
    setState(() => _selectedStopId = stopId);
    _refreshShownForm();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    _showCurrentForm();
    _loadAttendance();
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formHeight = MediaQuery.of(context).size.height * 0.78;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _totalChildCount > 0
                        ? 'Children($_totalChildCount)'
                        : 'Children',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: _DatePickerCard(
                    selected: _selectedDate,
                    onChanged: _onDateChanged,
                  ),
                ),
              ),
              MobileAnimatedFormHost(
                controller: _formCtrl,
                height: formHeight,
                duration: const Duration(milliseconds: 400),
                respectKeyboard: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date picker card ──────────────────────────────────────────────────────────

class _DatePickerCard extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerCard({
    required this.selected,
    required this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) onChanged(picked);
  }

  String _fmt(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dayName = days[d.weekday - 1];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = months[d.month - 1];
    return '$dayName / $dd-$mm-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                IconsaxPlusLinear.calendar_search,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                _fmt(selected),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
