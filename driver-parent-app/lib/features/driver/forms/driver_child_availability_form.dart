import 'package:flutter/material.dart';

import '../models/attendance_record_model.dart';

/// Detail view shown when the driver taps a student card.
/// Shows both MORNING and AFTERNOON attendance with two steps per session:
/// [BOARDED] the child got on the bus, and [DROPPED_OFF] they arrived at destination.
class DriverChildAvailabilityForm extends StatelessWidget {
  final String childId;
  final String childName;
  final String? photoUrl;

  /// null if no attendance record exists for morning yet
  final AttendanceRecordModel? morningRecord;

  /// null if no attendance record exists for afternoon yet
  final AttendanceRecordModel? afternoonRecord;

  /// Called when the driver taps an action button.
  /// [session] = 'MORNING' or 'AFTERNOON'
  /// [action]  = 'BOARDED' or 'DROPPED_OFF'
  /// [newValue] = the desired confirmed state
  final void Function(String session, String action, bool newValue) onMarkAction;

  /// Set of "\$childId:\$session:\$action" keys that are currently being saved
  final Set<String> togglingKeys;

  /// Whether the parent has marked this child absent for each journey today
  final bool isAbsentMorning;
  final bool isAbsentAfternoon;

  final VoidCallback onCancel;

  const DriverChildAvailabilityForm({
    super.key,
    required this.childId,
    required this.childName,
    required this.photoUrl,
    required this.morningRecord,
    required this.afternoonRecord,
    required this.onMarkAction,
    required this.togglingKeys,
    required this.isAbsentMorning,
    required this.isAbsentAfternoon,
    required this.onCancel,
  });

  static const cancelBg = Color(0xFFEBF1FE);

  @override
  Widget build(BuildContext context) {
    final name = childName.isEmpty ? 'Unnamed student' : childName;

    // MORNING state
    final morningBoarded = morningRecord?.boarded ?? false;
    final morningDropped = morningRecord?.droppedOff ?? false;
    final morningBoardedToggling =
        togglingKeys.contains('$childId:MORNING:BOARDED');
    final morningDroppedToggling =
        togglingKeys.contains('$childId:MORNING:DROPPED_OFF');

    // AFTERNOON state
    final afternoonBoarded = afternoonRecord?.boarded ?? false;
    final afternoonDropped = afternoonRecord?.droppedOff ?? false;
    final afternoonBoardedToggling =
        togglingKeys.contains('$childId:AFTERNOON:BOARDED');
    final afternoonDroppedToggling =
        togglingKeys.contains('$childId:AFTERNOON:DROPPED_OFF');

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: cancelBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF001B3D),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Morning Journey ────────────────────────────────────────────────────────
          _SessionSection(
            sectionLabel: 'Morning Journey',
            sectionIcon: Icons.wb_sunny_outlined,            isAbsent: isAbsentMorning,            rows: [
              _AttendanceStepRow(
                label: 'Boarded bus',
                icon: Icons.directions_bus_outlined,
                active: morningBoarded,
                toggling: morningBoardedToggling,
                onTap: morningBoardedToggling
                    ? null
                    : () => onMarkAction('MORNING', 'BOARDED', !morningBoarded),
              ),
              _AttendanceStepRow(
                label: 'Arrived at school',
                icon: Icons.school_outlined,
                active: morningDropped,
                toggling: morningDroppedToggling,
                onTap: morningDroppedToggling
                    ? null
                    : () => onMarkAction(
                        'MORNING', 'DROPPED_OFF', !morningDropped),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Afternoon Journey ─────────────────────────────────────────────────
          _SessionSection(
            sectionLabel: 'Afternoon Journey',
            sectionIcon: Icons.wb_twilight_outlined,            isAbsent: isAbsentAfternoon,            rows: [
              _AttendanceStepRow(
                label: 'Boarded bus',
                icon: Icons.directions_bus_outlined,
                active: afternoonBoarded,
                toggling: afternoonBoardedToggling,
                onTap: afternoonBoardedToggling
                    ? null
                    : () =>
                        onMarkAction('AFTERNOON', 'BOARDED', !afternoonBoarded),
              ),
              _AttendanceStepRow(
                label: 'Dropped at stop',
                icon: Icons.home_outlined,
                active: afternoonDropped,
                toggling: afternoonDroppedToggling,
                onTap: afternoonDroppedToggling
                    ? null
                    : () => onMarkAction(
                        'AFTERNOON', 'DROPPED_OFF', !afternoonDropped),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Session section (header + rows) ────────────────────────────────────────────────

class _SessionSection extends StatelessWidget {
  final String sectionLabel;
  final IconData sectionIcon;
  final bool isAbsent;
  final List<_AttendanceStepRow> rows;

  const _SessionSection({
    required this.sectionLabel,
    required this.sectionIcon,
    this.isAbsent = false,
    required this.rows,
  });

  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2530) : Colors.white,
        border: Border.all(
          color: isAbsent
              ? const Color(0xFFE67E22).withValues(alpha: 0.35)
              : (isDark ? const Color(0xFF2A3A50) : stroke),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(isAbsent ? Icons.event_busy_rounded : sectionIcon,
                    size: 16,
                    color: isAbsent
                        ? const Color(0xFFE67E22)
                        : onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  sectionLabel,
                  style: TextStyle(
                    color: isAbsent ? const Color(0xFFE67E22) : onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF2A3A50) : stroke,
          ),
          // When absent, replace step rows with a notice
          if (isAbsent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 16, color: const Color(0xFFE67E22)),
                  const SizedBox(width: 8),
                  Text(
                    'Absent for this journey',
                    style: const TextStyle(
                      color: Color(0xFFE67E22),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Step rows
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 14,
                  endIndent: 14,
                  color: isDark ? const Color(0xFF2A3A50) : stroke,
                ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Attendance step row ───────────────────────────────────────────────────────────────

class _AttendanceStepRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool toggling;
  final VoidCallback? onTap;

  const _AttendanceStepRow({
    required this.label,
    required this.icon,
    required this.active,
    required this.toggling,
    required this.onTap,
  });

  static const green = Color(0xFF21C260);
  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: active ? green : onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active
                    ? green
                    : (isDark
                        ? const Color(0xFF2A3A50)
                        : const Color(0xFFEEF3FB)),
                borderRadius: BorderRadius.circular(10),
                border: active
                    ? null
                    : Border.all(
                        color: blue.withValues(alpha: 0.3), width: 1.5),
              ),
              child: toggling
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: active ? Colors.white : blue,
                      ),
                    )
                  : Icon(
                      active ? Icons.check : icon,
                      size: 20,
                      color: active
                          ? Colors.white
                          : blue.withValues(alpha: 0.6),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}