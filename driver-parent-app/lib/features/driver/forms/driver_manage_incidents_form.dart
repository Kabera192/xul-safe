import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/driver_incident_model.dart';

class DriverManageIncidentsForm extends StatefulWidget {
  final List<DriverIncidentModel> incidents;
  final bool loading;
  final String? error;
  final int? currentUserId;

  final VoidCallback onClose;
  final void Function(DriverIncidentModel incident) onEdit;
  final void Function(DriverIncidentModel incident) onResolve;

  const DriverManageIncidentsForm({
    super.key,
    required this.incidents,
    required this.loading,
    required this.error,
    required this.currentUserId,
    required this.onClose,
    required this.onEdit,
    required this.onResolve,
  });

  @override
  State<DriverManageIncidentsForm> createState() =>
      _DriverManageIncidentsFormState();
}

class _DriverManageIncidentsFormState
    extends State<DriverManageIncidentsForm> {
  static const _blue = Color(0xFF0D4896);
  static const _closeBackground = Color(0xFFEBF1FE);

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DriverIncidentModel> get _filtered {
    final query = _searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.incidents;
    }

    return widget.incidents.where((incident) {
      return _typeLabel(incident.type).toLowerCase().contains(query) ||
          _impactLabel(incident.journeyImpact).toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query);
    }).toList();
  }

  bool _canManage(DriverIncidentModel incident) {
    final userId = widget.currentUserId;

    return incident.isActive &&
        userId != null &&
        incident.createdBy == userId;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill =
        isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    final filtered = _filtered;

    final active = filtered
        .where((incident) => incident.isActive)
        .toList();

    final resolved = filtered
        .where((incident) => incident.isResolved)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Close ────────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: _closeBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onClose,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: _blue,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Manage incidents',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          // ── Search ───────────────────────────────────────────────────
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  IconsaxPlusLinear.search_normal_1,
                  color: _blue,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search incidents',
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
          ),

          const SizedBox(height: 18),

          if (widget.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (widget.error != null) ...[
            _MessageCard(
              text: widget.error!,
              textColor: Colors.red,
              bgColor: inputFill,
              borderColor: borderColor,
            ),
          ] else if (filtered.isEmpty) ...[
            _MessageCard(
              text: 'No incidents found',
              textColor: onSurface.withValues(alpha: 0.5),
              bgColor: inputFill,
              borderColor: borderColor,
            ),
          ] else ...[
            if (active.isNotEmpty) ...[
              _SectionTitle(
                'ONGOING',
                onSurface: onSurface,
              ),
              const SizedBox(height: 10),

              ...active.asMap().entries.map(
                (entry) => _IncidentCard(
                  incident: entry.value,
                  index: entry.key,
                  canManage: _canManage(entry.value),
                  onEdit: () => widget.onEdit(entry.value),
                  onResolve: () =>
                      widget.onResolve(entry.value),
                ),
              ),

              const SizedBox(height: 18),
            ],

            if (resolved.isNotEmpty) ...[
              _SectionTitle(
                'RESOLVED',
                onSurface: onSurface,
              ),
              const SizedBox(height: 10),

              ...resolved.asMap().entries.map(
                (entry) => _IncidentCard(
                  incident: entry.value,
                  index: entry.key,
                  canManage: false,
                  onEdit: null,
                  onResolve: null,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final DriverIncidentModel incident;
  final int index;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onResolve;

  const _IncidentCard({
    required this.incident,
    required this.index,
    required this.canManage,
    required this.onEdit,
    required this.onResolve,
  });

  static const _blue = Color(0xFF0D4896);
  static const _green = Color(0xFF21C260);

  bool get _isAltRow => index.isEven;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    final bgColor = _isAltRow
        ? (isDark
            ? const Color(0xFF1A2A3E)
            : const Color(0xFFF1F5FA))
        : surface;

    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    final iconColor =
        isDark ? const Color(0xFF93B5E8) : _blue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: _isAltRow
              ? null
              : Border.all(
                  color: borderColor,
                  width: 1,
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Icon(
                  _iconForType(incident.type),
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _typeLabel(incident.type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      _StatusBadge(
                        resolved: incident.isResolved,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Journey: ${_impactLabel(incident.journeyImpact)}',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (incident.createdAt != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatCreatedAt(incident.createdAt!),
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  if (canManage) ...[
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _SmallActionButton(
                          label: 'Edit',
                          onTap: onEdit!,
                          primary: false,
                        ),

                        const SizedBox(width: 8),

                        _SmallActionButton(
                          label: 'Resolve',
                          onTap: onResolve!,
                          primary: true,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool resolved;

  const _StatusBadge({
    required this.resolved,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      resolved ? 'RESOLVED' : 'ACTIVE',
      style: TextStyle(
        color: resolved
            ? const Color(0xFF21C260)
            : const Color(0xFFFC4A4A),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _SmallActionButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: primary
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                side: const BorderSide(
                  color: Color(0xFFDCE6F5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color onSurface;

  const _SectionTitle(
    this.text, {
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _MessageCard({
    required this.text,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type.toUpperCase()) {
    case 'ACCIDENT':
      return IconsaxPlusLinear.car;

    case 'MEDICAL':
      return IconsaxPlusLinear.health;

    case 'VEHICLE_BREAKDOWN':
      return IconsaxPlusLinear.setting_2;

    case 'DELAY':
      return IconsaxPlusLinear.clock;

    case 'ROAD_OBSTRUCTION':
      return IconsaxPlusLinear.routing;

    case 'CHILD_BEHAVIOR':
      return IconsaxPlusLinear.people;

    case 'OTHER':
    default:
      return IconsaxPlusLinear.more;
  }
}

String _typeLabel(String type) {
  switch (type.toUpperCase()) {
    case 'ACCIDENT':
      return 'Bus accident or collision';

    case 'MEDICAL':
      return 'Sick / injured student';

    case 'VEHICLE_BREAKDOWN':
      return 'Bus mechanical issue';

    case 'DELAY':
      return 'Journey delay';

    case 'ROAD_OBSTRUCTION':
      return 'Road obstruction';

    case 'CHILD_BEHAVIOR':
      return 'Student behavior issue';

    case 'OTHER':
    default:
      return 'Other incident';
  }
}

String _impactLabel(String impact) {
  switch (impact.toUpperCase()) {
    case 'NONE':
      return 'No impact';

    case 'DELAYED':
      return 'Delayed';

    case 'STOPPED':
      return 'Stopped';

    default:
      return impact;
  }
}

String _formatCreatedAt(int milliseconds) {
  final date =
      DateTime.fromMillisecondsSinceEpoch(milliseconds);

  final now = DateTime.now();

  final sameDay =
      date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;

  final hour =
      date.hour.toString().padLeft(2, '0');

  final minute =
      date.minute.toString().padLeft(2, '0');

  if (sameDay) {
    return 'Today, $hour:$minute';
  }

  final yesterday =
      now.subtract(const Duration(days: 1));

  final wasYesterday =
      date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;

  if (wasYesterday) {
    return 'Yesterday, $hour:$minute';
  }

  final day =
      date.day.toString().padLeft(2, '0');

  final month =
      date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}, $hour:$minute';
}