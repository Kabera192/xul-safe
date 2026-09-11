import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverIncidentSuccessForm extends StatelessWidget {
  final String incidentType;
  final VoidCallback onDone;

  const DriverIncidentSuccessForm({
    super.key,
    required this.incidentType,
    required this.onDone,
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