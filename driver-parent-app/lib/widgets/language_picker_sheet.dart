import 'package:flutter/material.dart';

import '../core/l10n/app_localizations.dart';
import '../core/l10n/locale_service.dart';

/// Call this from anywhere to show the language picker.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _LanguagePickerSheet(),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  static const _options = [
    _LangOption(code: 'en', flag: '🇬🇧', nativeName: 'English'),
    _LangOption(code: 'fr', flag: '🇫🇷', nativeName: 'Français'),
    _LangOption(code: 'rw', flag: '🇷🇼', nativeName: 'Ikinyarwanda'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111C2B) : Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        isDark ? const Color(0xFF1E2D40) : const Color(0xFFE8EFF9);
    const blue = Color(0xFF0D4896);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 0,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            l10n.selectLanguage,
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          ValueListenableBuilder<Locale>(
            valueListenable: LocaleService.notifier,
            builder: (context, current, _) {
              return Column(
                children: _options.map((opt) {
                  final selected = current.languageCode == opt.code;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LanguageTile(
                      option: opt,
                      selected: selected,
                      isDark: isDark,
                      borderColor: borderColor,
                      blue: blue,
                      onSurface: onSurface,
                      onTap: () async {
                        await LocaleService.setLocale(Locale(opt.code));
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final _LangOption option;
  final bool selected;
  final bool isDark;
  final Color borderColor;
  final Color blue;
  final Color onSurface;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.isDark,
    required this.borderColor,
    required this.blue,
    required this.onSurface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (isDark ? const Color(0xFF0D2A5A) : const Color(0xFFEBF2FF))
        : (isDark ? const Color(0xFF1A2530) : Colors.white);
    final activeBorder = selected ? blue : borderColor;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: activeBorder, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Text(option.flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.nativeName,
                  style: TextStyle(
                    color: selected ? blue : onSurface,
                    fontSize: 16,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangOption {
  final String code;
  final String flag;
  final String nativeName;
  const _LangOption(
      {required this.code, required this.flag, required this.nativeName});
}
