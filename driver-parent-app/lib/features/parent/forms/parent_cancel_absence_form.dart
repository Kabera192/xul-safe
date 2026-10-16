import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/absence_model.dart';
import '../models/child_model.dart';

/// Bottom-sheet confirmation for cancelling an absence. Pops `true` if cancelled.
class ParentCancelAbsenceForm extends StatefulWidget {
  final ChildModel child;
  final AbsenceModel absence;

  const ParentCancelAbsenceForm({
    super.key,
    required this.child,
    required this.absence,
  });

  @override
  State<ParentCancelAbsenceForm> createState() =>
      _ParentCancelAbsenceFormState();
}

class _ParentCancelAbsenceFormState extends State<ParentCancelAbsenceForm> {
  bool _cancelling = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _cancelling = true;
      _error = null;
    });

    try {
      await ChildService.deleteAbsence(
        childId: widget.child.id,
        absenceId: widget.absence.id,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _cancelling = false;
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

    final name = widget.child.fullName;
    final startFmt = widget.absence.startDate;
    final endFmt = widget.absence.endDate;

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
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(IconsaxPlusLinear.calendar_tick, color: Colors.green, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.nameIsAvailable(name),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            endFmt != startFmt
                ? l10n.cancelAbsenceRange(name, startFmt, endFmt)
                : l10n.cancelAbsenceSingle(name, startFmt),
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
                  label: l10n.keepAbsence,
                  outlined: true,
                  textColor: onSurface,
                  borderColor: borderColor,
                  onTap: _cancelling ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SheetButton(
                  label: l10n.yesCancelIt,
                  loading: _cancelling,
                  color: Colors.green,
                  onTap: _cancelling ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
