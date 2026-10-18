import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/child_model.dart';

/// Bottom-sheet form for editing a child's details. Pops `true` if the
/// update succeeded, so the caller knows to refresh its list.
class ParentEditChildForm extends StatefulWidget {
  final ChildModel child;

  const ParentEditChildForm({super.key, required this.child});

  @override
  State<ParentEditChildForm> createState() => _ParentEditChildFormState();
}

class _ParentEditChildFormState extends State<ParentEditChildForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _gradeCtrl;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.child.fullName);
    _gradeCtrl = TextEditingController(text: widget.child.grade ?? '');
    _selectedGender = widget.child.gender;
    _selectedBirthDate = parseSheetDate(widget.child.birthDate);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final bdStr =
        _selectedBirthDate != null ? formatSheetDate(_selectedBirthDate!) : null;

    try {
      await ChildService.updateChild(
        childId: widget.child.id,
        fullName: _nameCtrl.text,
        birthDate: bdStr,
        gender: _selectedGender,
        grade: _gradeCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
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
            SheetHeader(onBack: () => Navigator.of(context).pop()),
            Text(
              l10n.editDetails,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.changesSavedImmediately,
              style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 13),
            ),
            const SizedBox(height: 22),
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
              label: l10n.dateOfBirthLabel,
              selected: _selectedBirthDate,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              onPicked: (d) => setState(() => _selectedBirthDate = d),
            ),
            const SizedBox(height: 14),
            GenderPicker(
              value: _selectedGender,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            const SizedBox(height: 14),
            SheetInput(
              label: l10n.gradeLabel,
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
            Row(
              children: [
                Expanded(
                  child: SheetButton(
                    label: l10n.cancel,
                    outlined: true,
                    textColor: onSurface,
                    borderColor: borderColor,
                    onTap: _saving ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SheetButton(
                    label: l10n.saveChanges,
                    loading: _saving,
                    onTap: _saving ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
