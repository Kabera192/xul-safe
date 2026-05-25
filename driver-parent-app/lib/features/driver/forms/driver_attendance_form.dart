import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/attendance_record_model.dart';

class DriverAttendanceForm extends StatefulWidget {
  final bool loading;
  final String? error;

  /// 'MORNING' or 'AFTERNOON'
  final String activeSession;

  /// All students on the bus with their confirmed status for [activeSession]
  final List<AttendanceRecordModel> records;

  /// Called when the driver switches between MORNING and AFTERNOON tabs
  final void Function(String session) onSessionChanged;

  /// Called when the driver taps one of the two action buttons on a card.
  /// [action] is 'BOARDED' or 'DROPPED_OFF', [newValue] is the desired state.
  final void Function(AttendanceRecordModel record, String action, bool newValue) onMarkAction;

  /// Called when the driver taps a student card (not an action button)
  final void Function(AttendanceRecordModel record) onChildTap;

  /// Set of "\$childId:\$session:\$action" keys currently being saved
  final Set<String> togglingKeys;

  const DriverAttendanceForm({
    super.key,
    required this.loading,
    required this.error,
    required this.activeSession,
    required this.records,
    required this.onSessionChanged,
    required this.onMarkAction,
    required this.onChildTap,
    required this.togglingKeys,
  });

  @override
  State<DriverAttendanceForm> createState() => _DriverAttendanceFormState();
}

class _DriverAttendanceFormState extends State<DriverAttendanceForm> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AttendanceRecordModel> get _filtered {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return widget.records;
    return widget.records
        .where((r) => r.childName.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filtered;
    // Count children who are fully done (both steps completed), excluding absent
    final confirmedCount = records.where((r) => !r.isAbsent && r.boarded && r.droppedOff).length;
    final totalCount = records.where((r) => !r.isAbsent).length;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchBox(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _SessionTabs(
            activeSession: widget.activeSession,
            confirmedCount: confirmedCount,
            totalCount: totalCount,
            onMorningTap: () => widget.onSessionChanged('MORNING'),
            onAfternoonTap: () => widget.onSessionChanged('AFTERNOON'),
          ),
          const SizedBox(height: 12),
          if (widget.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (widget.error != null) ...[
            _MessageCard(text: widget.error!, textColor: Colors.red),
          ] else ...[
            _StudentList(
              records: records,
              session: widget.activeSession,
              togglingKeys: widget.togglingKeys,
              onMarkAction: widget.onMarkAction,
              onCardTap: widget.onChildTap,
            ),
          ],
        ],
      ),
    );
  }
}

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
                hintText: 'Search a name',
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

// ── Session tabs ──────────────────────────────────────────────────────────────

class _SessionTabs extends StatelessWidget {
  final String activeSession;
  final int confirmedCount;
  final int totalCount;
  final VoidCallback onMorningTap;
  final VoidCallback onAfternoonTap;

  const _SessionTabs({
    required this.activeSession,
    required this.confirmedCount,
    required this.totalCount,
    required this.onMorningTap,
    required this.onAfternoonTap,
  });

  static const blue = Color(0xFF0D4896);

  bool get _isMorning => activeSession == 'MORNING';

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final dividerColor = onSurface.withValues(alpha: 0.12);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onMorningTap,
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny_outlined,
                              size: 14,
                              color: _isMorning ? blue : onSurface),
                          const SizedBox(width: 4),
                          Text(
                            'Morning',
                            style: TextStyle(
                              color: _isMorning ? blue : onSurface,
                              fontSize: 13,
                              fontWeight: _isMorning
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (_isMorning) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$confirmedCount / $totalCount completed',
                          style: TextStyle(
                            color: blue.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onAfternoonTap,
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_twilight_outlined,
                              size: 14,
                              color: !_isMorning ? blue : onSurface),
                          const SizedBox(width: 4),
                          Text(
                            'Afternoon',
                            style: TextStyle(
                              color: !_isMorning ? blue : onSurface,
                              fontSize: 13,
                              fontWeight: !_isMorning
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (!_isMorning) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$confirmedCount / $totalCount completed',
                          style: TextStyle(
                            color: blue.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 1.2, color: dividerColor),
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: _isMorning
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                height: 2.6,
                width: MediaQuery.of(context).size.width * 0.42,
                color: blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Student list ──────────────────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final List<AttendanceRecordModel> records;
  final String session;
  final Set<String> togglingKeys;
  final void Function(AttendanceRecordModel, String action, bool newValue) onMarkAction;
  final void Function(AttendanceRecordModel) onCardTap;

  const _StudentList({
    required this.records,
    required this.session,
    required this.togglingKeys,
    required this.onMarkAction,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const _MessageCard(text: 'No students on this bus');
    }

    // Pin absent students to the top
    final sorted = [...records]
      ..sort((a, b) {
        if (a.isAbsent && !b.isAbsent) return -1;
        if (!a.isAbsent && b.isAbsent) return 1;
        return 0;
      });

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final record = sorted[index];
          final isBoardedToggling =
              togglingKeys.contains('${record.childId}:$session:BOARDED');
          final isDroppedOffToggling =
              togglingKeys.contains('${record.childId}:$session:DROPPED_OFF');

          return _StudentCard(
            record: record,
            session: session,
            isBoardedToggling: isBoardedToggling,
            isDroppedOffToggling: isDroppedOffToggling,
            onToggleBoarded: () =>
                onMarkAction(record, 'BOARDED', !record.boarded),
            onToggleDroppedOff: () =>
                onMarkAction(record, 'DROPPED_OFF', !record.droppedOff),
            onTap: () => onCardTap(record),
          );
        },
      ),
    );
  }
}

