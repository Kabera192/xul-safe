import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/absence_model.dart';
import '../models/child_model.dart';
import 'parent_cancel_absence_form.dart';
import 'parent_child_photo_form.dart';
import 'parent_delete_child_form.dart';
import 'parent_edit_absence_form.dart';
import 'parent_edit_child_form.dart';
import 'parent_mark_absent_form.dart';

class ParentMyChildrenForm extends StatefulWidget {
  final VoidCallback? onRequestRefresh;
  const ParentMyChildrenForm({super.key, this.onRequestRefresh});

  @override
  State<ParentMyChildrenForm> createState() => _ParentMyChildrenFormState();
}

class _ParentMyChildrenFormState extends State<ParentMyChildrenForm> {
  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  List<ChildModel> _children = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final children = await ChildService.getMyChildren();
      if (mounted) setState(() => _children = children);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),

          // Hint card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    IconsaxPlusLinear.info_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).didYouKnow,
                        style: const TextStyle(
                          color: blue,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).didYouKnowBody,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Content
          if (_loading)
            const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _load, child: Text(AppLocalizations.of(context).retry)),
                  ],
                ),
              ),
            )
          else if (_children.isEmpty)
            SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusLinear.user_add, size: 48, color: onSurface.withOpacity(0.26)),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).noChildrenYet,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).tapToAddFirstChild,
                      style: TextStyle(color: onSurface.withValues(alpha: 0.45), fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: _children.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                // Slightly taller than a plain square so the avatar + 2-line
                // name + grade + absence badge don't get tight against the
                // cell at larger OS text-scale settings.
                childAspectRatio: 0.7,
              ),
              itemBuilder: (_, i) => _ChildTile(
                child: _children[i],
                onTap: () => _showChildActions(_children[i]),
              ),
            ),
        ],
      ),
    );
  }

  // ── Action sheet ──────────────────────────────────────────────────────────

  void _showChildActions(ChildModel child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ChildActionsSheet(
        child: child,
        onEditDetails: () => _showEditSheet(child),
        onChangePhoto: () => _showPhotoSheet(child),
        onMarkAbsent: () => _showAbsentSheet(child),
        onEditAbsence: (a) => _showEditAbsenceSheet(child, a),
        onCancelAbsence: (a) => _showCancelAbsenceSheet(child, a),
        onRemoveChild: () async {
          final wasDeleted = await _showDeleteSheet(child);
          if (wasDeleted && ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _showEditSheet(ChildModel child) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParentEditChildForm(child: child),
    );
    if (updated == true && mounted) _load();
  }

  Future<void> _showPhotoSheet(ChildModel child) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParentChildPhotoForm(childId: child.id),
    );
    if (updated == true && mounted) _load();
  }

  Future<void> _showAbsentSheet(ChildModel child) async {
    final marked = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParentMarkAbsentForm(child: child),
    );
    if (marked == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).markedAbsentSnack(child.fullName)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<bool> _showDeleteSheet(ChildModel child) async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParentDeleteChildForm(child: child),
    );
    if (deleted == true && mounted) _load();
    return deleted == true;
  }

  Future<void> _showEditAbsenceSheet(ChildModel child, AbsenceModel absence) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParentEditAbsenceForm(child: child, absence: absence),
    );
    if (updated == true && mounted) _load();
  }

  Future<void> _showCancelAbsenceSheet(ChildModel child, AbsenceModel absence) async {
    final cancelled = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParentCancelAbsenceForm(child: child, absence: absence),
    );
    if (cancelled == true && mounted) _load();
  }
}

// ── Child actions sheet ─────────────────────────────────────────────────────

class _ChildActionsSheet extends StatefulWidget {
  final ChildModel child;
  final VoidCallback onEditDetails;
  final VoidCallback onChangePhoto;
  final VoidCallback onMarkAbsent;
  final void Function(AbsenceModel) onEditAbsence;
  final void Function(AbsenceModel) onCancelAbsence;
  final VoidCallback onRemoveChild;

  const _ChildActionsSheet({
    required this.child,
    required this.onEditDetails,
    required this.onChangePhoto,
    required this.onMarkAbsent,
    required this.onEditAbsence,
    required this.onCancelAbsence,
    required this.onRemoveChild,
  });

  @override
  State<_ChildActionsSheet> createState() => _ChildActionsSheetState();
}

class _ChildActionsSheetState extends State<_ChildActionsSheet> {
  static const blue = Color(0xFF0D4896);

  AbsenceModel? _activeAbsence;
  bool _loadingAbsence = true;

  @override
  void initState() {
    super.initState();
    _loadActiveAbsence();
  }

