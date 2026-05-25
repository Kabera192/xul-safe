import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/config/theme_service.dart';
import '../../../core/session/session_storage.dart';
import '../../../mobile_authentication.dart';
import '../models/parent_profile_edit_mode.dart';
import '../models/parent_profile_model.dart';

class ParentProfileForm extends StatelessWidget {
  final ParentProfileModel? profile;
  final bool loading;
  final String? error;
  final void Function(ParentProfileEditMode mode)? onEditTap;

  const ParentProfileForm({
    super.key,
    required this.profile,
    required this.loading,
    required this.error,
    this.onEditTap,
  });

  static const blue = Color(0xFF0D4896);

  Future<void> _signOut(BuildContext context) async {
    await SessionStorage.clearSession();

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final infoAndSignoutBg = isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE6EDF6);
    final stroke = isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    final fullName = profile?.fullName ?? '';
    final email = profile?.email ?? '';
    final phoneNumber = profile?.phoneNumber ?? '';
    final maskedPassword = profile?.maskedPassword ?? '********';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Parent profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (loading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: infoAndSignoutBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: stroke, width: 1),
              ),
              child: Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: infoAndSignoutBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: stroke, width: 1),
              ),
              child: Column(
                children: [
                  _ProfileFieldRow(
                    text: fullName,
                    icon: IconsaxPlusLinear.edit_2,
                    onTap: () => onEditTap?.call(ParentProfileEditMode.fullName),
                  ),
                  const _PaddedDivider(),
                  _ProfileFieldRow(
                    text: email,
                    icon: IconsaxPlusLinear.edit_2,
                    onTap: () => onEditTap?.call(ParentProfileEditMode.email),
                  ),
                  const _PaddedDivider(),
                  _ProfileFieldRow(
                    text: phoneNumber,
                    icon: IconsaxPlusLinear.edit_2,
                    onTap: () => onEditTap?.call(ParentProfileEditMode.phoneNumber),
                  ),
                  const _PaddedDivider(),
                  _ProfileFieldRow(
                    text: maskedPassword,
                    icon: IconsaxPlusLinear.edit_2,
                    onTap: () => onEditTap?.call(ParentProfileEditMode.password),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: infoAndSignoutBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stroke, width: 1),
            ),
            child: Column(
              children: [
                _ProfileActionRow(
                  text: 'Theme',
                  rightWidget: const _ThemeDot(),
                  onTap: () => ThemeService.toggle(),
                ),
                const _PaddedDivider(),
                _ProfileActionRow(
                  text: 'Sign out',
                  rightIcon: IconsaxPlusLinear.logout,
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaddedDivider extends StatelessWidget {
  const _PaddedDivider();

  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1, color: stroke),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const _ProfileFieldRow({
    required this.text,
    required this.icon,
    this.onTap,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final row = SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onSurface.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(icon, size: 18, color: blue),
          ],
        ),
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: row,
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  final String text;
  final IconData? rightIcon;
  final Widget? rightWidget;
  final VoidCallback? onTap;

  const _ProfileActionRow({
    required this.text,
    this.rightIcon,
    this.rightWidget,
    required this.onTap,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (rightWidget != null) rightWidget!,
              if (rightWidget == null && rightIcon != null)
                Icon(rightIcon, size: 18, color: blue),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D4896);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDark ? 'Dark' : 'Light',
              style: const TextStyle(
                color: blue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDark ? Colors.black87 : blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}