// ── Student card ──────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final AttendanceRecordModel record;
  final String session;
  final bool isBoardedToggling;
  final bool isDroppedOffToggling;
  final VoidCallback onToggleBoarded;
  final VoidCallback onToggleDroppedOff;
  final VoidCallback onTap;

  const _StudentCard({
    required this.record,
    required this.session,
    required this.isBoardedToggling,
    required this.isDroppedOffToggling,
    required this.onToggleBoarded,
    required this.onToggleDroppedOff,
    required this.onTap,
  });

  static const stroke = Color(0xFFDCE6F5);
  static const green = Color(0xFF21C260);
  static const blue = Color(0xFF0D4896);

  String _statusLabel() {
    if (record.isAbsent) return 'Absent today';
    if (record.boarded && record.droppedOff) return 'Completed';
    if (record.boarded) {
      return session == 'MORNING' ? 'On bus' : 'Heading home';
    }
    return session == 'MORNING' ? 'Not yet boarded' : 'Not yet picked up';
  }

  Color _statusColor(Color onSurface) {
    if (record.isAbsent) return const Color(0xFFE67E22);
    if (record.boarded && record.droppedOff) return green;
    if (record.boarded) return const Color(0xFFF5A623);
    return onSurface.withValues(alpha: 0.45);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final name =
        record.childName.isEmpty ? 'Unnamed student' : record.childName;
    final dropoffIcon =
        session == 'MORNING' ? Icons.school_outlined : Icons.home_outlined;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              _Avatar(photoUrl: record.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: _statusColor(onSurface),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (record.isAbsent)
                const _AbsentBadge()
              else ...[  
                _ActionButton(
                  isDark: isDark,
                  active: record.boarded,
                  toggling: isBoardedToggling,
                  icon: Icons.directions_bus_outlined,
                  onTap: isBoardedToggling ? null : onToggleBoarded,
                ),
                const SizedBox(width: 6),
                // ── DROPPED_OFF button ─────────────────────────────────────────────────────
                _ActionButton(
                  isDark: isDark,
                  active: record.droppedOff,
                  toggling: isDroppedOffToggling,
                  icon: dropoffIcon,
                  onTap: isDroppedOffToggling ? null : onToggleDroppedOff,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact action button ─────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final bool isDark;
  final bool active;
  final bool toggling;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.isDark,
    required this.active,
    required this.toggling,
    required this.icon,
    required this.onTap,
  });

  static const green = Color(0xFF21C260);
  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active
              ? green
              : (isDark
                  ? const Color(0xFF2A3A50)
                  : const Color(0xFFEEF3FB)),
          shape: BoxShape.circle,
          border: active
              ? null
              : Border.all(
                  color: blue.withValues(alpha: 0.3), width: 1.5),
        ),
        child: toggling
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: active ? Colors.white : blue,
                ),
              )
            : Icon(
                icon,
                size: 17,
                color: active ? Colors.white : blue.withValues(alpha: 0.6),
              ),
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

// ── Message card ──────────────────────────────────────────────────────────────

class _MessageCard extends StatelessWidget {
  final String text;
  final Color? textColor;

  const _MessageCard({required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor ?? onSurface.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Absent badge (replaces action buttons for absent children) ────────────────

class _AbsentBadge extends StatelessWidget {
  const _AbsentBadge();

  static const _orange = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D2200) : const Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _orange.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, color: _orange, size: 13),
          SizedBox(width: 4),
          Text(
            'Absent',
            style: TextStyle(
              color: _orange,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}