import 'package:flutter/material.dart';

import '../core/session/session_storage.dart';
import '../features/navigation/driver_nav.dart';
import '../features/navigation/parent_nav.dart';
import '../mobile_authentication.dart';
import 'mobile_splash_gradient.dart';

class MobileAuthGate extends StatefulWidget {
  const MobileAuthGate({super.key});

  @override
  State<MobileAuthGate> createState() => _MobileAuthGateState();
}

class _MobileAuthGateState extends State<MobileAuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final isLoggedIn = await SessionStorage.isLoggedIn();
      final token = await SessionStorage.getToken();
      final role = await SessionStorage.getRole();

      if (!mounted) return;

      Widget destination;

      if (isLoggedIn && token != null && token.isNotEmpty) {
        final normalizedRole = (role ?? 'PARENT').toUpperCase();

        if (normalizedRole == 'DRIVER') {
          destination = const DriverNav();
        } else {
          destination = const ParentNav();
        }
      } else {
        destination = const LoginPage();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        svgAsset:
            'assests/backgrounds/mobile/mobile_background_login.svg',
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}