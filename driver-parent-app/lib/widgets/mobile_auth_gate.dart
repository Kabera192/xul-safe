import 'package:flutter/material.dart';

import '../core/auth/auth_service.dart';
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

      if (!isLoggedIn) {
        await _clearSessionAndOpenLogin();
        return;
      }

      final token = await SessionStorage.getToken();
      final tokenExpiresAt = await SessionStorage.getTokenExpiresAt();

      final hasValidAccessToken =
          token != null &&
          token.isNotEmpty &&
          !_isExpired(tokenExpiresAt);

      if (!hasValidAccessToken) {
        final refreshToken = await SessionStorage.getRefreshToken();
        final refreshTokenExpiresAt =
            await SessionStorage.getRefreshTokenExpiresAt();

        final canAttemptRefresh =
            refreshToken != null &&
            refreshToken.isNotEmpty &&
            !_isExpired(refreshTokenExpiresAt);

        if (!canAttemptRefresh) {
          await _clearSessionAndOpenLogin();
          return;
        }

        final refreshed = await AuthService.refreshSession();

        if (!refreshed) {
          await _clearSessionAndOpenLogin();
          return;
        }
      }

      final refreshedToken = await SessionStorage.getToken();

      if (refreshedToken == null || refreshedToken.isEmpty) {
        await _clearSessionAndOpenLogin();
        return;
      }

      final role = await SessionStorage.getRole();

      if (!mounted) {
        return;
      }

      final normalizedRole = (role ?? 'PARENT').toUpperCase();

      final Widget destination;

      if (normalizedRole == 'DRIVER') {
        destination = const DriverNav();
      } else {
        destination = const ParentNav();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => destination,
        ),
      );
    } catch (_) {
      await _clearSessionAndOpenLogin();
    }
  }

  bool _isExpired(String? expiresAt) {
    if (expiresAt == null || expiresAt.trim().isEmpty) {
      return true;
    }

    final expiration = DateTime.tryParse(expiresAt);

    if (expiration == null) {
      return true;
    }

    return !expiration.toUtc().isAfter(DateTime.now().toUtc());
  }

  Future<void> _clearSessionAndOpenLogin() async {
    await SessionStorage.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_login.svg',
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}