import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/attendance_service.dart';
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

  /// Called after submission with the set of child IDs marked as present.
  final void Function(Set<String> presentChildIds)? onConfirmed;

  const StopAttendanceSheet({
    super.key,
    required this.currentStop,
    required this.allStops,
    required this.allChildren,
    required this.session,
    this.confirmLabel = 'Confirm',
    this.onConfirmed,
  });

  @override
  State<StopAttendanceSheet> createState() => _StopAttendanceSheetState();
}

class _StopAttendanceSheetState extends State<StopAttendanceSheet> {
  static const _blue = Color(0xFF0D4896);
  static const _green = Color(0xFF21C260);
  static const _red = Color(0xFFE53935);
  static const _grey = Color(0xFFCDD5DF);

  final _searchCtrl = TextEditingController();
  late int? _selectedStopId; // null = All tab
  final Map<String, _Mark> _marks = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedStopId = widget.currentStop?.id;
    _searchCtrl.addListener(() => setState(() {}));
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

  /// Stops that actually have children assigned (for tabs).
  List<StopModel> get _stopsWithChildren {
    final ids = widget.allChildren.map(_stopIdFor).whereType<int>().toSet();
    return widget.allStops.where((s) => ids.contains(s.id)).toList();
  }

  List<ChildModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final stopId = _selectedStopId;
    return widget.allChildren.where((c) {
      final matchStop = stopId == null || _stopIdFor(c) == stopId;
      final matchSearch =
          q.isEmpty || c.fullName.toLowerCase().contains(q);
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

    final action = _isMorning ? 'BOARDED' : 'DROPPED_OFF';
    final date = DateTime.now();

    // Submit all "present" marks to backend
    for (final child in widget.allChildren) {
      if (_marks[child.id] == _Mark.present) {
        try {
          await AttendanceService.markAttendance(
            childId: child.id,
            date: date,
            session: widget.session,
            action: action,
            confirmed: true,
          );
        } catch (_) {
          // Individual failure: continue marking others, handle in full list
        }
      }
    }

    // Notify caller which children were marked as present
    final presentIds = widget.allChildren
        .where((c) => _marks[c.id] == _Mark.present)
        .map((c) => c.id)
        .toSet();
    widget.onConfirmed?.call(presentIds);

    if (mounted) Navigator.of(context).pop(true);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill = isDark ? const Color(0xFF1A2530) : const Color(0xFFF5F8FE);
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    final stopsWithChildren = _stopsWithChildren;
    final filtered = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────────
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title + close button ─────────────────────────────────────────────
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

          // ── Search bar ───────────────────────────────────────────────────────
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
                      controller: _searchCtrl,
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

          // ── Stop tabs (hidden in pre-journey "all students" mode) ────────────
          if (widget.currentStop != null && stopsWithChildren.isNotEmpty)
            SizedBox(
              height: 34,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _Tab(
                    label: 'All',
                    active: _selectedStopId == null,
                    onTap: () => setState(() => _selectedStopId = null),
                    isDark: isDark,
                  ),
                  ...stopsWithChildren.map((s) => _Tab(
                        label: s.locationName.isNotEmpty
                            ? s.locationName
                            : 'Stop',
                        active: _selectedStopId == s.id,
                        onTap: () =>
                            setState(() => _selectedStopId = s.id),
                        isDark: isDark,
                      )),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ── Child list ───────────────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.38,
            ),
            child: filtered.isEmpty
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
                        Divider(color: borderColor, height: 1, thickness: 1),
                    itemBuilder: (_, i) {
                      final child = filtered[i];
                      final mark = _marks[child.id] ?? _Mark.none;
                      return _ChildRow(
                        child: child,
                        mark: mark,
                        onPresent: () => _togglePresent(child.id),
                        onAbsent: () => _toggleAbsent(child.id),
                        onSurface: onSurface,
                        green: _green,
                        red: _red,
                        grey: _grey,
                      );
                    },
                  ),
          ),

          const SizedBox(height: 12),

          // ── Confirm button ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canConfirm ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _blue.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white54,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.confirmLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
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
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Child row ─────────────────────────────────────────────────────────────────

class _ChildRow extends StatelessWidget {
  final ChildModel child;
  final _Mark mark;
  final VoidCallback onPresent;
  final VoidCallback onAbsent;
  final Color onSurface;
  final Color green;
  final Color red;
  final Color grey;

  const _ChildRow({
    required this.child,
    required this.mark,
    required this.onPresent,
    required this.onAbsent,
    required this.onSurface,
    required this.green,
    required this.red,
    required this.grey,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = mark == _Mark.present;
    final isAbsent = mark == _Mark.absent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFDCE6F5),
            backgroundImage: (child.photoUrl != null &&
                    child.photoUrl!.isNotEmpty)
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

          // Name
          Expanded(
            child: Text(
              child.fullName,
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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
                color: isAbsent
                    ? red.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAbsent ? red : grey,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.close,
                color: isAbsent ? red : grey,
                size: 18,
              ),
            ),
          ),

          // Present (checkmark) button
          GestureDetector(
            onTap: onPresent,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isPresent
                    ? green.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPresent ? green : grey,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check,
                color: isPresent ? green : grey,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
