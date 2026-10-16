import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/absence_model.dart';
import '../models/child_model.dart';

/// Bottom-sheet form for editing an existing absence. Pops `true` on success.
class ParentEditAbsenceForm extends StatefulWidget {
  final ChildModel child;
  final AbsenceModel absence;

  const ParentEditAbsenceForm({
    super.key,
    required this.child,
    required this.absence,
  });

  @override
  State<ParentEditAbsenceForm> createState() => _ParentEditAbsenceFormState();
}

class _ParentEditAbsenceFormState extends State<ParentEditAbsenceForm> {
  static const blue = Color(0xFF0D4896);

  late String _selectedJourney;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _multiDay;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedJourney = widget.absence.absenceType;
    _startDate = parseSheetDate(widget.absence.startDate) ?? DateTime.now();
    _endDate = parseSheetDate(widget.absence.endDate) ?? _startDate;
    _multiDay = !_startDate.isAtSameMomentAs(_endDate) && _endDate.isAfter(_startDate);
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ChildService.updateAbsence(
        childId: widget.child.id,
        absenceId: widget.absence.id,
        absenceType: _multiDay ? 'MULTIPLE_DAYS' : _selectedJourney,
        startDate: formatSheetDate(_startDate),
        endDate: formatSheetDate(_endDate),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(onBack: () => Navigator.of(context).pop()),
          SheetIconHeading(
            icon: IconsaxPlusLinear.calendar_edit,
            color: Colors.orange,
            title: l10n.editAbsenceTitle(widget.child.fullName),
            subtitle: l10n.updateDatesOrJourney,
          ),
          const SizedBox(height: 22),
          SectionLabel(label: l10n.journeyLabel, color: onSurface),
          const SizedBox(height: 8),
          SegmentedJourneyPicker(
            selected: _selectedJourney,
            fill: inputFill,
            border: borderColor,
            onSurface: onSurface,
            onChanged: (v) => setState(() => _selectedJourney = v),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.multipleDays,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                    fontSize: 14.5,
                  ),
                ),
              ),
              Switch(
                value: _multiDay,
                activeColor: blue,
                onChanged: (v) => setState(() {
                  _multiDay = v;
                  if (!v) _endDate = _startDate;
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DatePickerRow(
            label: _multiDay ? l10n.startDate : l10n.dateLabel,
            selected: _startDate,
            fill: inputFill,
            border: borderColor,
            textColor: onSurface,
            onPicked: (d) => setState(() {
              _startDate = d;
              if (_endDate.isBefore(d)) _endDate = d;
            }),
          ),
          if (_multiDay) ...[
            const SizedBox(height: 12),
            DatePickerRow(
              label: l10n.endDate,
              selected: _endDate,
              fill: inputFill,
              border: borderColor,
              textColor: onSurface,
              onPicked: (d) => setState(() => _endDate = d),
              firstDate: _startDate,
            ),
          ],
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
                  color: Colors.orange,
                  onTap: _saving ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
