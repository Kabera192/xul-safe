import 'package:flutter/material.dart';
import 'core/config/theme_service.dart';
import 'widgets/mobile_network_gate.dart';
import 'widgets/mobile_location_gate.dart';
import 'widgets/mobile_auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.load();
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bus App',
          themeMode: themeMode,
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
  }
}