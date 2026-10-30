import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/app_localizations.dart';

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

  String _title(AppLocalizations l10n) {
    switch (incidentType) {
      case 'ACCIDENT':
        return l10n.drvAccidentReportSentTitle;

      case 'VEHICLE_BREAKDOWN':
        return l10n.drvBreakdownReportedTitle;

      case 'DELAY':
        return l10n.drvDelayReportSentTitle;

      case 'ROAD_OBSTRUCTION':
        return l10n.drvRoadObstructionReportedTitle;

      case 'MEDICAL':
        return l10n.drvMedicalReportSentTitle;

      case 'CHILD_BEHAVIOR':
        return l10n.drvBehaviorIncidentReportedTitle;

      case 'OTHER':
        return l10n.drvIncidentReportSentTitle;

      default:
        return l10n.drvIncidentReportedTitle;
    }
  }

  String _description(AppLocalizations l10n) {
    switch (incidentType) {
      case 'ACCIDENT':
        return l10n.drvAccidentReportedBody;

      case 'VEHICLE_BREAKDOWN':
        return l10n.drvBreakdownReportedBody;

      case 'DELAY':
        return l10n.drvDelayReportedBody;

      case 'ROAD_OBSTRUCTION':
        return l10n.drvRoadObstructionReportedBody;

      case 'MEDICAL':
        return l10n.drvMedicalReportedBody;

      case 'CHILD_BEHAVIOR':
        return l10n.drvBehaviorReportedBody;

      case 'OTHER':
        return l10n.drvOtherIncidentReportedBody;

      default:
        return l10n.drvIncidentReportedBodyDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              _title(l10n),
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
                _description(l10n),
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
              child: Text(
                l10n.gotIt,
                style: const TextStyle(
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