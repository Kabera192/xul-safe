import 'dart:convert';
import 'core/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'features/navigation/driver_nav.dart';
import 'features/navigation/parent_nav.dart';
import 'widgets/mobile_splash_gradient.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _showLogin = true;
  bool _isAnimating = false;
  bool _entryShown = false;

  late final AnimationController _controller;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      setState(() {
        _entryShown = true;
      });
      _controller.value = 0;
      await _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleForm() async {
    if (_isAnimating) return;
    _isAnimating = true;

    await _controller.reverse();

    setState(() {
      _showLogin = !_showLogin;
    });

    await _controller.forward();
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_login.svg',
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                top: _entryShown ? null : size.height,
                bottom: _entryShown ? keyboard : null,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _slideUp,
                    child: _showLogin
                        ? _LoginForm(onSwitch: _toggleForm)
                        : _SignupForm(onSwitch: _toggleForm),
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

class _LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const _LoginForm({required this.onSwitch});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSession({
    required String token,
    required String refreshToken,
    required String tokenExpiresAt,
    required String refreshTokenExpiresAt,
    required int userId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('token_expires_at', tokenExpiresAt);
    await prefs.setString('refresh_token_expires_at', refreshTokenExpiresAt);
    await prefs.setInt('user_id', userId);
    await prefs.setString('role', role);
    await prefs.setBool('is_logged_in', true);
  }

  void _goToHomeByRole(String role) {
    final normalizedRole = role.toUpperCase();

    Widget page;
    if (normalizedRole == 'DRIVER') {
      page = const DriverNav();
    } else {
      page = const ParentNav();
    }

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
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': _identifierCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      if (!mounted) return;

      final bodyText = res.body.trim();
      final dynamic decoded = bodyText.isNotEmpty ? jsonDecode(bodyText) : null;

      if (res.statusCode == 200) {
        if (decoded is! Map<String, dynamic>) {
          setState(() {
            _error = 'Unexpected server response';
          });
          return;
        }

        final user = decoded['user'];
        if (user is! Map<String, dynamic>) {
          setState(() {
            _error = 'User data missing from response';
          });
          return;
        }

        final roles = user['roles'];
        String role = 'PARENT';
        if (roles is List && roles.isNotEmpty) {
          role = roles.first.toString();
        }

        final userIdRaw = user['user_id'];
        final int userId = userIdRaw is int
            ? userIdRaw
            : int.tryParse(userIdRaw.toString()) ?? 0;

        await _saveSession(
          token: decoded['token']?.toString() ?? '',
          refreshToken: decoded['refresh_token']?.toString() ?? '',
          tokenExpiresAt: decoded['token_expires_at']?.toString() ?? '',
          refreshTokenExpiresAt:
              decoded['refresh_token_expires_at']?.toString() ?? '',
          userId: userId,
          role: role,
        );

        if (!mounted) return;
        _goToHomeByRole(role);
      } else {
        String message = 'Invalid credentials';

        if (decoded is Map<String, dynamic>) {
          final serverMessage = decoded['message']?.toString();
          final serverError = decoded['error']?.toString();

          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          } else if (serverError != null && serverError.isNotEmpty) {
            message = serverError;
          }
        }

        setState(() {
          _error = message;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not reach server';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
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
              _FInput(
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
              _FInput(
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

class _SignupForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const _SignupForm({required this.onSwitch});

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/register');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'phoneNumber': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      if (!mounted) return;

      final bodyText = res.body.trim();
      final dynamic decoded = bodyText.isNotEmpty ? jsonDecode(bodyText) : null;

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded is! Map<String, dynamic>) {
          setState(() => _error = 'Unexpected server response');
          return;
        }

        final user = decoded['user'];
        if (user is! Map<String, dynamic>) {
          setState(() => _error = 'User data missing from response');
          return;
        }

        final roles = user['roles'];
        String role = 'PARENT';
        if (roles is List && roles.isNotEmpty) {
          role = roles.first.toString();
        }

        final userIdRaw = user['user_id'];
        final int userId = userIdRaw is int
            ? userIdRaw
            : int.tryParse(userIdRaw.toString()) ?? 0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', decoded['token']?.toString() ?? '');
        await prefs.setString('refresh_token', decoded['refresh_token']?.toString() ?? '');
        await prefs.setString('token_expires_at', decoded['token_expires_at']?.toString() ?? '');
        await prefs.setString('refresh_token_expires_at', decoded['refresh_token_expires_at']?.toString() ?? '');
        await prefs.setInt('user_id', userId);
        await prefs.setString('role', role);
        await prefs.setBool('is_logged_in', true);

        if (!mounted) return;

        final normalizedRole = role.toUpperCase();
        Widget page = normalizedRole == 'DRIVER'
            ? const DriverNav()
            : const ParentNav();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => page),
        );
      } else {
        String message = 'Registration failed';
        if (decoded is Map<String, dynamic>) {
          final serverMessage = decoded['message']?.toString();
          final serverError = decoded['error']?.toString();
          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          } else if (serverError != null && serverError.isNotEmpty) {
            message = serverError;
          }
        }
        setState(() => _error = message);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not reach server. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: 'Create your account',
      subtitle:
          'We are happy to have you! Please fill in the details below to create your account.',
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 380),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _FInput(
                    label: 'First name',
                    controller: _firstNameCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FInput(
                    label: 'Last name',
                    controller: _lastNameCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FInput(
                    label: 'Phone number',
                    controller: _phoneCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FInput(
                    label: 'Email address',
                    controller: _emailCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!_isValidEmail(v.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'More fields below ↓',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FInput(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscure: true,
                    showEye: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      if (v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(v)) {
                        return 'Password must contain at least one symbol';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FInput(
                    label: 'Confirm password',
                    controller: _confirmCtrl,
                    obscure: true,
                    showEye: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordCtrl.text) {
                        return 'Passwords do not match';
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
                          : const Text(
                              'Create account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  if (_error != null) ...
                    [
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
                      child: const Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
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

class _FormShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _FormShell({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: -18,
          child: Container(
            width: size.width * 0.9,
            decoration: BoxDecoration(
              color: surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24)
              .copyWith(top: 32, bottom: 24),
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
                title,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: onSurface.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ...children,
            ],
          ),
        ),
      ],
    );
  }
}

class _FInput extends StatefulWidget {
  final String label;
  final bool obscure;
  final bool showEye;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const _FInput({
    // super.key,
    required this.label,
    this.obscure = false,
    this.showEye = false,
    this.validator,
    this.controller,
  });

  @override
  State<_FInput> createState() => _FInputState();
}

class _FInputState extends State<_FInput> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : const Color(0xFFE0E0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _hidden,
          keyboardType: widget.label.toLowerCase().contains('email')
              ? TextInputType.emailAddress
              : TextInputType.text,
          style: TextStyle(color: onSurface, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            suffixIcon: widget.showEye
                ? IconButton(
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: onSurface.withOpacity(0.5),
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D4896), width: 1.3),
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
          validator: widget.validator,
        ),
      ],
    );
  }
}