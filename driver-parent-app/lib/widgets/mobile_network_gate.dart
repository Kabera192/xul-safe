import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mobile_offline_banner.dart';

class MobileNetworkGate extends StatefulWidget {
  final Widget child;

  final ValueChanged<bool>? onStatusChanged;

  const MobileNetworkGate({
    super.key,
    required this.child,
    this.onStatusChanged,
  });

  @override
  State<MobileNetworkGate> createState() => _MobileNetworkGateState();
}

class _MobileNetworkGateState extends State<MobileNetworkGate> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;
  bool _online = true;

  @override
  void initState() {
    super.initState();

    // initial check
    Connectivity().checkConnectivity().then((results) {
      if (!mounted) return;
      _updateStatus(results);
    });

    // listen to changes
    _sub = Connectivity()
        .onConnectivityChanged
        .listen((results) => _updateStatus(results));
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasNetwork = results.any(
      (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
    );

    // no change → do nothing
    if (!mounted || hasNetwork == _online) return;

    // went from online → offline → trigger haptic
    if (!hasNetwork && _online) {
      HapticFeedback.vibrate ();
      // or: HapticFeedback.vibrate();
    }

    setState(() {
      _online = hasNetwork;
    });
    widget.onStatusChanged?.call(_online);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOffline = !_online;

    Widget content = Stack(
      children: [
        // your app
        widget.child,

        // dimmer (fade) – but only intercept taps when offline
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOffline, // online -> don't block taps
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              opacity: isOffline ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
        ),

        // banner: slides from top + fades in/out
        SafeArea(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            offset: isOffline ? Offset.zero : const Offset(0, -1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              opacity: isOffline ? 1.0 : 0.0,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: MobileOfflineBanner(
                  text: 'offline', // later: "RAE 109 P - offline"
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // block all interaction while offline (page + banner)
    if (isOffline) {
      content = AbsorbPointer(
        absorbing: true,
        child: content,
      );
    }

    return content;
  }
}