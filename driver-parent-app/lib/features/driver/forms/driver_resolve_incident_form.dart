import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/driver_incident_model.dart';

class DriverResolveIncidentForm extends StatelessWidget {
  final DriverIncidentModel incident;
  final bool resolving;
  final String? error;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const DriverResolveIncidentForm({
    super.key,
    required this.incident,
    required this.resolving,
    required this.error,
    required this.onCancel,
    required this.onConfirm,
  });

  static const _blue = Color(0xFF0D4896);
  static const _green = Color(0xFF21C260);
  static const _closeBackground = Color(0xFFEBF1FE);

  String get _incidentLabel {
    switch (incident.type.toUpperCase()) {
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

  IconData get _incidentIcon {
    switch (incident.type.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final incidentBackground =
        isDark ? const Color(0xFF1A2530) : const Color(0xFFF1F5FA);

    final incidentBorder =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Close ──────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: _closeBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: resolving ? null : onCancel,
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

          const SizedBox(height: 12),

          // ── Resolve icon ────────────────────────────────────────────
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  IconsaxPlusLinear.tick_circle,
                  color: _green,
                  size: 36,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Resolve incident?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Are you sure this incident has been resolved? '
              'It will move to the resolved incidents section.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.55),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Incident being resolved ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: incidentBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: incidentBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _incidentIcon,
                  color: _blue,
                  size: 23,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    _incidentLabel,
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
          ),

          if (error != null) ...[
            const SizedBox(height: 14),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 26),

          // ── Actions ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: resolving ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(
                        color: Color(0xFFDCE6F5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: resolving ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _green.withValues(alpha: 0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: resolving
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Resolve',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}