  Future<void> _loadActiveAbsence() async {
    try {
      final absences = await ChildService.getChildAbsences(widget.child.id);
      final today = DateTime.now();
      AbsenceModel? active;
      for (final a in absences) {
        if (!a.isActive) continue;
        try {
          final end = DateTime.parse(a.endDate);
          if (!end.isBefore(DateTime(today.year, today.month, today.day))) {
            active = a;
            break;
          }
        } catch (_) {
          active = a;
          break;
        }
      }
      if (mounted) {
        setState(() {
          _activeAbsence = active;
          _loadingAbsence = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAbsence = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    final grade = widget.child.grade;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: onSurface.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  _ChildPhotoAvatar(childId: widget.child.id, radius: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.child.fullName,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: onSurface)),
                        if (grade != null && grade.isNotEmpty)
                          Text(grade,
                              style: TextStyle(
                                  color: onSurface.withOpacity(0.5),
                                  fontSize: 13)),
                      ],
                    ),
                  ),
                  if (_activeAbsence != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(AppLocalizations.of(context).absent,
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: borderColor, height: 1),
            SheetTile(
              icon: IconsaxPlusLinear.edit,
              iconColor: blue,
              label: AppLocalizations.of(context).editDetails,
              subtitle: AppLocalizations.of(context).editDetailsSubtitle,
              onTap: widget.onEditDetails,
            ),
            Divider(color: borderColor, height: 1, indent: 68),
            SheetTile(
              icon: IconsaxPlusLinear.gallery_edit,
              iconColor: const Color(0xFF5A7FBF),
              label: AppLocalizations.of(context).changePhoto,
              subtitle: AppLocalizations.of(context).changePhotoSubtitle,
              onTap: widget.onChangePhoto,
            ),
            Divider(color: borderColor, height: 1, indent: 68),
            if (_loadingAbsence)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onSurface.withOpacity(0.4),
                  ),
                ),
              )
            else if (_activeAbsence != null) ...[
              SheetTile(
                icon: IconsaxPlusLinear.calendar_edit,
                iconColor: Colors.orange,
                label: AppLocalizations.of(context).editAbsenceAction,
                subtitle: AppLocalizations.of(context).editAbsenceSubtitle,
                onTap: () => widget.onEditAbsence(_activeAbsence!),
              ),
              Divider(color: borderColor, height: 1, indent: 68),
              SheetTile(
                icon: IconsaxPlusLinear.calendar_tick,
                iconColor: Colors.green,
                label: AppLocalizations.of(context).cancelAbsenceAction,
                subtitle: AppLocalizations.of(context)
                    .cancelAbsenceSubtitle(widget.child.fullName),
                onTap: () => widget.onCancelAbsence(_activeAbsence!),
              ),
            ] else
              SheetTile(
                icon: IconsaxPlusLinear.calendar_remove,
                iconColor: Colors.orange,
                label: AppLocalizations.of(context).markAsAbsentAction,
                subtitle: AppLocalizations.of(context).markAsAbsentSubtitle,
                onTap: widget.onMarkAbsent,
              ),
            Divider(color: borderColor, height: 1, indent: 68),
            SheetTile(
              icon: IconsaxPlusLinear.trash,
              iconColor: Colors.red,
              label: AppLocalizations.of(context).removeChildAction,
              subtitle: AppLocalizations.of(context).removeChildSubtitle,
              labelColor: Colors.red,
              onTap: widget.onRemoveChild,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ChildTile extends StatefulWidget {
  final ChildModel child;
  final VoidCallback? onTap;
  const _ChildTile({required this.child, this.onTap});

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  Uint8List? _photoBytes;
  AbsenceModel? _activeAbsence;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
    _loadAbsences();
  }

  Future<void> _loadPhoto() async {
    final childId = widget.child.id;
    if (childId.isEmpty) return;
    try {
      final bytes = await ChildService.getChildPhotoBytes(childId);
      if (mounted) setState(() => _photoBytes = bytes);
    } catch (_) {}
  }

  Future<void> _loadAbsences() async {
    final childId = widget.child.id;
    if (childId.isEmpty) return;
    try {
      final absences = await ChildService.getChildAbsences(childId);
      AbsenceModel? active;
      for (final a in absences) {
        if (a.isActive && _absenceIsRelevant(a)) {
          active = a;
          break;
        }
      }
      if (mounted) setState(() => _activeAbsence = active);
    } catch (_) {}
  }

  /// Returns true if the absence covers today or a future date.
  bool _absenceIsRelevant(AbsenceModel a) {
    try {
      final end = DateTime.parse(a.endDate);
      return !end.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;

    final name = widget.child.fullName;
    final grade = widget.child.grade;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _activeAbsence != null
                    ? Colors.orange.withOpacity(0.55)
                    : borderColor,
                width: _activeAbsence != null ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFEBF1FE),
                      backgroundImage: _photoBytes != null
                          ? MemoryImage(_photoBytes!)
                          : null,
                      child: _photoBytes == null
                          ? const Icon(IconsaxPlusLinear.user,
                              color: blue, size: 28)
                          : null,
                    ),
                    if (_activeAbsence != null)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: cardBg, width: 2),
                          ),
                          child: const Icon(
                            IconsaxPlusLinear.calendar_remove,
                            color: Colors.white,
                            size: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (grade != null && grade.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    grade,
                    style: TextStyle(
                        color: onSurface.withOpacity(0.5), fontSize: 12),
                  ),
                ],
                if (_activeAbsence != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context).absent,
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Icon(
                    IconsaxPlusLinear.more_circle,
                    size: 16,
                    color: onSurface.withOpacity(0.28),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Child photo avatar (used in action sheet header) ────────────────────────

class _ChildPhotoAvatar extends StatefulWidget {
  final String childId;
  final double radius;
  const _ChildPhotoAvatar({required this.childId, this.radius = 24});

  @override
  State<_ChildPhotoAvatar> createState() => _ChildPhotoAvatarState();
}

class _ChildPhotoAvatarState extends State<_ChildPhotoAvatar> {
  static const blue = Color(0xFF0D4896);
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    ChildService.getChildPhotoBytes(widget.childId)
        .then((b) { if (mounted && b != null) setState(() => _bytes = b); })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: const Color(0xFFEBF1FE),
      backgroundImage: _bytes != null ? MemoryImage(_bytes!) : null,
      child: _bytes == null
          ? Icon(IconsaxPlusLinear.user, color: blue, size: widget.radius * 0.8)
          : null,
    );
  }
}
