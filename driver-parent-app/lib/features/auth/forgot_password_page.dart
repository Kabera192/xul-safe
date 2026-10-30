import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../widgets/mobile_splash_gradient.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _loading = false;

  static const blue = Color(0xFF0D4896);

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/forgot-password');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailCtrl.text.trim()}),
      );

      if (!mounted) return;

      // The backend always returns 200 here, whether or not the email has
      // an account, so this can't be used to tell which emails are
      // registered. Only a non-200 (e.g. malformed email, server error)
      // stops here and surfaces the reason in a popup.
      if (res.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationPage(email: _emailCtrl.text.trim()),
          ),
        );
      } else {
        final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
        final message =
            (decoded is Map ? decoded['message'] as String? : null) ??
                l10n.appFailedToSendCode;
        _showErrorDialog(message);
      }
    } catch (_) {
      if (!mounted) return;
      _showErrorDialog(l10n.couldNotReachServerCheck);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => _ForgotPasswordErrorDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_login.svg',
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              // Card — padded up above the keyboard when it opens, since
              // resizeToAvoidBottomInset is off (would otherwise squash the
              // gradient background).
              AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.only(bottom: keyboard),
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24)
                    .copyWith(top: 32, bottom: 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                        l10n.forgotPassword,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appForgotPasswordIntro,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _AuthInput(
                        label: l10n.emailAddress,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        hintText: l10n.appEmailHintExample,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.emailRequired;
                          }
                          if (!_isValidEmail(v.trim())) {
                            return l10n.enterValidEmail;
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
                                  l10n.appSendCode,
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

// ── Error popup ─────────────────────────────────────────────────────────────

class _ForgotPasswordErrorDialog extends StatelessWidget {
  final String message;

  const _ForgotPasswordErrorDialog({required this.message});

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFE53935),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.appCouldNotSendCodeTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.retry,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared input widget for auth pages ────────────────────────────────────────

class _AuthInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final bool obscure;
  final String? Function(String?)? validator;

  const _AuthInput({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

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
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: onSurface.withValues(alpha: 0.35), fontSize: 14),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1A2530) : const Color(0xFFF7F9FC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2A3A50) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2A3A50) : const Color(0xFFE0E0E0),
              ),
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
