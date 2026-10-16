import 'package:flutter/material.dart';

import '../core/l10n/app_localizations.dart';

/// Shared building blocks for the app's `showModalBottomSheet`-based forms
/// (child add/edit, absence marking, delete/cancel confirmations, etc).
/// Extracted so every sheet-style form reuses the same look instead of
/// redefining it inline.

/// Rounded-top container + SafeArea wrapper every bottom sheet uses.
class SheetShell extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const SheetShell({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
      child: child,
    );

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: scrollable ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}

/// Back-button + drag-handle row repeated at the top of every sheet.
class SheetHeader extends StatelessWidget {
  final VoidCallback onBack;

  const SheetHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
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
    );
  }
}

/// Icon-circle + title/subtitle pair used atop confirmation-style sheets
/// (mark absent, delete child, edit/cancel absence).
class SheetIconHeading extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const SheetIconHeading({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 13),
        ),
      ],
    );
  }
}

class SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final Color? labelColor;
  final VoidCallback? onTap;

  const SheetTile({
    super.key,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: (labelColor ?? onSurface).withOpacity(0.5),
          fontSize: 12.5,
        ),
      ),
      onTap: onTap,
    );
  }
}

class SheetInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final Color fill;
  final Color border;
  final Color textColor;
  final String? Function(String?)? validator;

  const SheetInput({
    super.key,
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
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: TextStyle(color: textColor, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textColor.withOpacity(0.35),
              fontSize: 14,
            ),
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF0D4896),
                width: 1.3,
              ),
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

class DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? selected;
  final Color fill;
  final Color border;
  final Color textColor;
  final ValueChanged<DateTime> onPicked;
  final DateTime? firstDate;

  const DatePickerRow({
    super.key,
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
        : AppLocalizations.of(context).selectDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textColor.withOpacity(0.7),
          ),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: textColor.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GenderPicker extends StatelessWidget {
  final String? value;
  final Color fill;
  final Color border;
  final Color textColor;
  final ValueChanged<String?> onChanged;

  const GenderPicker({
    super.key,
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
        Text(
          AppLocalizations.of(context).genderLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          style: TextStyle(color: textColor, fontSize: 15),
          dropdownColor: fill,
          decoration: InputDecoration(
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF0D4896),
                width: 1.3,
              ),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 'MALE',
              child: Text(
                AppLocalizations.of(context).male,
                style: TextStyle(color: textColor),
              ),
            ),
            DropdownMenuItem(
              value: 'FEMALE',
              child: Text(
                AppLocalizations.of(context).female,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class SegmentedJourneyPicker extends StatelessWidget {
  final String selected;
  final Color fill;
  final Color border;
  final Color onSurface;
  final ValueChanged<String> onChanged;

  static const _blue = Color(0xFF0D4896);

  const SegmentedJourneyPicker({
    super.key,
    required this.selected,
    required this.fill,
    required this.border,
    required this.onSurface,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      ('MORNING', AppLocalizations.of(context).morning),
      ('EVENING', AppLocalizations.of(context).evening),
    ];

    return Row(
      children: options.map((opt) {
        final isActive = selected == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt.$1),
            child: Container(
              margin: EdgeInsets.only(right: opt.$1 == 'MORNING' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? _blue.withOpacity(0.1) : fill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? _blue : border,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    color: isActive ? _blue : onSurface.withOpacity(0.7),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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

class SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const SectionLabel({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: color.withOpacity(0.7),
      ),
    );
  }
}

class SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool loading;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;

  static const _blue = Color(0xFF0D4896);

  const SheetButton({
    super.key,
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
    final bg = outlined ? Colors.transparent : (color ?? _blue);
    final fg = outlined ? (textColor ?? _blue) : Colors.white;
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
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// yyyy-MM-dd formatting/parsing shared by every sheet that deals with dates.
String formatSheetDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? parseSheetDate(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}
