import 'package:flutter/material.dart';

import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/parent_more_settings_form.dart';

class ParentMoreSettingsPage extends StatefulWidget {
  final bool isActive;

  const ParentMoreSettingsPage({
    super.key,
    required this.isActive,
  });

  @override
  State<ParentMoreSettingsPage> createState() =>
      _ParentMoreSettingsPageState();
}

class _ParentMoreSettingsPageState extends State<ParentMoreSettingsPage> {
  final MobileFormController _formCtrl = MobileFormController();
  bool _alreadyScheduled = false;

  @override
  void didUpdateWidget(covariant ParentMoreSettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
    }
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    // allow background + title to appear instantly
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));
      if (!mounted || !widget.isActive) return;

      final h = MediaQuery.of(context).size.height * 0.80;

      _formCtrl.show(
        MobileFormShell(
          height: h,
          child: const ParentMoreSettingsForm(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formHeight = MediaQuery.of(context).size.height * 0.80;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'More settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500, // medium
                    ),
                  ),
                ),
              ),

              MobileAnimatedFormHost(
                controller: _formCtrl,
                height: formHeight,
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}