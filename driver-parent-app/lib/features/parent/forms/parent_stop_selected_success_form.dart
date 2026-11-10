import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/app_localizations.dart';

/// Shown after picking an existing bus stop, which is assigned immediately
/// — distinct from ParentRequestStopSuccessForm, which is for a brand-new
/// stop request that still needs admin approval.
class ParentStopSelectedSuccessForm extends StatelessWidget {
  final VoidCallback onDone;

  const ParentStopSelectedSuccessForm({
    super.key,
    required this.onDone,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assests/backgrounds/mobile/success_checkmark.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                SvgPicture.asset(
                  'assests/backgrounds/mobile/edit_pen_shadow.svg',
                  height: 14,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              l10n.parStopSelectedTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.parStopSelectedBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                l10n.gotIt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
