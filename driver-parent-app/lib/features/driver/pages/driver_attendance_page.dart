import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/attendance_service.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_attendance_form.dart';
import '../forms/driver_child_availability_form.dart';
import '../models/attendance_record_model.dart';

class DriverAttendancePage extends StatefulWidget {
  final bool isActive;

  const DriverAttendancePage({
    super.key,
    required this.isActive,
  });

  @override
  State<DriverAttendancePage> createState() => _DriverAttendancePageState();
}

class _DriverAttendancePageState extends State<DriverAttendancePage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();

  /// 'MORNING' or 'AFTERNOON' — auto-detected from current time on first load
  String _activeSession = _detectSession();

  /// childId -> record  for morning session
  Map<String, AttendanceRecordModel> _morningRecords = {};

  /// childId -> record  for afternoon session
  Map<String, AttendanceRecordModel> _afternoonRecords = {};

  /// childId of the currently selected student (detail view); null = list view
  String? _selectedChildId;

  /// "\$childId:\$session:\$action" keys that are in the middle of an API save
  final Set<String> _togglingKeys = {};

  /// Children absent for each session (populated alongside attendance load)
  Set<String> _absentMorningIds = {};
  Set<String> _absentAfternoonIds = {};

  /// Previous combined absent IDs — used to detect revocations
  Set<String> _previousAbsentAllIds = {};

  static String _detectSession() {
    return DateTime.now().hour < 12 ? 'MORNING' : 'AFTERNOON';
  }

  @override
  void didUpdateWidget(covariant DriverAttendancePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
      _loadAttendance();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
      _selectedChildId = null;
    }
  }

  Future<void> _loadAttendance() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Attendance and absent-children requests run concurrently.
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
      ]);

      if (!mounted) return;

      final morningRecs = results[0] as List<AttendanceRecordModel>;
      final afternoonRecs = results[1] as List<AttendanceRecordModel>;
      final absentMorningList =
          results[2] as List<Map<String, dynamic>>;
      final absentAfternoonList =
          results[3] as List<Map<String, dynamic>>;

      // Extract absent child IDs (backend may use 'childId' or 'id')
      final newAbsentMorning = <String>{};
      for (final c in absentMorningList) {
        final id =
            (c['childId'] ?? c['id'])?.toString().trim() ?? '';
        if (id.isNotEmpty) newAbsentMorning.add(id);
      }
      final newAbsentAfternoon = <String>{};
      for (final c in absentAfternoonList) {
        final id =
            (c['childId'] ?? c['id'])?.toString().trim() ?? '';
        if (id.isNotEmpty) newAbsentAfternoon.add(id);
      }

      // Detect revocations: was absent before, not absent now
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
      if (!mounted) return;
      setState(() => _loading = false);
      _refreshShownForm();
    }
  }

  void _notifyAbsenceRevocations(Set<String> revokedIds) {
    // Build name map from newly-loaded records
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

  List<AttendanceRecordModel> get _activeRecords {
    final map =
        _activeSession == 'MORNING' ? _morningRecords : _afternoonRecords;
    return map.values.toList();
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
    final h = MediaQuery.of(context).size.height * 0.70;

    final Widget child;

    if (_selectedChildId == null) {
      child = DriverAttendanceForm(
        loading: _loading,
        error: _error,
        activeSession: _activeSession,
        records: _activeRecords,
        togglingKeys: Set.unmodifiable(_togglingKeys),
        onSessionChanged: (session) {
          setState(() => _activeSession = session);
          _showCurrentForm();
        },
        onMarkAction: _handleToggle,
        onChildTap: (record) {
          setState(() => _selectedChildId = record.childId);
          _showCurrentForm();
        },
      );
    } else {
      final id = _selectedChildId!;
      child = DriverChildAvailabilityForm(
        childId: id,
        childName: (_morningRecords[id] ?? _afternoonRecords[id])?.childName ?? '',
        photoUrl: (_morningRecords[id] ?? _afternoonRecords[id])?.photoUrl,
        morningRecord: _morningRecords[id],
        afternoonRecord: _afternoonRecords[id],
        isAbsentMorning: _absentMorningIds.contains(id),
        isAbsentAfternoon: _absentAfternoonIds.contains(id),
        togglingKeys: Set.unmodifiable(_togglingKeys),
        onMarkAction: (session, action, newValue) {
          final record = session == 'MORNING'
              ? _morningRecords[id]
              : _afternoonRecords[id];
          if (record == null) return;
          _handleToggle(record, action, newValue);
        },
        onCancel: () {
          setState(() => _selectedChildId = null);
          _showCurrentForm();
        },
      );
    }

    _formCtrl.show(MobileFormShell(height: h, child: child));
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

    // Optimistic update
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
      // Preserve the absent flag — the API response does not include it
      setState(() => _applyRecord(updated.copyWith(isAbsent: record.isAbsent)));
    } catch (_) {
      // Revert on failure
      if (!mounted) return;
      setState(() => _applyRecord(record));
    } finally {
      if (!mounted) return;
      setState(() => _togglingKeys.remove(key));
      _refreshShownForm();
    }
  }

  void _applyRecord(AttendanceRecordModel record) {
    if (record.session == 'MORNING') {
      _morningRecords = Map.of(_morningRecords)..[record.childId] = record;
    } else {
      _afternoonRecords = Map.of(_afternoonRecords)..[record.childId] = record;
    }
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _selectedChildId = null;
    });
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
    final formHeight = MediaQuery.of(context).size.height * 0.70;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Attendance',
                    style: TextStyle(
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
                  child: _AttendanceDatePickerCard(
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

class _AttendanceDatePickerCard extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _AttendanceDatePickerCard({
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

    if (picked != null) {
      onChanged(picked);
    }
  }

  String _fmt(DateTime d) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
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