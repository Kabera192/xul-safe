import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/config/theme_service.dart';
import '../../../core/session/session_storage.dart';
import '../../../mobile_authentication.dart';
import '../models/driver_profile_edit_mode.dart';
import '../models/driver_profile_model.dart';

class DriverProfileForm extends StatelessWidget {
  final DriverProfileModel? profile;
  final bool loading;
  final String? error;
  final void Function(DriverProfileEditMode mode)? onEditTap;
  final VoidCallback? onBusRouteTap;

  const DriverProfileForm({
    super.key,
    required this.profile,
    required this.loading,
    required this.error,
    this.onEditTap,
    this.onBusRouteTap,
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
    final settingsBg = isDark ? const Color(0xFF1A2530) : const Color(0xFFEDF4FD);
    final stroke = isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);

    final fullName = profile?.fullName ?? '';
    final email = profile?.email ?? '';
    final phoneNumber = profile?.phoneNumber ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Conductor profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
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
                    onTap: () => onEditTap?.call(DriverProfileEditMode.fullName),
                  ),
                  Divider(height: 1, color: stroke),
                  _ProfileFieldRow(
                    text: email,
                    icon: IconsaxPlusLinear.edit_2,
                    onTap: () => onEditTap?.call(DriverProfileEditMode.email),
                  ),
                  Divider(height: 1, color: stroke),
                  _ProfileFieldRow(
                    text: phoneNumber,
                    icon: IconsaxPlusLinear.edit_2,
                    onTap: () =>
                        onEditTap?.call(DriverProfileEditMode.phoneNumber),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          _ProfileButtonCard(
            bgColor: settingsBg,
            leftIcon: IconsaxPlusLinear.setting_2,
            text: 'Bus & route settings',
            onTap: onBusRouteTap,
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: infoAndSignoutBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stroke, width: 1),
            ),
            child: Column(
              children: [
                _DriverActionRow(
                  text: 'Theme',
                  rightWidget: const _ThemeDot(),
                  onTap: () => ThemeService.toggle(),
                ),
                Divider(height: 1, color: stroke),
                _DriverActionRow(
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

class _DriverActionRow extends StatelessWidget {
  final String text;
  final IconData? rightIcon;
  final Widget? rightWidget;
  final VoidCallback? onTap;

  const _DriverActionRow({
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

class _ProfileButtonCard extends StatelessWidget {
  final IconData? leftIcon;
  final String text;
  final VoidCallback? onTap;
  final Color bgColor;

  const _ProfileButtonCard({
    this.leftIcon,
    required this.text,
    required this.onTap,
    required this.bgColor,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: stroke, width: 1),
          ),
          child: Row(
            children: [
              if (leftIcon != null) ...[
                Icon(leftIcon, size: 18, color: blue),
                const SizedBox(width: 10),
              ],
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
            ],
          ),
        ),
      ),
    );
  }
}