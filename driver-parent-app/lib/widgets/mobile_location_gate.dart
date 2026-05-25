import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'mobile_gps_banner.dart';

class MobileLocationGate extends StatefulWidget {
  final Widget child;

  const MobileLocationGate({
    super.key,
    required this.child,
  });

  @override
  State<MobileLocationGate> createState() => _MobileLocationGateState();
}

class _MobileLocationGateState extends State<MobileLocationGate> {
  StreamSubscription<ServiceStatus>? _serviceSub;
  bool _gpsOk = true;
  bool _checkedOnce = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkAll();

    // listen for GPS service ON/OFF changes
    _serviceSub =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      final enabled = status == ServiceStatus.enabled;
      _update(enabled);
    });
  }

  Future<void> _checkAll() async {
    // 1) is GPS service enabled?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // 2) permissions
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    final permissionOk = perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;

    _update(serviceEnabled && permissionOk);
    _checkedOnce = true;
  }

  void _update(bool ok) {
    if (!mounted) return;
    if (ok == _gpsOk && _checkedOnce) return;

    if (!ok && _gpsOk) {
      // went from ok -> not ok
      HapticFeedback.vibrate();
    }

    setState(() {
      _gpsOk = ok;
    });
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBad = !_gpsOk;

    Widget content = Stack(
      children: [
        widget.child,

        // dimmer when GPS/permission not ok
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isBad,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              opacity: isBad ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
        ),

        // banner
        SafeArea(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            offset: isBad ? Offset.zero : const Offset(0, -1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              opacity: isBad ? 1.0 : 0.0,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: MobileGpsBanner(
                  text: 'Location is off',
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (isBad) {
      content = AbsorbPointer(absorbing: true, child: content);
    }

    return content;
  }
}