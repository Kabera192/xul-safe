import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';

/// Bottom-sheet form for changing a child's photo. Pops `true` if the
/// upload succeeded.
class ParentChildPhotoForm extends StatefulWidget {
  final String childId;

  const ParentChildPhotoForm({super.key, required this.childId});

  @override
  State<ParentChildPhotoForm> createState() => _ParentChildPhotoFormState();
}

class _ParentChildPhotoFormState extends State<ParentChildPhotoForm> {
  File? _selectedFile;
  bool _saving = false;
  String? _error;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ChildService.uploadChildPhoto(
        childId: widget.childId,
        imageFile: _selectedFile!,
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
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    final uploadBg =
        isDark ? const Color(0xFF1A2530) : const Color(0xFFF1F5FA);

    return SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(onBack: () => Navigator.of(context).pop()),
          Text(
            l10n.changePhoto,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.choosePhotoFromGallery,
            style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _saving ? null : _pickPhoto,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: uploadBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor.withOpacity(0.8),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _selectedFile != null
                    ? Image.file(
                        _selectedFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconsaxPlusLinear.gallery_add,
                            size: 38,
                            color: onSurface.withOpacity(0.35),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.tapToSelectPhoto,
                            style: TextStyle(
                              color: onSurface.withOpacity(0.45),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
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
                  label: l10n.uploadPhoto,
                  loading: _saving,
                  onTap: (_saving || _selectedFile == null) ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
