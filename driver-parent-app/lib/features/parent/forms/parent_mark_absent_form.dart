import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/session/session_storage.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_sheet_widgets.dart';
import '../models/child_model.dart';

/// Bottom-sheet form for marking a child absent. Pops `true` on success.
class ParentMarkAbsentForm extends StatefulWidget {
  final ChildModel child;

  const ParentMarkAbsentForm({super.key, required this.child});

  @override
  State<ParentMarkAbsentForm> createState() => _ParentMarkAbsentFormState();
}

class _ParentMarkAbsentFormState extends State<ParentMarkAbsentForm> {
  static const blue = Color(0xFF0D4896);

  String _selectedJourney = 'MORNING';
  late DateTime _startDate;
  late DateTime _endDate;
  bool _multiDay = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _startDate = today;
    _endDate = today;
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final parentId = await SessionStorage.getUserId();
      await ChildService.createAbsence(
        childId: widget.child.id,
        absenceType: _multiDay ? 'MULTIPLE_DAYS' : _selectedJourney,
        startDate: formatSheetDate(_startDate),
        endDate: formatSheetDate(_endDate),
        parentId: parentId ?? 0,
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
            icon: IconsaxPlusLinear.calendar_remove,
            color: Colors.orange,
            title: l10n.markAbsentTitle(widget.child.fullName),
            subtitle: l10n.driverNotifiedAbsent,
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
                  label: l10n.markAbsentBtn,
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
