import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverIncidentSuccessForm extends StatelessWidget {
  final String incidentType;
  final VoidCallback onDone;

  /// Set when the incident report itself succeeded but an attached
  /// photo/voice note failed to upload. The report has already reached
  /// the relevant people -- this is a secondary, non-blocking notice,
  /// not a reason to show a failure screen or let the driver retry
  /// (retrying would create a duplicate report).
  final String? attachmentWarning;

  const DriverIncidentSuccessForm({
    super.key,
    required this.incidentType,
    required this.onDone,
    this.attachmentWarning,
  });

  static const blue = Color(0xFF0D4896);

  String get _title {
    switch (incidentType) {
      case 'ACCIDENT':
        return 'Accident report sent';

      case 'VEHICLE_BREAKDOWN':
        return 'Mechanical issue reported';

      case 'DELAY':
        return 'Delay report sent';

      case 'ROAD_OBSTRUCTION':
        return 'Road obstruction reported';

      case 'MEDICAL':
        return 'Medical report sent';

      case 'CHILD_BEHAVIOR':
        return 'Behavior incident reported';

      case 'OTHER':
        return 'Incident report sent';

      default:
        return 'Incident reported';
    }
  }

  String get _description {
    switch (incidentType) {
      case 'ACCIDENT':
        return 'The accident has been reported successfully. The relevant people can now be informed about the incident.';

      case 'VEHICLE_BREAKDOWN':
        return 'The mechanical issue has been reported successfully. The relevant people can now be informed about the incident.';

      case 'DELAY':
        return 'The journey delay has been reported successfully. The relevant people can now be informed about the delay.';

      case 'ROAD_OBSTRUCTION':
        return 'The road obstruction has been reported successfully. The relevant people can now be informed about the incident.';

      case 'MEDICAL':
        return 'The medical incident has been reported successfully. The relevant people can now be informed about the affected student.';

      case 'CHILD_BEHAVIOR':
        return 'The student behavior incident has been reported successfully. The relevant people can now be informed about the incident.';

      case 'OTHER':
        return 'The incident has been reported successfully. The relevant people can now be informed about it.';

      default:
        return 'The incident has been reported successfully.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // ── Existing app success visual ───────────────────────────────
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
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

          // ── Dynamic success title ─────────────────────────────────────
          Center(
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Dynamic description ───────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          if (attachmentWarning != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB45309),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachmentWarning!,
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // ── Done ──────────────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}