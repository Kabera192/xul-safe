import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/child_model.dart';

/// Bottom-sheet confirmation for removing a child. Pops `true` if deleted.
class ParentDeleteChildForm extends StatefulWidget {
  final ChildModel child;

  const ParentDeleteChildForm({super.key, required this.child});

  @override
  State<ParentDeleteChildForm> createState() => _ParentDeleteChildFormState();
}

class _ParentDeleteChildFormState extends State<ParentDeleteChildForm> {
  bool _deleting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _deleting = true;
      _error = null;
    });

    try {
      await ChildService.deleteChild(widget.child.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _deleting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    return SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(onBack: () => Navigator.of(context).pop()),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(IconsaxPlusLinear.trash, color: Colors.red, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.removeChildTitle(widget.child.fullName),
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.removeChildBody,
            style: TextStyle(color: onSurface.withOpacity(0.55), fontSize: 14, height: 1.4),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SheetButton(
                  label: l10n.keep,
                  outlined: true,
                  textColor: onSurface,
                  borderColor: borderColor,
                  onTap: _deleting ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SheetButton(
                  label: l10n.yesRemove,
                  loading: _deleting,
                  color: Colors.red,
                  onTap: _deleting ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
