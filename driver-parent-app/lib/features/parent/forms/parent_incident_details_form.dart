import 'dart:typed_data';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/child_service.dart';
import '../models/child_model.dart';
import '../models/parent_incident_model.dart';

class ParentIncidentDetailsForm extends StatelessWidget {
  final ParentIncidentModel incident;
  final List<ChildModel> affectedChildren;
  final Uint8List? imageBytes;
  final Uint8List? audioBytes;
  final VoidCallback onClose;

  const ParentIncidentDetailsForm({
    super.key,
    required this.incident,
    required this.affectedChildren,
    required this.imageBytes,
    required this.audioBytes,
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

        // ── Incident photo ───────────────────────────────────────────────
        if (imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              imageBytes!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Text(
                    'Photo unavailable',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
        // ── Voice note ───────────────────────────────────────────────────
        if (audioBytes != null) ...[
          _IncidentVoiceNote(
            audioBytes: audioBytes!,
          ),

          const SizedBox(height: 20),
        ],
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

class _IncidentVoiceNote extends StatefulWidget {
  final Uint8List audioBytes;

  const _IncidentVoiceNote({
    required this.audioBytes,
  });

  @override
  State<_IncidentVoiceNote> createState() =>
      _IncidentVoiceNoteState();
}

class _IncidentVoiceNoteState
    extends State<_IncidentVoiceNote> {
  static const _blue = Color(0xFF0D4896);

  final AudioPlayer _player = AudioPlayer();

  File? _audioFile;
  bool _preparing = true;
  bool _failed = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player.positionStream.listen((position) {
      if (!mounted) return;

      setState(() {
        _position = position;
      });
    });

    _player.durationStream.listen((duration) {
      if (!mounted || duration == null) return;

      setState(() {
        _duration = duration;
      });
    });

    _player.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }

      setState(() {});
    });

    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/incident_voice_'
        '${DateTime.now().microsecondsSinceEpoch}.m4a',
      );

      await file.writeAsBytes(
        widget.audioBytes,
        flush: true,
      );

      await _player.setFilePath(file.path);

      if (!mounted) return;

      setState(() {
        _audioFile = file;
        _preparing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _preparing = false;
        _failed = true;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_preparing || _failed) return;

    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString();

    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();

    final file = _audioFile;

    if (file != null) {
      file.delete().catchError((_) => file);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final onSurface =
        Theme.of(context).colorScheme.onSurface;

    final background =
        isDark ? const Color(0xFF1A2530) : Colors.white;

    final borderColor =
        isDark
            ? const Color(0xFF2A3A50)
            : const Color(0xFFDCE6F5);

    if (_failed) {
      return Container(
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          'Voice note unavailable',
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final maxMilliseconds =
        _duration.inMilliseconds > 0
            ? _duration.inMilliseconds.toDouble()
            : 1.0;

    final positionMilliseconds =
        _position.inMilliseconds
            .clamp(0, maxMilliseconds.toInt())
            .toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed:
                  _preparing ? null : _togglePlayback,
              icon: _preparing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _player.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: _blue,
                      size: 28,
                    ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Slider(
              value: positionMilliseconds,
              min: 0,
              max: maxMilliseconds,
              onChanged:
                  _preparing || _duration == Duration.zero
                      ? null
                      : (value) {
                          _player.seek(
                            Duration(
                              milliseconds: value.round(),
                            ),
                          );
                        },
            ),
          ),

          const SizedBox(width: 6),

          Text(
            '${_formatDuration(_position)} / '
            '${_formatDuration(_duration)}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.65),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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