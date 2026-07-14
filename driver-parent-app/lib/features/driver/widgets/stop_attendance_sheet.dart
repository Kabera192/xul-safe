import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/attendance_service.dart';
import '../models/attendance_record_model.dart';
import '../models/child_model.dart';
import '../models/stop_model.dart';

enum _Mark { none, present, absent }

class StopAttendanceSheet extends StatefulWidget {
  /// The stop that triggered this popup (pre-selected tab).
  /// Null when shown as a pre-journey "who's on the bus?" check.
  final StopModel? currentStop;

  /// All stops on the route (for the tab bar).
  final List<StopModel> allStops;

  /// Children to display (pre-filtered by caller — e.g. non-absent).
  final List<ChildModel> allChildren;

  /// 'MORNING' or 'AFTERNOON' — determines which stopId field to use.
  final String session;

  /// Label for the primary action button.
  final String confirmLabel;

  /// When set, overrides the session-derived action ('BOARDED' or 'DROPPED_OFF').
  final String? forceAction;

  /// Called after submission with the set of child IDs marked as present.
  final void Function(Set<String> presentChildIds)? onConfirmed;

  const StopAttendanceSheet({
    super.key,
    required this.currentStop,
    required this.allStops,
    required this.allChildren,
    required this.session,
    this.confirmLabel = 'Confirm',
    this.forceAction,
    this.onConfirmed,
  });

  @override
  State<StopAttendanceSheet> createState() => _StopAttendanceSheetState();
}

