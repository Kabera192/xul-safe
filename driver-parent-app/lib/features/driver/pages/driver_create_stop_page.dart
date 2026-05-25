import 'package:flutter/material.dart';

import '../../../services/transport_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_create_stop_form.dart';
import '../forms/driver_create_stop_success_form.dart';

class DriverCreateStopPage extends StatefulWidget {
  const DriverCreateStopPage({super.key});

  @override
  State<DriverCreateStopPage> createState() => _DriverCreateStopPageState();
}

class _DriverCreateStopPageState extends State<DriverCreateStopPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _scheduleShow();
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));

      if (!mounted) return;

      _showCurrentForm();
    });
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.75;

    final Widget child = _success
        ? DriverCreateStopSuccessForm(
            onDone: () {
              Navigator.pop(context, true);
            },
          )
        : DriverCreateStopForm(
            onSave: ({
              required String locationName,
              required double locationLat,
              required double locationLong,
            }) async {
              await TransportService.createMyStop(
                locationName: locationName,
                locationLat: locationLat,
                locationLong: locationLong,
              );

              if (!mounted) return;

              setState(() {
                _success = true;
              });

              _showCurrentForm();
            },
            onCancel: () {
              Navigator.pop(context);
            },
          );

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notif) => true,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formHeight = MediaQuery.of(context).size.height * 0.75;
    final media = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Create bus stop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              MediaQuery(
                data: media.copyWith(viewInsets: EdgeInsets.zero),
                child: MobileAnimatedFormHost(
                  controller: _formCtrl,
                  height: formHeight,
                  duration: const Duration(milliseconds: 400),
                  respectKeyboard: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}