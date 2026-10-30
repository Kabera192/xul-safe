import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../widgets/mobile_splash_gradient.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  const NewPasswordPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  String? _error;

  static const blue = Color(0xFF0D4896);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': widget.otp,
          'newPassword': _passwordCtrl.text,
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        _showSuccess();
      } else {
        final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        setState(() {
          _error = (decoded is Map ? decoded['message'] : null) ??
              l10n.appFailedToResetPassword;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.couldNotReachServer);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text(l10n.appPasswordResetTitle),
          ],
        ),
        content: Text(l10n.appPasswordResetBody),
        actions: [
          TextButton(
            onPressed: () {
              // Pop dialog, then pop all pages back to login
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              l10n.signIn,
              style: const TextStyle(color: blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFE0E0E0);
    final fillColor =
        isDark ? const Color(0xFF1A2530) : const Color(0xFFF7F9FC);

    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_login.svg',
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.only(bottom: keyboard),
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24)
                    .copyWith(top: 32, bottom: 32),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appCreateNewPasswordTitle,
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appNewPasswordRequirements,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // New password
                      _PasswordField(
                        label: l10n.appNewPasswordLabel,
                        controller: _passwordCtrl,
                        hidden: _hidePassword,
                        onToggle: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        fillColor: fillColor,
                        borderColor: borderColor,
                        onSurface: onSurface,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (v.length < 8) {
                            return l10n.passwordMin8;
                          }
                          if (v.contains(' ')) {
                            return l10n.appPasswordNoSpaces;
                          }
                          if (!v.contains(RegExp(r'[0-9]'))) {
                            return l10n.appPasswordNeedsNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm password
                      _PasswordField(
                        label: l10n.confirmPassword,
                        controller: _confirmCtrl,
                        hidden: _hideConfirm,
                        onToggle: () =>
                            setState(() => _hideConfirm = !_hideConfirm),
                        fillColor: fillColor,
                        borderColor: borderColor,
                        onSurface: onSurface,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.pleaseConfirmPassword;
                          }
                          if (v != _passwordCtrl.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.appResetPasswordButton,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
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

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hidden;
  final VoidCallback onToggle;
  final Color fillColor;
  final Color borderColor;
  final Color onSurface;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.hidden,
    required this.onToggle,
    required this.fillColor,
    required this.borderColor,
    required this.onSurface,
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
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: hidden,
          validator: validator,
          style: TextStyle(color: onSurface, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: onSurface.withValues(alpha: 0.5),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D4896), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
