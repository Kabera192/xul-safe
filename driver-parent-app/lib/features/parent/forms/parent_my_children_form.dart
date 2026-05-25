import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/session/session_storage.dart';
import '../../../services/child_service.dart';

class ParentMyChildrenForm extends StatefulWidget {
  final VoidCallback? onRequestRefresh;
  const ParentMyChildrenForm({super.key, this.onRequestRefresh});

  @override
  State<ParentMyChildrenForm> createState() => _ParentMyChildrenFormState();
}

class _ParentMyChildrenFormState extends State<ParentMyChildrenForm> {
  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  List<Map<String, dynamic>> _children = [];
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
                      const Text(
                        'Did you know?',
                        style: TextStyle(
                          color: blue,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can mark your students as absent easily by tapping them and select absent action.',
                        style: TextStyle(
                          color: onSurface.withOpacity(0.6),
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
                    TextButton(onPressed: _load, child: const Text('Retry')),
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
                      'No children added yet',
                      style: TextStyle(
                        color: onSurface.withOpacity(0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add your first child',
                      style: TextStyle(color: onSurface.withOpacity(0.45), fontSize: 13),
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
                childAspectRatio: 0.78,
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

  // â”€â”€ Action sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showChildActions(Map<String, dynamic> child) {
    final name = child['fullName']?.toString() ?? 'Child';
    final grade = child['grade']?.toString();
    final childId = child['id']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ChildActionsSheet(
        child: child,
        name: name,
        grade: grade,
        childId: childId,
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

  // â”€â”€ Edit sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _showEditSheet(Map<String, dynamic> child) async {
    final childId = child['id']?.toString() ?? '';
    final formKey = GlobalKey<FormState>();
    final nameCtrl =
        TextEditingController(text: child['fullName']?.toString() ?? '');
    final gradeCtrl =
        TextEditingController(text: child['grade']?.toString() ?? '');
    String? selectedGender = child['gender']?.toString();
    DateTime? selectedBirthDate;
    final rawBirth = child['birthDate']?.toString();
    if (rawBirth != null && rawBirth.isNotEmpty) {
      try {
        selectedBirthDate = DateTime.parse(rawBirth);
      } catch (_) {}
    }
    bool saving = false;
    String? sheetError;
    bool updated = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final inputFill =
              isDark ? const Color(0xFF1A2530) : const Color(0xFFF6F9FE);
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
          final keyboard = MediaQuery.of(ctx).viewInsets.bottom;

          return Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, keyboard + 16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 16),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(ctx).pop(),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E3050)
                                        : const Color(0xFFEBF1FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 16,
                                    color: onSurface,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: onSurface.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 34),
                            ],
                          ),
                        ),
                        Text('Edit details',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: onSurface)),
                        const SizedBox(height: 4),
                        Text('Changes will be saved immediately.',
                            style: TextStyle(
                                color: onSurface.withOpacity(0.5),
                                fontSize: 13)),
                        const SizedBox(height: 22),
                        _SheetInput(
                          label: 'Full name *',
                          controller: nameCtrl,
                          fill: inputFill,
                          border: borderColor,
                          textColor: onSurface,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        _DatePickerRow(
                          label: 'Date of birth',
                          selected: selectedBirthDate,
                          fill: inputFill,
                          border: borderColor,
                          textColor: onSurface,
                          onPicked: (d) =>
                              setSheetState(() => selectedBirthDate = d),
                        ),
                        const SizedBox(height: 14),
                        _GenderPicker(
                          value: selectedGender,
                          fill: inputFill,
                          border: borderColor,
                          textColor: onSurface,
                          onChanged: (v) =>
                              setSheetState(() => selectedGender = v),
                        ),
                        const SizedBox(height: 14),
                        _SheetInput(
                          label: 'Grade',
                          hint: 'e.g. Grade 3',
                          controller: gradeCtrl,
                          fill: inputFill,
                          border: borderColor,
                          textColor: onSurface,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final trimmed = v.trim();
                            final match = RegExp(
                              r'^Grade\s+(\d+)$',
                            ).firstMatch(trimmed);
                            if (match == null) {
                              return 'Use format: Grade 3';
                            }
                            final n = int.parse(match.group(1)!);
                            if (n < 1 || n > 13) {
                              return 'Grade must be between 1 and 13';
                            }
                            return null;
                          },
                        ),
                        if (sheetError != null) ...[
                          const SizedBox(height: 12),
                          Text(sheetError!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ],
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _SheetButton(
                                label: 'Cancel',
                                outlined: true,
                                textColor: onSurface,
                                borderColor: borderColor,
                                onTap: saving
                                    ? null
                                    : () => Navigator.of(ctx).pop(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SheetButton(
                                label: saving ? '' : 'Save changes',
                                loading: saving,
                                onTap: saving
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!
                                            .validate()) return;
                                        setSheetState(() {
                                          saving = true;
                                          sheetError = null;
                                        });
                                        final bdStr =
                                            selectedBirthDate != null
                                                ? _fmtDate(selectedBirthDate!)
                                                : null;
                                        try {
                                          await ChildService.updateChild(
                                            childId: childId,
                                            fullName: nameCtrl.text,
                                            birthDate: bdStr,
                                            gender: selectedGender,
                                            grade: gradeCtrl.text.trim(),
                                          );
                                          updated = true;
                                          if (ctx.mounted)
                                            Navigator.of(ctx).pop();
                                        } catch (e) {
                                          setSheetState(() {
                                            saving = false;
                                            sheetError = e
                                                .toString()
                                                .replaceFirst(
                                                    'Exception: ', '');
                                          });
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          );
        },
      ),
    );
    if (updated && mounted) _load();
  }

  // â”€â”€ Photo sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _showPhotoSheet(Map<String, dynamic> child) async {
    final childId = child['id']?.toString() ?? '';
    File? selectedFile;
    bool saving = false;
    String? sheetError;
    bool updated = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
          final uploadBg =
              isDark ? const Color(0xFF1A2530) : const Color(0xFFF1F5FA);

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3050)
                                    : const Color(0xFFEBF1FE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: onSurface.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                    ),
                    Text('Change photo',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: onSurface)),
                    const SizedBox(height: 4),
                    Text(
                        'Tap the box below to choose a photo from your gallery.',
                        style: TextStyle(
                            color: onSurface.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 22),
                    // Upload box
                    GestureDetector(
                      onTap: saving
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85);
                              if (picked != null) {
                                setSheetState(() =>
                                    selectedFile = File(picked.path));
                              }
                            },
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: uploadBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: borderColor.withOpacity(0.8),
                              width: 1.5,
                              style: BorderStyle.solid),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: selectedFile != null
                              ? Image.file(selectedFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(IconsaxPlusLinear.gallery_add,
                                        size: 38,
                                        color: onSurface.withOpacity(0.35)),
                                    const SizedBox(height: 10),
                                    Text('Tap to select photo',
                                        style: TextStyle(
                                            color:
                                                onSurface.withOpacity(0.45),
                                            fontSize: 14)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    if (sheetError != null) ...[
                      const SizedBox(height: 12),
                      Text(sheetError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Cancel',
                            outlined: true,
                            textColor: onSurface,
                            borderColor: borderColor,
                            onTap: saving
                                ? null
                                : () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SheetButton(
                            label: saving ? '' : 'Upload photo',
                            loading: saving,
                            onTap: (saving || selectedFile == null)
                                ? null
                                : () async {
                                    setSheetState(() {
                                      saving = true;
                                      sheetError = null;
                                    });
                                    try {
                                      await ChildService.uploadChildPhoto(
                                        childId: childId,
                                        imageFile: selectedFile!,
                                      );
                                      updated = true;
                                      if (ctx.mounted)
                                        Navigator.of(ctx).pop();
                                    } catch (e) {
                                      setSheetState(() {
                                        saving = false;
                                        sheetError = e
                                            .toString()
                                            .replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (updated && mounted) _load();
  }

  // â”€â”€ Absent sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _showAbsentSheet(Map<String, dynamic> child) async {
    final childId = child['id']?.toString() ?? '';
    final name = child['fullName']?.toString() ?? 'Child';
    String selectedJourney = 'MORNING';
    final today = DateTime.now();
    DateTime startDate = today;
    DateTime endDate = today;
    bool multiDay = false;
    bool saving = false;
    String? sheetError;
    bool marked = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final inputFill =
              isDark ? const Color(0xFF1A2530) : const Color(0xFFF6F9FE);
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3050)
                                    : const Color(0xFFEBF1FE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: onSurface.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                    ),
                    // Orange icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          IconsaxPlusLinear.calendar_remove,
                          color: Colors.orange,
                          size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text('Mark $name absent',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: onSurface)),
                    const SizedBox(height: 4),
                    Text(
                        'The driver will be notified and the child will be marked as absent.',
                        style: TextStyle(
                            color: onSurface.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 22),
                    // Journey type
                    _SectionLabel(label: 'Journey', color: onSurface),
                    const SizedBox(height: 8),
                    _SegmentedJourneyPicker(
                      selected: selectedJourney,
                      fill: inputFill,
                      border: borderColor,
                      onSurface: onSurface,
                      onChanged: (v) =>
                          setSheetState(() => selectedJourney = v),
                    ),
                    const SizedBox(height: 18),
                    // Multi-day toggle
                    Row(
                      children: [
                        Expanded(
                          child: Text('Multiple days',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                  fontSize: 14.5)),
                        ),
                        Switch(
                          value: multiDay,
                          activeColor: blue,
                          onChanged: (v) => setSheetState(() {
                            multiDay = v;
                            if (!v) endDate = startDate;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DatePickerRow(
                      label: multiDay ? 'Start date' : 'Date',
                      selected: startDate,
                      fill: inputFill,
                      border: borderColor,
                      textColor: onSurface,
                      onPicked: (d) => setSheetState(() {
                        startDate = d;
                        if (endDate.isBefore(d)) endDate = d;
                      }),
                    ),
                    if (multiDay) ...[
                      const SizedBox(height: 12),
                      _DatePickerRow(
                        label: 'End date',
                        selected: endDate,
                        fill: inputFill,
                        border: borderColor,
                        textColor: onSurface,
                        onPicked: (d) => setSheetState(() => endDate = d),
                        firstDate: startDate,
                      ),
                    ],
                    if (sheetError != null) ...[
                      const SizedBox(height: 12),
                      Text(sheetError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Cancel',
                            outlined: true,
                            textColor: onSurface,
                            borderColor: borderColor,
                            onTap: saving
                                ? null
                                : () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SheetButton(
                            label: saving ? '' : 'Mark absent',
                            loading: saving,
                            color: Colors.orange,
                            onTap: saving
                                ? null
                                : () async {
                                    setSheetState(() {
                                      saving = true;
                                      sheetError = null;
                                    });
                                    try {
                                      final parentId =
                                          await SessionStorage.getUserId();
                                      await ChildService.createAbsence(
                                        childId: childId,
                                        absenceType: multiDay
                                            ? 'MULTIPLE_DAYS'
                                            : selectedJourney,
                                        startDate: _fmtDate(startDate),
                                        endDate: _fmtDate(endDate),
                                        parentId: parentId ?? 0,
                                      );
                                      marked = true;
                                      if (ctx.mounted)
                                        Navigator.of(ctx).pop();
                                    } catch (e) {
                                      setSheetState(() {
                                        saving = false;
                                        sheetError = e
                                            .toString()
                                            .replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (marked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name marked absent'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // â”€â”€ Delete sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<bool> _showDeleteSheet(Map<String, dynamic> child) async {
    final childId = child['id']?.toString() ?? '';
    final name = child['fullName']?.toString() ?? 'this child';
    bool deleting = false;
    String? sheetError;
    bool deleted = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3050)
                                    : const Color(0xFFEBF1FE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: onSurface.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(IconsaxPlusLinear.trash,
                          color: Colors.red, size: 22),
                    ),
                    const SizedBox(height: 14),
                    Text('Remove "$name"?',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: onSurface)),
                    const SizedBox(height: 8),
                    Text(
                        'This will permanently delete this child record and all related data. This cannot be undone.',
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.4)),
                    if (sheetError != null) ...[
                      const SizedBox(height: 12),
                      Text(sheetError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Keep',
                            outlined: true,
                            textColor: onSurface,
                            borderColor: borderColor,
                            onTap: deleting
                                ? null
                                : () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SheetButton(
                            label: deleting ? '' : 'Yes, remove',
                            loading: deleting,
                            color: Colors.red,
                            onTap: deleting
                                ? null
                                : () async {
                                    setSheetState(() {
                                      deleting = true;
                                      sheetError = null;
                                    });
                                    try {
                                      await ChildService.deleteChild(childId);
                                      deleted = true;
                                      if (ctx.mounted)
                                        Navigator.of(ctx).pop();
                                    } catch (e) {
                                      setSheetState(() {
                                        deleting = false;
                                        sheetError = e
                                            .toString()
                                            .replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (deleted && mounted) _load();
    return deleted;
  }

  // ── Edit absence sheet ───────────────────────────────────────────────────────

  Future<void> _showEditAbsenceSheet(
      Map<String, dynamic> child, Map<String, dynamic> absence) async {
    final childId = child['id']?.toString() ?? '';
    final name = child['fullName']?.toString() ?? 'Child';
    final absenceId = int.tryParse(absence['id']?.toString() ?? '') ?? 0;

    String selectedJourney =
        absence['absenceType']?.toString() ?? 'MORNING';
    DateTime startDate = _parseDate(absence['startDate']?.toString()) ??
        DateTime.now();
    DateTime endDate =
        _parseDate(absence['endDate']?.toString()) ?? startDate;
    bool multiDay = !startDate.isAtSameMomentAs(endDate) &&
        endDate.isAfter(startDate);
    bool saving = false;
    String? sheetError;
    bool updated = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final inputFill =
              isDark ? const Color(0xFF1A2530) : const Color(0xFFF6F9FE);
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3050)
                                    : const Color(0xFFEBF1FE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: onSurface.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(IconsaxPlusLinear.calendar_edit,
                          color: Colors.orange, size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text('Edit $name\'s absence',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: onSurface)),
                    const SizedBox(height: 4),
                    Text('Update the dates or journey type.',
                        style: TextStyle(
                            color: onSurface.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 22),
                    _SectionLabel(label: 'Journey', color: onSurface),
                    const SizedBox(height: 8),
                    _SegmentedJourneyPicker(
                      selected: selectedJourney,
                      fill: inputFill,
                      border: borderColor,
                      onSurface: onSurface,
                      onChanged: (v) =>
                          setSheetState(() => selectedJourney = v),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Multiple days',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                  fontSize: 14.5)),
                        ),
                        Switch(
                          value: multiDay,
                          activeColor: blue,
                          onChanged: (v) => setSheetState(() {
                            multiDay = v;
                            if (!v) endDate = startDate;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DatePickerRow(
                      label: multiDay ? 'Start date' : 'Date',
                      selected: startDate,
                      fill: inputFill,
                      border: borderColor,
                      textColor: onSurface,
                      onPicked: (d) => setSheetState(() {
                        startDate = d;
                        if (endDate.isBefore(d)) endDate = d;
                      }),
                    ),
                    if (multiDay) ...[
                      const SizedBox(height: 12),
                      _DatePickerRow(
                        label: 'End date',
                        selected: endDate,
                        fill: inputFill,
                        border: borderColor,
                        textColor: onSurface,
                        onPicked: (d) =>
                            setSheetState(() => endDate = d),
                        firstDate: startDate,
                      ),
                    ],
                    if (sheetError != null) ...[
                      const SizedBox(height: 12),
                      Text(sheetError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Cancel',
                            outlined: true,
                            textColor: onSurface,
                            borderColor: borderColor,
                            onTap: saving
                                ? null
                                : () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SheetButton(
                            label: saving ? '' : 'Save changes',
                            loading: saving,
                            color: Colors.orange,
                            onTap: saving
                                ? null
                                : () async {
                                    setSheetState(() {
                                      saving = true;
                                      sheetError = null;
                                    });
                                    try {
                                      await ChildService.updateAbsence(
                                        childId: childId,
                                        absenceId: absenceId,
                                        absenceType: multiDay
                                            ? 'MULTIPLE_DAYS'
                                            : selectedJourney,
                                        startDate: _fmtDate(startDate),
                                        endDate: _fmtDate(endDate),
                                      );
                                      updated = true;
                                      if (ctx.mounted) {
                                        Navigator.of(ctx).pop();
                                      }
                                    } catch (e) {
                                      setSheetState(() {
                                        saving = false;
                                        sheetError = e
                                            .toString()
                                            .replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (updated && mounted) _load();
  }

  // ── Cancel absence sheet ─────────────────────────────────────────────────────

  Future<void> _showCancelAbsenceSheet(
      Map<String, dynamic> child, Map<String, dynamic> absence) async {
    final childId = child['id']?.toString() ?? '';
    final name = child['fullName']?.toString() ?? 'this child';
    final absenceId = int.tryParse(absence['id']?.toString() ?? '') ?? 0;
    final startFmt = absence['startDate']?.toString() ?? '';
    final endFmt = absence['endDate']?.toString() ?? '';
    bool cancelling = false;
    String? sheetError;
    bool cancelled = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3050)
                                    : const Color(0xFFEBF1FE),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: onSurface.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(IconsaxPlusLinear.calendar_tick,
                          color: Colors.green, size: 22),
                    ),
                    const SizedBox(height: 14),
                    Text('$name is available?',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: onSurface)),
                    const SizedBox(height: 8),
                    Text(
                        'This will cancel the absence marked from $startFmt'
                        '${endFmt != startFmt ? " to $endFmt" : ""}. '
                        'The driver will be notified that $name is back.',
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.4)),
                    if (sheetError != null) ...[
                      const SizedBox(height: 12),
                      Text(sheetError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _SheetButton(
                            label: 'Keep absence',
                            outlined: true,
                            textColor: onSurface,
                            borderColor: borderColor,
                            onTap: cancelling
                                ? null
                                : () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SheetButton(
                            label: cancelling ? '' : 'Yes, cancel it',
                            loading: cancelling,
                            color: Colors.green,
                            onTap: cancelling
                                ? null
                                : () async {
                                    setSheetState(() {
                                      cancelling = true;
                                      sheetError = null;
                                    });
                                    try {
                                      await ChildService.deleteAbsence(
                                        childId: childId,
                                        absenceId: absenceId,
                                      );
                                      cancelled = true;
                                      if (ctx.mounted) {
                                        Navigator.of(ctx).pop();
                                      }
                                    } catch (e) {
                                      setSheetState(() {
                                        cancelling = false;
                                        sheetError = e
                                            .toString()
                                            .replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (cancelled && mounted) _load();
  }

  static DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try { return DateTime.parse(s); } catch (_) { return null; }
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// â”€â”€ Child tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// ── Child actions sheet ───────────────────────────────────────────────────────────────

class _ChildActionsSheet extends StatefulWidget {
  final Map<String, dynamic> child;
  final String name;
  final String? grade;
  final String childId;
  final VoidCallback onEditDetails;
  final VoidCallback onChangePhoto;
  final VoidCallback onMarkAbsent;
  final void Function(Map<String, dynamic>) onEditAbsence;
  final void Function(Map<String, dynamic>) onCancelAbsence;
  final VoidCallback onRemoveChild;

  const _ChildActionsSheet({
    required this.child,
    required this.name,
    required this.grade,
    required this.childId,
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

  Map<String, dynamic>? _activeAbsence;
  bool _loadingAbsence = true;

  @override
  void initState() {
    super.initState();
    _loadActiveAbsence();
  }

  Future<void> _loadActiveAbsence() async {
    try {
      final absences = await ChildService.getChildAbsences(widget.childId);
      final today = DateTime.now();
      final active = absences
          .where((a) {
            if (a['status']?.toString().toUpperCase() != 'ACTIVE') return false;
            try {
              final end = DateTime.parse(a['endDate']?.toString() ?? '');
              return !end.isBefore(
                  DateTime(today.year, today.month, today.day));
            } catch (_) {
              return true;
            }
          })
          .cast<Map<String, dynamic>>()
          .firstOrNull;
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

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
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
                  _ChildPhotoAvatar(childId: widget.childId, radius: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: onSurface)),
                        if (widget.grade != null &&
                            widget.grade!.isNotEmpty)
                          Text(widget.grade!,
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
                      child: const Text('Absent',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: borderColor, height: 1),
            _SheetTile(
              icon: IconsaxPlusLinear.edit,
              iconColor: blue,
              label: 'Edit details',
              subtitle: 'Update name, grade or birth date',
              onTap: widget.onEditDetails,
            ),
            Divider(color: borderColor, height: 1, indent: 68),
            _SheetTile(
              icon: IconsaxPlusLinear.gallery_edit,
              iconColor: const Color(0xFF5A7FBF),
              label: 'Change photo',
              subtitle: 'Upload a profile picture',
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
              _SheetTile(
                icon: IconsaxPlusLinear.calendar_edit,
                iconColor: Colors.orange,
                label: 'Edit absence',
                subtitle: 'Change the dates or journey type',
                onTap: () => widget.onEditAbsence(_activeAbsence!),
              ),
              Divider(color: borderColor, height: 1, indent: 68),
              _SheetTile(
                icon: IconsaxPlusLinear.calendar_tick,
                iconColor: Colors.green,
                label: 'Cancel absence',
                subtitle: '${widget.name} is available, remove the absence',
                onTap: () => widget.onCancelAbsence(_activeAbsence!),
              ),
            ] else
              _SheetTile(
                icon: IconsaxPlusLinear.calendar_remove,
                iconColor: Colors.orange,
                label: 'Mark as absent',
                subtitle: 'Notify driver for one or more days',
                onTap: widget.onMarkAbsent,
              ),
            Divider(color: borderColor, height: 1, indent: 68),
            _SheetTile(
              icon: IconsaxPlusLinear.trash,
              iconColor: Colors.red,
              label: 'Remove child',
              subtitle: 'Permanently delete this record',
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
  final Map<String, dynamic> child;
  final VoidCallback? onTap;
  const _ChildTile({required this.child, this.onTap});

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  Uint8List? _photoBytes;
  Map<String, dynamic>? _activeAbsence;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
    _loadAbsences();
  }

  Future<void> _loadPhoto() async {
    final childId = widget.child['id']?.toString() ?? '';
    if (childId.isEmpty) return;
    try {
      final bytes = await ChildService.getChildPhotoBytes(childId);
      if (mounted) setState(() => _photoBytes = bytes);
    } catch (_) {}
  }

  Future<void> _loadAbsences() async {
    final childId = widget.child['id']?.toString() ?? '';
    if (childId.isEmpty) return;
    try {
      final absences = await ChildService.getChildAbsences(childId);
      final active = absences
          .where((a) =>
              (a['status']?.toString().toUpperCase() == 'ACTIVE') &&
              _absenceIsRelevant(a))
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      if (mounted) setState(() => _activeAbsence = active);
    } catch (_) {}
  }

  /// Returns true if the absence covers today or a future date.
  bool _absenceIsRelevant(Map<String, dynamic> a) {
    try {
      final end = DateTime.parse(a['endDate']?.toString() ?? '');
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

    final name = widget.child['fullName']?.toString() ?? 'Unknown';
    final grade = widget.child['grade']?.toString();

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
                    child: const Text(
                      'Absent',
                      style: TextStyle(
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

// â”€â”€ Child photo avatar (used in action sheet header) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€ Reusable sheet helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(label,
          style: TextStyle(
              color: labelColor ?? onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14.5)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: (labelColor ?? onSurface).withOpacity(0.5),
              fontSize: 12.5)),
      onTap: onTap,
    );
  }
}

class _SheetInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final Color fill;
  final Color border;
  final Color textColor;
  final String? Function(String?)? validator;

  const _SheetInput({
    required this.label,
    this.hint,
    required this.controller,
    required this.fill,
    required this.border,
    required this.textColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textColor.withOpacity(0.7))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: TextStyle(color: textColor, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: textColor.withOpacity(0.35), fontSize: 14),
            filled: true,
            fillColor: fill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D4896), width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? selected;
  final Color fill;
  final Color border;
  final Color textColor;
  final ValueChanged<DateTime> onPicked;
  final DateTime? firstDate;

  const _DatePickerRow({
    required this.label,
    required this.selected,
    required this.fill,
    required this.border,
    required this.textColor,
    required this.onPicked,
    this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    final display = selected != null
        ? '${selected!.year}-${selected!.month.toString().padLeft(2, '0')}-${selected!.day.toString().padLeft(2, '0')}'
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textColor.withOpacity(0.7))),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? (firstDate ?? DateTime(2015)),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      color: selected != null
                          ? textColor
                          : textColor.withOpacity(0.38),
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 18, color: textColor.withOpacity(0.45)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderPicker extends StatelessWidget {
  final String? value;
  final Color fill;
  final Color border;
  final Color textColor;
  final ValueChanged<String?> onChanged;

  const _GenderPicker({
    required this.value,
    required this.fill,
    required this.border,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textColor.withOpacity(0.7))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          style: TextStyle(color: textColor, fontSize: 15),
          dropdownColor: fill,
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D4896), width: 1.3),
            ),
          ),
          items: [
            DropdownMenuItem(
                value: 'MALE',
                child:
                    Text('Male', style: TextStyle(color: textColor))),
            DropdownMenuItem(
                value: 'FEMALE',
                child:
                    Text('Female', style: TextStyle(color: textColor))),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SegmentedJourneyPicker extends StatelessWidget {
  final String selected;
  final Color fill;
  final Color border;
  final Color onSurface;
  final ValueChanged<String> onChanged;

  static const blue = Color(0xFF0D4896);

  const _SegmentedJourneyPicker({
    required this.selected,
    required this.fill,
    required this.border,
    required this.onSurface,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      ('MORNING', 'Morning'),
      ('EVENING', 'Evening'),
    ];

    return Row(
      children: options.map((opt) {
        final isActive = selected == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt.$1),
            child: Container(
              margin: EdgeInsets.only(
                  right: opt.$1 == 'MORNING' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? blue.withOpacity(0.1)
                    : fill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isActive ? blue : border,
                    width: isActive ? 1.5 : 1),
              ),
              child: Center(
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    color: isActive ? blue : onSurface.withOpacity(0.7),
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color.withOpacity(0.7)));
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool loading;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;

  static const blue = Color(0xFF0D4896);

  const _SheetButton({
    required this.label,
    this.onTap,
    this.outlined = false,
    this.loading = false,
    this.color,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.transparent : (color ?? blue);
    final fg = outlined ? (textColor ?? blue) : Colors.white;
    final bd = outlined ? (borderColor ?? const Color(0xFFDCE6F5)) : bg;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bd, width: 1.3),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: fg),
                  )
                : Text(label,
                    style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
          ),
        ),
      ),
    );
  }
}
