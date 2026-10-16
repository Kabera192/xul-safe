import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/child_model.dart';

/// Bottom-sheet form for adding a child. Pops with the created [ChildModel]
/// on success (and uploads the selected photo, if any), or null if cancelled.
class ParentAddChildForm extends StatefulWidget {
  const ParentAddChildForm({super.key});

  @override
  State<ParentAddChildForm> createState() => _ParentAddChildFormState();
}

class _ParentAddChildFormState extends State<ParentAddChildForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  File? _selectedPhoto;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedPhoto = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final birthDateStr = _selectedBirthDate != null
        ? formatSheetDate(_selectedBirthDate!)
        : null;

    try {
      final newChild = await ChildService.addChild(
        fullName: _nameCtrl.text,
        birthDate: birthDateStr,
        gender: _selectedGender,
        grade: _gradeCtrl.text.trim(),
      );

      if (_selectedPhoto != null) {
        try {
          await ChildService.uploadChildPhoto(
            childId: newChild.id,
            imageFile: _selectedPhoto!,
          );
        } catch (_) {
          // Photo upload failure is non-fatal.
        }
      }

      if (mounted) Navigator.of(context).pop(newChild);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill =
        isDark ? const Color(0xFF1A2530) : const Color(0xFFF6F9FE);
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    return SheetShell(
      scrollable: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              onBack: _saving ? () {} : () => Navigator.of(context).pop(),
            ),
            SheetIconHeading(
              icon: IconsaxPlusLinear.user_add,
              color: const Color(0xFF0D4896),
              title: l10n.addAChild,
              subtitle: l10n.fillInChildDetails,
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: _saving ? null : _pickPhoto,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF1A2530) : const Color(0xFFF1F5FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _selectedPhoto != null
                      ? Image.file(
                          _selectedPhoto!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconsaxPlusLinear.gallery_add,
                              size: 32,
                              color: onSurface.withOpacity(0.35),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.addPhotoOptional,
                              style: TextStyle(
                                color: onSurface.withOpacity(0.45),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SheetInput(
              label: l10n.fullNameField,
              controller: _nameCtrl,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            const SizedBox(height: 14),
            DatePickerRow(
              label: l10n.dateOfBirthField,
              selected: _selectedBirthDate,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              firstDate: DateTime(2000),
              onPicked: (picked) =>
                  setState(() => _selectedBirthDate = picked),
            ),
            const SizedBox(height: 14),
            GenderPicker(
              value: _selectedGender,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              onChanged: (g) => setState(() => _selectedGender = g),
            ),
            const SizedBox(height: 14),
            SheetInput(
              label: l10n.gradeField,
              hint: l10n.gradeHint,
              controller: _gradeCtrl,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.required;
                final match = RegExp(r'^Grade\s+(\d+)$').firstMatch(v.trim());
                if (match == null) return l10n.gradeFormat;
                final n = int.parse(match.group(1)!);
                if (n < 1 || n > 13) return l10n.gradeRange;
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 22),
            SheetButton(
              label: l10n.addChild,
              loading: _saving,
              onTap: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
