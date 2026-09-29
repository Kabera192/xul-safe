import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

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
    File? image,
    File? audio,
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
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  File? _selectedImage;
  File? _recordedAudio;

  bool _isRecording = false;

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
    if (widget.isEditing) {
      return false;
    }

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
    if (widget.isEditing) {
      return false;
    }

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

  Future<void> _choosePhotoSource() async {
    if (widget.submitting || _selectedImage != null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(IconsaxPlusLinear.camera),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.gallery),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  void _removePhoto() {
    if (widget.submitting) return;

    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _toggleRecording() async {
    if (widget.submitting) return;

    if (_isRecording) {
      final path = await _audioRecorder.stop();

      if (!mounted) return;

      setState(() {
        _isRecording = false;

        if (path != null) {
          _recordedAudio = File(path);
        }
      });

      return;
    }

    if (_recordedAudio != null) return;

    final hasPermission =
        await _audioRecorder.hasPermission();

    if (!hasPermission) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Microphone permission is required to record a voice note.',
          ),
        ),
      );

      return;
    }

    final directory = Directory.systemTemp;

    final path =
        '${directory.path}/incident_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
      ),
      path: path,
    );

    if (!mounted) return;

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _removeAudio() async {
    if (widget.submitting) return;

    if (_isRecording) {
      await _audioRecorder.stop();
    }

    final audio = _recordedAudio;

    setState(() {
      _isRecording = false;
      _recordedAudio = null;
    });

    if (audio != null && await audio.exists()) {
      try {
        await audio.delete();
      } catch (_) {
        // Failure to delete a temporary recording should not block the form.
      }
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit ||
        widget.submitting ||
        _isRecording) {
      return;
    }

    await widget.onSubmit(
      description: _descriptionCtrl.text.trim(),
      journeyImpact: _selectedImpact!,
      image: _selectedImage,
      audio: _recordedAudio,
    );
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _audioRecorder.dispose();
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

        // ── Photo attachment ─────────────────────────────────────────────
        if (_showsPhotoPlaceholder) ...[
          if (_selectedImage == null)
            GestureDetector(
              onTap:
                  widget.submitting ? null : _choosePhotoSource,
              child: CustomPaint(
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
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap:
                            widget.submitting ? null : _removePhoto,
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 34,
                          height: 34,
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

        // ── Voice note attachment ────────────────────────────────────────
        if (_showsVoicePlaceholder) ...[
          const SizedBox(height: 14),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.submitting
                  ? null
                  : _recordedAudio != null
                      ? null
                      : _toggleRecording,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isRecording
                        ? _blue
                        : borderColor,
                    width: _isRecording ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isRecording
                          ? IconsaxPlusLinear.stop
                          : _recordedAudio != null
                              ? IconsaxPlusLinear.tick_circle
                              : IconsaxPlusLinear.microphone_2,
                      color: _blue,
                      size: 22,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        _isRecording
                            ? 'Recording... Tap to stop'
                            : _recordedAudio != null
                                ? 'Voice note recorded'
                                : 'Record audio',
                        style: TextStyle(
                          color: _recordedAudio != null ||
                                  _isRecording
                              ? onSurface
                              : onSurface.withValues(alpha: 0.62),
                          fontSize: 13,
                          fontWeight: _recordedAudio != null ||
                                  _isRecording
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),

                    if (_recordedAudio != null)
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: widget.submitting
                              ? null
                              : _removeAudio,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.close_rounded,
                              color: _blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],

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
              (_canSubmit &&
                      !widget.submitting &&
                      !_isRecording)
                  ? _submit
                  : null,
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