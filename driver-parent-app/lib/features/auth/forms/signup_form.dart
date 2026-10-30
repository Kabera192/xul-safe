import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../services/auth_api_service.dart';
import '../registration_otp_page.dart';
import '../widgets/auth_field_input.dart';
import '../widgets/auth_form_shell.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignupForm({super.key, required this.onSwitch});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex =
        RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    return emailRegex.hasMatch(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthApiService.register(
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        phoneNumber: _phoneCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegistrationOtpPage(email: _emailCtrl.text.trim()),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFormShell(
      title: l10n.createYourAccount,
      subtitle: l10n.registerSubtitle,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 380),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthFieldInput(
                    label: l10n.firstName,
                    controller: _firstNameCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.firstNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthFieldInput(
                    label: l10n.lastName,
                    controller: _lastNameCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.lastNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthFieldInput(
                    label: l10n.phoneNumber,
                    controller: _phoneCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.phoneRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthFieldInput(
                    label: l10n.emailAddress,
                    controller: _emailCtrl,
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
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.moreFieldsBelow,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AuthFieldInput(
                    label: l10n.password,
                    controller: _passwordCtrl,
                    obscure: true,
                    showEye: true,
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
                      if (!RegExp(r'[0-9]').hasMatch(v)) {
                        return l10n.appPasswordNeedsNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthFieldInput(
                    label: l10n.confirmPassword,
                    controller: _confirmCtrl,
                    obscure: true,
                    showEye: true,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D4896),
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
                              l10n.createAccount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: widget.onSwitch,
                      child: Text(
                        l10n.alreadyHaveAccount,
                        style: const TextStyle(
                          color: Color(0xFF0D4896),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
