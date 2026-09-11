import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class DriverIncidentTypeForm extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onIncidentTypeSelected;

  const DriverIncidentTypeForm({
    super.key,
    required this.onClose,
    required this.onIncidentTypeSelected,
  });

  static const _blue = Color(0xFF0D4896);
  static const _optionBackground = Color(0xFFF5F8FB);
  static const _closeBackground = Color(0xFFEBF1FE);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: _closeBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: _blue,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'On Trip Incidents',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.car,
            title: 'Bus accident or collision',
            onTap: () => onIncidentTypeSelected('ACCIDENT'),
          ),
          const SizedBox(height: 10),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.health,
            title: 'Sick / injured student',
            onTap: () => onIncidentTypeSelected('MEDICAL'),
          ),
          const SizedBox(height: 10),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.setting_2,
            title: 'Bus mechanical issue',
            onTap: () => onIncidentTypeSelected('VEHICLE_BREAKDOWN'),
          ),
          const SizedBox(height: 10),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.clock,
            title: 'Journey delay',
            onTap: () => onIncidentTypeSelected('DELAY'),
          ),
          const SizedBox(height: 10),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.routing,
            title: 'Road obstruction',
            onTap: () => onIncidentTypeSelected('ROAD_OBSTRUCTION'),
          ),
          const SizedBox(height: 10),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.people,
            title: 'Student behavior issue',
            onTap: () => onIncidentTypeSelected('CHILD_BEHAVIOR'),
          ),
          const SizedBox(height: 10),

          _IncidentTypeOption(
            icon: IconsaxPlusLinear.more,
            title: 'Other incidents',
            onTap: () => onIncidentTypeSelected('OTHER'),
          ),
        ],
      ),
    );
  }
}

class _IncidentTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _IncidentTypeOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  static const _blue = Color(0xFF0D4896);
  static const _background = Color(0xFFF5F8FB);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Center(
                  child: Icon(
                    icon,
                    color: _blue,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}