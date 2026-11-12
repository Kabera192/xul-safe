import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/session/session_storage.dart';
import '../../services/auth_api_service.dart';
import '../../widgets/mobile_splash_gradient.dart';
import '../navigation/driver_nav.dart';
import '../navigation/parent_nav.dart';

/// Confirms the OTP sent to a just-registered account's email, then logs
/// the user straight in (mirrors otp_verification_page.dart's visuals, but
/// activates+signs in on success instead of moving to a password screen).
class RegistrationOtpPage extends StatefulWidget {
  final String email;
  const RegistrationOtpPage({super.key, required this.email});

  @override
  State<RegistrationOtpPage> createState() => _RegistrationOtpPageState();
}

class _RegistrationOtpPageState extends State<RegistrationOtpPage> {
  static const _digitCount = 6;
  static const blue = Color(0xFF0D4896);

  final _controllers =
      List.generate(_digitCount, (_) => TextEditingController());
  final _focusNodes = List.generate(_digitCount, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _goToHomeByRole(String role) {
    final normalizedRole = role.toUpperCase();
    final page =
        normalizedRole == 'DRIVER' ? const DriverNav() : const ParentNav();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final otp = _otp;
    if (otp.length < _digitCount) {
      setState(() => _error = l10n.appEnterAll6Digits);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthApiService.verifyRegistrationOtp(
        email: widget.email,
        otp: otp,
      );

      await SessionStorage.saveSession(
        token: result.token,
        refreshToken: result.refreshToken,
        tokenExpiresAt: result.tokenExpiresAt,
        refreshTokenExpiresAt: result.refreshTokenExpiresAt,
        userId: result.userId,
        role: result.role,
      );

      if (!mounted) return;
      _goToHomeByRole(result.role);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
    });
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    try {
      await AuthApiService.resendRegistrationOtp(email: widget.email);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appVerifyYourEmail,
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appOtpSentToEmailActivate(widget.email),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_digitCount, (i) {
                          final filled = _controllers[i].text.isNotEmpty;
                          return SizedBox(
                            width: 44,
                            height: 52,
                            child: TextFormField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              style: TextStyle(
                                color: onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (v) => _onDigitChanged(i, v),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1A2530)
                                    : const Color(0xFFF7F9FC),
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: filled
                                        ? blue
                                        : (isDark
                                            ? const Color(0xFF2A3A50)
                                            : const Color(0xFFE0E0E0)),
                                    width: filled ? 1.5 : 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: filled
                                        ? blue
                                        : (isDark
                                            ? const Color(0xFF2A3A50)
                                            : const Color(0xFFE0E0E0)),
                                    width: filled ? 1.5 : 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: blue, width: 2),
                                ),
                              ),
                            ),
                          );
                        }),
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
                          onPressed: _loading ? null : _verify,
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
                                  l10n.appVerifyAndContinue,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: _resending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: blue),
                              )
                            : TextButton(
                                onPressed: _resend,
                                child: Text(
                                  l10n.appResendCode,
                                  style: const TextStyle(
                                    color: blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ],
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
