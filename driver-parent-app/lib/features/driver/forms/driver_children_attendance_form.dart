import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/attendance_record_model.dart';
import '../models/stop_model.dart';

class DriverChildrenAttendanceForm extends StatefulWidget {
  final bool loading;
  final String? error;
  final Map<String, AttendanceRecordModel> morningRecords;
  final Map<String, AttendanceRecordModel> afternoonRecords;
  final Set<String> absentMorningIds;
  final Set<String> absentAfternoonIds;
  final Set<String> togglingKeys;
  final void Function(AttendanceRecordModel record, String action, bool newValue)
      onMarkAction;

  final List<StopModel> stops;
  final Map<String, Set<String>> childStopMap;
  final Map<String, String> childStopNameMap;
  final String? selectedStopId;
  final void Function(String?) onStopSelected;

  const DriverChildrenAttendanceForm({
    super.key,
    required this.loading,
    required this.error,
    required this.morningRecords,
    required this.afternoonRecords,
    required this.absentMorningIds,
    required this.absentAfternoonIds,
    required this.togglingKeys,
    required this.onMarkAction,
    required this.stops,
    required this.childStopMap,
    required this.childStopNameMap,
    required this.selectedStopId,
    required this.onStopSelected,
  });

  @override
  State<DriverChildrenAttendanceForm> createState() =>
      _DriverChildrenAttendanceFormState();
}

