import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/theme_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_service.dart';
import 'core/session/session_storage.dart';
import 'mobile_authentication.dart';
import 'widgets/mobile_auth_gate.dart';
import 'widgets/mobile_location_gate.dart';
import 'widgets/mobile_network_gate.dart';

final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();

bool _isReturningToLogin = false;

Future<void> logoutAndReturnToLogin() async {
  if (_isReturningToLogin) return;

  _isReturningToLogin = true;

  try {
    await SessionStorage.clearSession();

    final navigator = appNavigatorKey.currentState;

    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (_) => false,
    );
  } finally {
    _isReturningToLogin = false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.load();
  await LocaleService.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _online = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LocaleService.notifier,
          builder: (context, locale, _) {
            return MaterialApp(
              navigatorKey: appNavigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Bus App',
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('fr'), Locale('rw')],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                const _FallbackMaterialLocalizationsDelegate(),
              ],
              theme: ThemeData(
                fontFamily: 'Poppins',
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0D4896),
                  brightness: Brightness.light,
                  surface: Colors.white,
                ),
                scaffoldBackgroundColor: Colors.white,
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.white,
                ),
              ),
              darkTheme: ThemeData(
                fontFamily: 'Poppins',
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0D4896),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF0F1923),
                ),
                scaffoldBackgroundColor: const Color(0xFF0F1923),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF0F1923),
                ),
              ),
              home: const MobileAuthGate(),
              builder: (context, child) {
                if (child == null) return const SizedBox.shrink();
                final gatedChild =
                    _online ? MobileLocationGate(child: child) : child;
                return MobileNetworkGate(
                  child: gatedChild,
                  onStatusChanged: (isOnline) {
                    if (isOnline != _online) {
                      setState(() => _online = isOnline);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// Fallback delegates so unsupported locales (e.g. rw) don't crash widgets
// that require MaterialLocalizations / CupertinoLocalizations.

class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}
