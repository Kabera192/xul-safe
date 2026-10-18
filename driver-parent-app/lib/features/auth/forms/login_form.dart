import 'package:flutter/material.dart';

import '../../../core/session/session_storage.dart';
import '../../../services/auth_api_service.dart';
import '../../navigation/driver_nav.dart';
import '../../navigation/parent_nav.dart';
import '../forgot_password_page.dart';
import '../widgets/auth_field_input.dart';
import '../widgets/auth_form_shell.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginForm({super.key, required this.onSwitch});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _goToHomeByRole(String role) {
    final normalizedRole = role.toUpperCase();

    final page =
        normalizedRole == 'DRIVER' ? const DriverNav() : const ParentNav();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthApiService.login(
        identifier: _identifierCtrl.text,
        password: _passwordCtrl.text,
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

  @override
  Widget build(BuildContext context) {
    return AuthFormShell(
      title: 'Welcome back!',
      subtitle:
          'Please provide your login information to sign in to your account.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              AuthFieldInput(
                label: 'Email or phone number',
                controller: _identifierCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthFieldInput(
                label: 'Password',
                controller: _passwordCtrl,
                obscure: true,
                showEye: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFF0D4896),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                  onPressed: _loading ? null : _onLogin,
                  child: Text(
                    _loading ? 'Signing in…' : 'Sign in',
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
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: widget.onSwitch,
            child: const Text(
              'New here? Create account',
              style: TextStyle(
                color: Color(0xFF0D4896),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