class _DriverChildrenAttendanceFormState
    extends State<DriverChildrenAttendanceForm> {
  final _searchCtrl = TextEditingController();
  String? _expandedChildId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_ChildEntry> get _allChildren {
    final ids = <String>{
      ...widget.morningRecords.keys,
      ...widget.afternoonRecords.keys,
    };
    final list = ids.map((id) {
      final m = widget.morningRecords[id];
      final a = widget.afternoonRecords[id];
      return _ChildEntry(
        childId: id,
        childName: m?.childName ?? a?.childName ?? '',
        photoUrl: m?.photoUrl ?? a?.photoUrl,
        morningRecord: m,
        afternoonRecord: a,
        stopName: widget.childStopNameMap[id],
      );
    }).toList()
      ..sort((a, b) => a.childName.compareTo(b.childName));
    return list;
  }

  List<_ChildEntry> get _filtered {
    var list = _allChildren;

    if (widget.selectedStopId != null) {
      list = list
          .where((c) =>
              widget.childStopMap[c.childId]
                  ?.contains(widget.selectedStopId) ==
              true)
          .toList();
    }

    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((c) => c.childName.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final children = _filtered;
    final totalCount = children.length;
    final absentCount = children
        .where((c) =>
            widget.absentMorningIds.contains(c.childId) ||
            widget.absentAfternoonIds.contains(c.childId))
        .length;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchBox(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          if (widget.stops.isNotEmpty) ...[
            const SizedBox(height: 10),
            _StopFilterRow(
              stops: widget.stops,
              selectedStopId: widget.selectedStopId,
              onSelected: widget.onStopSelected,
            ),
          ],
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Text(
                  '$totalCount ${totalCount == 1 ? 'child' : 'children'}',
                  style: const TextStyle(
                    color: Color(0xFF0D4896),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (absentCount > 0) ...[
                  const SizedBox(width: 8),
                  const Text('·',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text(
                    '$absentCount absent',
                    style: const TextStyle(
                      color: Color(0xFFE67E22),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (widget.loading) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ] else if (widget.error != null) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Center(
                child: Text(
                  widget.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ] else if (children.isEmpty) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: const Center(
                child: Text(
                  'No children on this bus',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemCount: children.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final child = children[i];
                  final isExpanded = _expandedChildId == child.childId;
                  final isAbsentMorning =
                      widget.absentMorningIds.contains(child.childId);
                  final isAbsentAfternoon =
                      widget.absentAfternoonIds.contains(child.childId);

                  return _ChildRow(
                    entry: child,
                    isExpanded: isExpanded,
                    isAbsentMorning: isAbsentMorning,
                    isAbsentAfternoon: isAbsentAfternoon,
                    togglingKeys: widget.togglingKeys,
                    onToggle: () {
                      setState(() {
                        _expandedChildId =
                            isExpanded ? null : child.childId;
                      });
                    },
                    onMarkAction: widget.onMarkAction,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Data holder ───────────────────────────────────────────────────────────────

class _ChildEntry {
  final String childId;
  final String childName;
  final String? photoUrl;
  final String? stopName;
  final AttendanceRecordModel? morningRecord;
  final AttendanceRecordModel? afternoonRecord;

  const _ChildEntry({
    required this.childId,
    required this.childName,
    required this.photoUrl,
    required this.morningRecord,
    required this.afternoonRecord,
    this.stopName,
  });
}

// ── Child row (header + optional expanded attendance) ─────────────────────────

class _ChildRow extends StatelessWidget {
  final _ChildEntry entry;
  final bool isExpanded;
  final bool isAbsentMorning;
  final bool isAbsentAfternoon;
  final Set<String> togglingKeys;
  final VoidCallback onToggle;
  final void Function(AttendanceRecordModel, String, bool) onMarkAction;

  const _ChildRow({
    required this.entry,
    required this.isExpanded,
    required this.isAbsentMorning,
    required this.isAbsentAfternoon,
    required this.togglingKeys,
    required this.onToggle,
    required this.onMarkAction,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);
  static const orange = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final name = entry.childName.isEmpty ? 'Unnamed child' : entry.childName;
    final isAbsentAny = isAbsentMorning || isAbsentAfternoon;

    String absentLabel() {
      if (isAbsentMorning && isAbsentAfternoon) return 'Absent';
      if (isAbsentMorning) return 'AM';
      return 'PM';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2530) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isExpanded
              ? blue.withValues(alpha: 0.45)
              : (isDark ? const Color(0xFF2A3A50) : stroke),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    _Avatar(photoUrl: entry.photoUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (entry.stopName != null &&
                        entry.stopName!.isNotEmpty) ...[
                      Text(
                        entry.stopName!,
                        style: const TextStyle(
                          color: blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (isAbsentAny) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D2200)
                              : const Color(0xFFFFF3E6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: orange.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_busy_rounded,
                                color: orange, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              absentLabel(),
                              style: const TextStyle(
                                color: orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: onSurface.withValues(alpha: 0.45),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded attendance section ───────────────────────────────
            if (isExpanded) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? const Color(0xFF2A3A50) : stroke,
              ),
              _AttendanceExpanded(
                entry: entry,
                isAbsentMorning: isAbsentMorning,
                isAbsentAfternoon: isAbsentAfternoon,
                togglingKeys: togglingKeys,
                onMarkAction: onMarkAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Attendance expanded (morning | afternoon) ─────────────────────────────────

class _AttendanceExpanded extends StatelessWidget {
  final _ChildEntry entry;
  final bool isAbsentMorning;
  final bool isAbsentAfternoon;
  final Set<String> togglingKeys;
  final void Function(AttendanceRecordModel, String, bool) onMarkAction;

  const _AttendanceExpanded({
    required this.entry,
    required this.isAbsentMorning,
    required this.isAbsentAfternoon,
    required this.togglingKeys,
    required this.onMarkAction,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);
  static const orange = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0xFF2A3A50) : stroke;
    final id = entry.childId;
    final morningRec = entry.morningRecord;
    final afternoonRec = entry.afternoonRecord;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Morning (left) ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session label
                  Row(
                    children: [
                      Icon(
                        isAbsentMorning
                            ? Icons.event_busy_rounded
                            : Icons.wb_sunny_outlined,
                        size: 13,
                        color: isAbsentMorning
                            ? orange
                            : blue.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Morning',
                        style: TextStyle(
                          color: isAbsentMorning ? orange : blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Morning: only BOARDED step
                  if (isAbsentMorning)
                    Text(
                      'Absent — locked',
                      style: TextStyle(
                        color: orange.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    _ActionToggle(
                      label: 'Boarded',
                      active: morningRec?.boarded ?? false,
                      toggling: togglingKeys.contains('$id:MORNING:BOARDED'),
                      disabled: morningRec == null,
                      onConfirm: (morningRec == null || (morningRec.boarded))
                          ? null
                          : () => onMarkAction(morningRec, 'BOARDED', true),
                      onUnconfirm: (morningRec == null || !(morningRec.boarded))
                          ? null
                          : () => onMarkAction(morningRec, 'BOARDED', false),
                    ),
                ],
              ),
            ),
          ),

          // Vertical divider
          VerticalDivider(width: 1, thickness: 1, color: dividerColor),

          // ── Afternoon (right) ─────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session label
                  Row(
                    children: [
                      Icon(
                        isAbsentAfternoon
                            ? Icons.event_busy_rounded
                            : Icons.wb_twilight_outlined,
                        size: 13,
                        color: isAbsentAfternoon
                            ? orange
                            : blue.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Afternoon',
                        style: TextStyle(
                          color: isAbsentAfternoon ? orange : blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Afternoon: BOARDED + DROPPED_OFF
                  if (isAbsentAfternoon)
                    Text(
                      'Absent — locked',
                      style: TextStyle(
                        color: orange.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else ...[
                    _ActionToggle(
                      label: 'Boarded',
                      active: afternoonRec?.boarded ?? false,
                      toggling: togglingKeys.contains('$id:AFTERNOON:BOARDED'),
                      disabled: afternoonRec == null,
                      onConfirm: (afternoonRec == null || afternoonRec.boarded)
                          ? null
                          : () => onMarkAction(afternoonRec, 'BOARDED', true),
                      onUnconfirm: (afternoonRec == null || !afternoonRec.boarded)
                          ? null
                          : () => onMarkAction(afternoonRec, 'BOARDED', false),
                    ),
                    const SizedBox(height: 8),
                    _ActionToggle(
                      label: 'Dropped off',
                      active: afternoonRec?.droppedOff ?? false,
                      toggling: togglingKeys.contains('$id:AFTERNOON:DROPPED_OFF'),
                      disabled: afternoonRec == null,
                      onConfirm: (afternoonRec == null || afternoonRec.droppedOff)
                          ? null
                          : () => onMarkAction(afternoonRec, 'DROPPED_OFF', true),
                      onUnconfirm: (afternoonRec == null || !afternoonRec.droppedOff)
                          ? null
                          : () => onMarkAction(afternoonRec, 'DROPPED_OFF', false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action toggle — label + ✓ button + ✗ button ──────────────────────────────

class _ActionToggle extends StatelessWidget {
  final String label;
  final bool active;
  final bool toggling;
  final bool disabled;
  final VoidCallback? onConfirm;   // called to set active = true
  final VoidCallback? onUnconfirm; // called to set active = false

  const _ActionToggle({
    required this.label,
    required this.active,
    required this.toggling,
    required this.disabled,
    required this.onConfirm,
    required this.onUnconfirm,
  });

  static const green = Color(0xFF21C260);
  static const red   = Color(0xFFE74C3C);
  static const blue  = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: disabled
                  ? onSurface.withValues(alpha: 0.25)
                  : onSurface.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // ✓ Tick button
        if (toggling)
          SizedBox(
            width: 30,
            height: 30,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: active ? green : blue,
              ),
            ),
          )
        else ...[
          GestureDetector(
            onTap: disabled || active ? null : onConfirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: disabled
                    ? (isDark ? const Color(0xFF1E2830) : const Color(0xFFF4F4F4))
                    : active
                        ? green
                        : (isDark ? const Color(0xFF1E2830) : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: disabled
                      ? Colors.transparent
                      : active
                          ? green
                          : green.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 15,
                color: disabled
                    ? onSurface.withValues(alpha: 0.18)
                    : active
                        ? Colors.white
                        : green.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // ✗ X button
          GestureDetector(
            onTap: disabled || !active ? null : onUnconfirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: disabled
                    ? (isDark ? const Color(0xFF1E2830) : const Color(0xFFF4F4F4))
                    : !active
                        ? red
                        : (isDark ? const Color(0xFF1E2830) : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: disabled
                      ? Colors.transparent
                      : !active
                          ? red
                          : red.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 15,
                color: disabled
                    ? onSurface.withValues(alpha: 0.18)
                    : !active
                        ? Colors.white
                        : red.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Stop filter chips ─────────────────────────────────────────────────────────

class _StopFilterRow extends StatelessWidget {
  final List<StopModel> stops;
  final String? selectedStopId;
  final void Function(String?) onSelected;

  const _StopFilterRow({
    required this.stops,
    required this.selectedStopId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _StopChip(
            label: 'All',
            selected: selectedStopId == null,
            onTap: () => onSelected(null),
          ),
          ...stops.map(
            (stop) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _StopChip(
                label: stop.locationName,
                selected: selectedStopId == stop.id,
                onTap: () => onSelected(
                  selectedStopId == stop.id ? null : stop.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StopChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? blue
              : (isDark ? const Color(0xFF1A2530) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? blue
                : (isDark ? const Color(0xFF2A3A50) : stroke),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : blue),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Search box ────────────────────────────────────────────────────────────────

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2530) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A50) : stroke,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(IconsaxPlusLinear.search_normal_1,
              color: blue, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search a child',
                hintStyle: TextStyle(
                  color: onSurface.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;

  const _Avatar({required this.photoUrl});

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: blue, shape: BoxShape.circle),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white, size: 22),
      ),
    );
  }
}
