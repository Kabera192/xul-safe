import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/child_service.dart';
import '../models/child_model.dart';
import '../models/parent_incident_model.dart';

class ParentIncidentDetailsForm extends StatelessWidget {
  final ParentIncidentModel incident;
  final List<ChildModel> affectedChildren;
  final VoidCallback onClose;

  const ParentIncidentDetailsForm({
    super.key,
    required this.incident,
    required this.affectedChildren,
    required this.onClose,
  });

  static const _blue = Color(0xFF0D4896);
  static const _closeBackground = Color(0xFFEBF1FE);

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final onSurface =
        Theme.of(context).colorScheme.onSurface;

    final cardBackground =
        isDark ? const Color(0xFF1A2530) : Colors.white;

    final borderColor =
        isDark
            ? const Color(0xFF2A3A50)
            : const Color(0xFFDCE6F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Close ────────────────────────────────────────────────────────
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: _closeBackground,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onClose,
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

        // ── Incident title ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconForType(incident.type),
              color: _blue,
              size: 27,
            ),

            const SizedBox(width: 12),

            Flexible(
              child: Text(
                _typeLabel(incident.type),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Center(
          child: _StatusText(
            resolved: incident.isResolved,
          ),
        ),

        const SizedBox(height: 26),

        // ── Affected children ────────────────────────────────────────────
        if (affectedChildren.isNotEmpty) ...[
          Text(
            affectedChildren.length == 1
                ? 'Affected student'
                : 'Affected students',
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          ...affectedChildren.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AffectedChildRow(
                child: child,
                background: cardBackground,
                borderColor: borderColor,
              ),
            ),
          ),

          const SizedBox(height: 14),
        ],

        // ── Journey impact ────────────────────────────────────────────────
        Text(
          'Journey impact',
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _impactIcon(incident.journeyImpact),
                color: _impactColor(incident.journeyImpact),
                size: 19,
              ),

              const SizedBox(width: 10),

              Text(
                _impactLabel(incident.journeyImpact),
                style: TextStyle(
                  color: onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Description ───────────────────────────────────────────────────
        Text(
          'What happened?',
          style: TextStyle(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Text(
            incident.description,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Timeline ──────────────────────────────────────────────────────
        _TimeRow(
          icon: IconsaxPlusLinear.clock,
          label: 'Reported',
          value: _formatDateTime(incident.createdAt),
          onSurface: onSurface,
        ),

        if (incident.resolvedAt != null) ...[
          const SizedBox(height: 12),

          _TimeRow(
            icon: IconsaxPlusLinear.tick_circle,
            label: 'Resolved',
            value: _formatDateTime(incident.resolvedAt!),
            onSurface: onSurface,
          ),
        ],

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Affected child
// ─────────────────────────────────────────────────────────────────────────────

class _AffectedChildRow extends StatelessWidget {
  final ChildModel child;
  final Color background;
  final Color borderColor;

  const _AffectedChildRow({
    required this.child,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface =
        Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _ChildAvatar(
            childId: child.id,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              child.fullName.isEmpty
                  ? 'Student'
                  : child.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Child photo
// ─────────────────────────────────────────────────────────────────────────────

class _ChildAvatar extends StatefulWidget {
  final String childId;

  const _ChildAvatar({
    required this.childId,
  });

  @override
  State<_ChildAvatar> createState() =>
      _ChildAvatarState();
}

class _ChildAvatarState extends State<_ChildAvatar> {
  static const _blue = Color(0xFF0D4896);

  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    try {
      final bytes =
          await ChildService.getChildPhotoBytes(
        widget.childId,
      );

      if (!mounted) return;

      setState(() {
        _photoBytes = bytes;
      });
    } catch (_) {
      // Default avatar remains visible.
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 21,
      backgroundColor: const Color(0xFFEBF1FE),
      backgroundImage: _photoBytes != null
          ? MemoryImage(_photoBytes!)
          : null,
      child: _photoBytes == null
          ? const Icon(
              IconsaxPlusLinear.user,
              color: _blue,
              size: 20,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline row
// ─────────────────────────────────────────────────────────────────────────────

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color onSurface;

  const _TimeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onSurface,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: _blue,
          size: 18,
        ),

        const SizedBox(width: 10),

        Text(
          '$label:',
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.55),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status
// ─────────────────────────────────────────────────────────────────────────────

class _StatusText extends StatelessWidget {
  final bool resolved;

  const _StatusText({
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
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

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

IconData _impactIcon(String impact) {
  switch (impact.toUpperCase()) {
    case 'DELAYED':
      return IconsaxPlusLinear.clock;

    case 'STOPPED':
      return IconsaxPlusLinear.close_circle;

    case 'NONE':
    default:
      return IconsaxPlusLinear.tick_circle;
  }
}

Color _impactColor(String impact) {
  switch (impact.toUpperCase()) {
    case 'DELAYED':
      return Colors.orange;

    case 'STOPPED':
      return const Color(0xFFFC4A4A);

    case 'NONE':
    default:
      return const Color(0xFF21C260);
  }
}

String _formatDateTime(int milliseconds) {
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