class _StopAttendanceSheetState extends State<StopAttendanceSheet> {
  final _searchCtrl = TextEditingController();
  late int? _selectedStopId;
  final Map<String, _Mark> _marks = {};
  Map<String, AttendanceRecordModel> _existingRecords = {};
  bool _loading = false;
  bool _loadingRecords = true;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _selectedStopId = widget.currentStop?.id;
    _searchCtrl.addListener(() => setState(() {}));
    _loadExistingAttendance();
  }

  Future<void> _loadExistingAttendance() async {
    try {
      final records = await AttendanceService.getSessionAttendance(
        date: DateTime.now(),
        session: widget.session,
      );
      if (!mounted) return;
      final map = <String, AttendanceRecordModel>{};
      for (final r in records) {
        map[r.childId] = r;
      }
      // Pre-fill marks for children already confirmed
      final action = widget.forceAction ??
          (widget.session == 'MORNING' ? 'BOARDED' : 'DROPPED_OFF');
      for (final child in widget.allChildren) {
        final rec = map[child.id];
        if (rec == null) continue;
        // Absent takes priority — a child marked absent stays absent even if
        // they have a stale boarded/droppedOff flag from a prior confirm.
        if (rec.isAbsent) {
          _marks[child.id] = _Mark.absent;
        } else {
          final alreadyDone = action == 'BOARDED' ? rec.boarded : rec.droppedOff;
          if (alreadyDone) _marks[child.id] = _Mark.present;
        }
      }
      setState(() {
        _existingRecords = map;
        _loadingRecords = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRecords = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get _isMorning => widget.session == 'MORNING';

  int? _stopIdFor(ChildModel c) =>
      _isMorning ? c.pickupStopId : c.dropoffStopId;

  List<StopModel> get _stopsWithChildren {
    final ids = widget.allChildren.map(_stopIdFor).whereType<int>().toSet();
    return widget.allStops.where((s) => ids.contains(s.id)).toList();
  }

  List<ChildModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final stopId = _selectedStopId;
    return widget.allChildren.where((c) {
      final matchStop = stopId == null || _stopIdFor(c) == stopId;
      final matchSearch = q.isEmpty || c.fullName.toLowerCase().contains(q);
      return matchStop && matchSearch;
    }).toList();
  }

  bool get _canConfirm =>
      !_loading && _marks.values.any((m) => m != _Mark.none);

  // ── Actions ───────────────────────────────────────────────────────────────

  void _togglePresent(String childId) {
    setState(() {
      _marks[childId] =
          _marks[childId] == _Mark.present ? _Mark.none : _Mark.present;
    });
  }

  void _toggleAbsent(String childId) {
    setState(() {
      _marks[childId] =
          _marks[childId] == _Mark.absent ? _Mark.none : _Mark.absent;
    });
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);

    final action = widget.forceAction ??
        (_isMorning ? 'BOARDED' : 'DROPPED_OFF');
    final date = DateTime.now();
    int failures = 0;

    for (final child in widget.allChildren) {
      final mark = _marks[child.id];
      if (mark == _Mark.present) {
        try {
          await AttendanceService.markAttendance(
            childId: child.id,
            date: date,
            session: widget.session,
            action: action,
            confirmed: true,
          );
        } catch (_) {
          failures++;
        }
      } else if (mark == _Mark.absent) {
        try {
          await AttendanceService.markAttendance(
            childId: child.id,
            date: date,
            session: widget.session,
            action: 'ABSENT',
            confirmed: true,
          );
        } catch (_) {
          failures++;
        }
      }
    }

    final presentIds = widget.allChildren
        .where((c) => _marks[c.id] == _Mark.present)
        .map((c) => c.id)
        .toSet();
    widget.onConfirmed?.call(presentIds);

    if (!mounted) return;

    if (failures > 0) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failures == 1
                ? 'One mark could not be saved. Please try again.'
                : '$failures marks could not be saved. Please try again.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() { _loading = false; _success = true; });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _success
          ? _SuccessView(onDone: () => Navigator.of(context).pop(true))
          : _FormView(
              isDark: isDark,
              bg: bg,
              onSurface: onSurface,
              widget: widget,
              searchCtrl: _searchCtrl,
              selectedStopId: _selectedStopId,
              stopsWithChildren: _stopsWithChildren,
              filtered: _filtered,
              marks: _marks,
              existingRecords: _existingRecords,
              loadingRecords: _loadingRecords,
              loading: _loading,
              canConfirm: _canConfirm,
              onSelectStop: (id) => setState(() => _selectedStopId = id),
              onTogglePresent: _togglePresent,
              onToggleAbsent: _toggleAbsent,
              onConfirm: _confirm,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success view
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          const SizedBox(height: 12),

          // Checkmark illustration
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Image.asset(
                    'assests/backgrounds/mobile/success_checkmark.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                SvgPicture.asset(
                  'assests/backgrounds/mobile/edit_pen_shadow.svg',
                  height: 14,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Attendance Saved',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'The attendance has been successfully recorded for the selected children.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Got it',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main form view
// ─────────────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color onSurface;
  final StopAttendanceSheet widget;
  final TextEditingController searchCtrl;
  final int? selectedStopId;
  final List<StopModel> stopsWithChildren;
  final List<ChildModel> filtered;
  final Map<String, _Mark> marks;
  final Map<String, AttendanceRecordModel> existingRecords;
  final bool loadingRecords;
  final bool loading;
  final bool canConfirm;
  final void Function(int?) onSelectStop;
  final void Function(String) onTogglePresent;
  final void Function(String) onToggleAbsent;
  final VoidCallback onConfirm;

  const _FormView({
    required this.isDark,
    required this.bg,
    required this.onSurface,
    required this.widget,
    required this.searchCtrl,
    required this.selectedStopId,
    required this.stopsWithChildren,
    required this.filtered,
    required this.marks,
    required this.existingRecords,
    required this.loadingRecords,
    required this.loading,
    required this.canConfirm,
    required this.onSelectStop,
    required this.onTogglePresent,
    required this.onToggleAbsent,
    required this.onConfirm,
  });

  static const _blue = Color(0xFF0D4896);
  static const _green = Color(0xFF21C260);
  static const _red = Color(0xFFE53935);
  static const _grey = Color(0xFFCDD5DF);

  @override
  Widget build(BuildContext context) {
    final inputFill =
        isDark ? const Color(0xFF1A2530) : const Color(0xFFF5F8FE);
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 16),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title + close button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.currentStop == null
                      ? "Who's on the bus?"
                      : (widget.currentStop!.locationName.isNotEmpty
                          ? widget.currentStop!.locationName
                          : 'Bus Stop'),
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(IconsaxPlusLinear.search_normal_1,
                    color: onSurface.withValues(alpha: 0.4), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search a name',
                      hintStyle: TextStyle(
                          color: onSurface.withValues(alpha: 0.4),
                          fontSize: 13),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: onSurface, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Stop tabs (hidden in pre-journey mode)
        if (widget.currentStop != null && stopsWithChildren.isNotEmpty)
          SizedBox(
            height: 34,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _Tab(
                  label: 'All',
                  active: selectedStopId == null,
                  onTap: () => onSelectStop(null),
                  isDark: isDark,
                ),
                ...stopsWithChildren.map((s) => _Tab(
                      label: s.locationName.isNotEmpty
                          ? s.locationName
                          : 'Stop',
                      active: selectedStopId == s.id,
                      onTap: () => onSelectStop(s.id),
                      isDark: isDark,
                    )),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Child list — shrinks when the keyboard is open so nothing overflows
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery.of(context).size.height * 0.38 -
                    MediaQuery.of(context).viewInsets.bottom)
                .clamp(80.0, double.infinity),
          ),
          child: loadingRecords
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              : filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No children at this stop',
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: borderColor, height: 1),
                      itemBuilder: (_, i) {
                        final child = filtered[i];
                        final mark = marks[child.id] ?? _Mark.none;
                        final existing = existingRecords[child.id];
                        return _ChildRow(
                          child: child,
                          mark: mark,
                          existingRecord: existing,
                          session: widget.session,
                          forceAction: widget.forceAction,
                          onPresent: () => onTogglePresent(child.id),
                          onAbsent: () => onToggleAbsent(child.id),
                          onSurface: onSurface,
                          green: _green,
                          red: _red,
                          grey: _grey,
                          isDark: isDark,
                        );
                      },
                    ),
        ),

        const SizedBox(height: 12),

        // Confirm button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: canConfirm ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _blue.withValues(alpha: 0.35),
                disabledForegroundColor: Colors.white54,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      widget.confirmLabel,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab chip ──────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;

  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
    required this.isDark,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? _blue
        : (isDark ? const Color(0xFF1A2530) : const Color(0xFFF1F5FA));
    final fg = active
        ? Colors.white
        : (isDark ? const Color(0xFF93B5E8) : _blue.withValues(alpha: 0.75));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: fg, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Child row ─────────────────────────────────────────────────────────────────

class _ChildRow extends StatelessWidget {
  final ChildModel child;
  final _Mark mark;
  final AttendanceRecordModel? existingRecord;
  final String session;
  final String? forceAction;
  final VoidCallback onPresent;
  final VoidCallback onAbsent;
  final Color onSurface;
  final Color green;
  final Color red;
  final Color grey;
  final bool isDark;

  const _ChildRow({
    required this.child,
    required this.mark,
    required this.existingRecord,
    required this.session,
    required this.forceAction,
    required this.onPresent,
    required this.onAbsent,
    required this.onSurface,
    required this.green,
    required this.red,
    required this.grey,
    required this.isDark,
  });

  static const _blue = Color(0xFF0D4896);
  static const _orange = Color(0xFFE67E22);

  String get _resolvedAction =>
      forceAction ?? (session == 'MORNING' ? 'BOARDED' : 'DROPPED_OFF');

  @override
  Widget build(BuildContext context) {
    final isPresent = mark == _Mark.present;
    final isAbsent = mark == _Mark.absent;

    // Existing status badge — hidden once the driver actively selects a mark,
    // so switching from Absent → ✓ immediately clears the stale pill.
    Widget? statusBadge;
    final rec = existingRecord;
    if (rec != null && mark == _Mark.none) {
      if (rec.isAbsent) {
        statusBadge = _StatusBadge(
          label: 'Absent',
          color: _orange,
          icon: Icons.event_busy_rounded,
          isDark: isDark,
        );
      } else if (_resolvedAction == 'BOARDED' && rec.boarded) {
        statusBadge = _StatusBadge(
          label: 'Boarded',
          color: const Color(0xFF21C260),
          icon: Icons.check_circle_outline_rounded,
          isDark: isDark,
        );
      } else if (_resolvedAction == 'DROPPED_OFF' && rec.droppedOff) {
        statusBadge = _StatusBadge(
          label: 'Dropped off',
          color: _blue,
          icon: Icons.location_on_outlined,
          isDark: isDark,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFDCE6F5),
            backgroundImage:
                (child.photoUrl != null && child.photoUrl!.isNotEmpty)
                    ? NetworkImage(child.photoUrl!)
                    : null,
            child: (child.photoUrl == null || child.photoUrl!.isEmpty)
                ? Text(
                    child.fullName.isNotEmpty
                        ? child.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF0D4896),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Name + status badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  child.fullName,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (statusBadge != null) ...[
                  const SizedBox(height: 4),
                  statusBadge,
                ],
              ],
            ),
          ),

          // Absent (X) button
          GestureDetector(
            onTap: onAbsent,
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isAbsent ? red.withValues(alpha: 0.12) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAbsent ? red : grey,
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.close,
                  color: isAbsent ? red : grey, size: 18),
            ),
          ),

          // Present (checkmark) button
          GestureDetector(
            onTap: onPresent,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                    isPresent ? green.withValues(alpha: 0.12) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPresent ? green : grey,
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.check,
                  color: isPresent ? green : grey, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
