import 'package:flutter/material.dart';

import 'features/auth/forms/login_form.dart';
import 'features/auth/forms/signup_form.dart';
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
                        ? LoginForm(onSwitch: _toggleForm)
                        : SignupForm(onSwitch: _toggleForm),
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
