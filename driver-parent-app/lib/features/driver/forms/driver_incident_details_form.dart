import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class DriverIncidentDetailsForm extends StatefulWidget {

  final String incidentType;

  final VoidCallback onClose;

  final bool submitting;

  final String? error;

  final String? initialDescription;

  final String? initialJourneyImpact;

  final bool isEditing;

  final Future<void> Function({
    required String description,
    required String journeyImpact,
  }) onSubmit;

  const DriverIncidentDetailsForm({
    super.key,
    required this.incidentType,
    required this.onClose,
    required this.submitting,
    required this.error,
    required this.onSubmit,
    this.initialDescription,
    this.initialJourneyImpact,
    this.isEditing = false,
  });

  @override
  State<DriverIncidentDetailsForm> createState() =>
      _DriverIncidentDetailsFormState();
}

class _DriverIncidentDetailsFormState
    extends State<DriverIncidentDetailsForm> {
  static const _blue = Color(0xFF0D4896);
  static const _photoBackground = Color(0xFFF1F5FA);
  static const _photoBorder = Color(0xFFD9E1FF);
  static const _photoContent = Color(0xFF1358B6);
  static const _closeBackground = Color(0xFFEBF1FE);

  final TextEditingController _descriptionCtrl = TextEditingController();

  String? _selectedImpact;

  @override
  void initState() {
    super.initState();

    _descriptionCtrl.text =
        widget.initialDescription ?? '';

    _selectedImpact =
        widget.initialJourneyImpact;
  }

  bool get _isDelay => widget.incidentType == 'DELAY';

  List<String> get _availableImpacts {
    if (_isDelay) {
      return const [
        'DELAYED',
        'STOPPED',
      ];
    }

    return const [
      'NONE',
      'DELAYED',
      'STOPPED',
    ];
  }

  String get _title {
    if (widget.isEditing) {
      switch (widget.incidentType) {
        case 'ACCIDENT':
          return 'Edit accident';
        case 'VEHICLE_BREAKDOWN':
          return 'Edit mechanical issue';
        case 'DELAY':
          return 'Edit delay';
        case 'ROAD_OBSTRUCTION':
          return 'Edit road obstruction';
        case 'MEDICAL':
          return 'Edit medical incident';
        case 'CHILD_BEHAVIOR':
          return 'Edit behavior incident';
        case 'OTHER':
          return 'Edit other incident';
        default:
          return 'Edit incident';
      }
    }

    switch (widget.incidentType) {
      case 'ACCIDENT':
        return 'Report accident';
      case 'VEHICLE_BREAKDOWN':
        return 'Report mechanical issue';
      case 'DELAY':
        return 'Report delay';
      case 'ROAD_OBSTRUCTION':
        return 'Report road obstruction';
      case 'OTHER':
        return 'Report other incident';
      default:
        return 'Report incident';
    }
  }

  IconData get _titleIcon {
    switch (widget.incidentType) {
      case 'ACCIDENT':
        return IconsaxPlusLinear.car;
      case 'VEHICLE_BREAKDOWN':
        return IconsaxPlusLinear.setting_2;
      case 'DELAY':
        return IconsaxPlusLinear.clock;
      case 'ROAD_OBSTRUCTION':
        return IconsaxPlusLinear.routing;
      case 'OTHER':
        return IconsaxPlusLinear.more;
      default:
        return IconsaxPlusLinear.warning_2;
    }
  }

  String get _descriptionHint {
    switch (widget.incidentType) {
      case 'DELAY':
        return 'What is causing the delay?';
      case 'ROAD_OBSTRUCTION':
        return 'What is blocking or affecting the road?';
      default:
        return 'Write a message';
    }
  }

  bool get _showsPhotoPlaceholder {
    switch (widget.incidentType) {
      case 'ACCIDENT':
      case 'VEHICLE_BREAKDOWN':
      case 'ROAD_OBSTRUCTION':
      case 'OTHER':
        return true;
      default:
        return false;
    }
  }

  bool get _showsVoicePlaceholder {
    switch (widget.incidentType) {
      case 'ACCIDENT':
      case 'VEHICLE_BREAKDOWN':
      case 'DELAY':
      case 'ROAD_OBSTRUCTION':
      case 'OTHER':
        return true;
      default:
        return false;
    }
  }

  bool get _canSubmit {
    return _descriptionCtrl.text.trim().isNotEmpty &&
        _selectedImpact != null;
  }

  Future<void> _submit() async {
    if (!_canSubmit || widget.submitting) return;

    await widget.onSubmit(
      description: _descriptionCtrl.text.trim(),
      journeyImpact: _selectedImpact!,
    );
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final fieldBackground =
        isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

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
              onTap: widget.submitting ? null : widget.onClose,
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

        // ── Title ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _titleIcon,
              color: _blue,
              size: 27,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Photo placeholder ────────────────────────────────────────────
        if (_showsPhotoPlaceholder) ...[
          CustomPaint(
            foregroundPainter: _DashedRoundedBorderPainter(
              color: _photoBorder,
              radius: 10,
            ),
            child: Container(
              height: 92,
              decoration: BoxDecoration(
                color: _photoBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusLinear.gallery_add,
                      color: _photoContent,
                      size: 25,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Add photo',
                      style: TextStyle(
                        color: _photoContent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Description field ────────────────────────────────────────────
        Container(
          constraints: const BoxConstraints(
            minHeight: 70,
          ),
          decoration: BoxDecoration(
            color: fieldBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _descriptionCtrl,
            minLines: 2,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: _descriptionHint,
              hintStyle: TextStyle(
                color: onSurface.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              counterText: '',
            ),
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),

        // ── Voice placeholder ────────────────────────────────────────────
        if (_showsVoicePlaceholder) ...[
          const SizedBox(height: 14),
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fieldBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Record audio',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.62),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  IconsaxPlusLinear.microphone_2,
                  color: _blue,
                  size: 22,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Journey impact ────────────────────────────────────────────────
        Text(
          'Journey impact',
          style: TextStyle(
            color: onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            for (int i = 0; i < _availableImpacts.length; i++) ...[
              Expanded(
                child: _JourneyImpactChoice(
                  impact: _availableImpacts[i],
                  selected: _selectedImpact == _availableImpacts[i],
                  onTap: () {
                    setState(() {
                      _selectedImpact = _availableImpacts[i];
                    });
                  },
                ),
              ),
              if (i != _availableImpacts.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),

        const SizedBox(height: 26),

        if (widget.error != null) ...[
          Text(
            widget.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ── Submit ────────────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed:
              (_canSubmit && !widget.submitting) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  _blue.withValues(alpha: 0.35),
              disabledForegroundColor:
                  Colors.white.withValues(alpha: 0.75),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: widget.submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.isEditing
                      ? 'Save changes'
                      : 'Send report',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _JourneyImpactChoice extends StatelessWidget {
  final String impact;
  final bool selected;
  final VoidCallback onTap;

  const _JourneyImpactChoice({
    required this.impact,
    required this.selected,
    required this.onTap,
  });

  static const _blue = Color(0xFF0D4896);

  String get _label {
    switch (impact) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _blue
                : isDark
                    ? const Color(0xFF1A2530)
                    : const Color(0xFFF5F8FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _blue
                  : isDark
                      ? const Color(0xFF2A3A50)
                      : const Color(0xFFDCE6F5),
            ),
          ),
          child: Text(
            _label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      0.6,
      0.6,
      size.width - 1.2,
      size.height - 1.2,
    );

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      const dashLength = 5.0;
      const gapLength = 4.0;

      while (distance < metric.length) {
        final next = distance + dashLength;

        canvas.drawPath(
          metric.extractPath(
            distance,
            next.clamp(0, metric.length),
          ),
          paint,
        );

        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _DashedRoundedBorderPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}