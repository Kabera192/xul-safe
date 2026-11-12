import 'package:flutter/material.dart';

import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/parent_more_settings_form.dart';
import '../../../core/l10n/app_localizations.dart';

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
  Key _formKey = UniqueKey();

  @override
  void didUpdateWidget(covariant ParentMoreSettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      // Re-entering this tab should refetch contacts/route details, not
      // just re-show the same form instance — a fresh key forces its
      // initState (and therefore its data loads) to rerun.
      if (_alreadyScheduled) {
        setState(() => _formKey = UniqueKey());
        _showForm();
      } else {
        _scheduleShow();
      }
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
    }
  }

  void _showForm() {
    _formCtrl.show(
      MobileFormShell(
        child: ParentMoreSettingsForm(key: _formKey),
      ),
    );
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    // allow background + title to appear instantly
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));
      if (!mounted || !widget.isActive) return;

      _showForm();
    });
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    l10n.moreSettings,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500, // medium
                    ),
                  ),
                ),
              ),

              MobileAnimatedFormHost(
                controller: _formCtrl,
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
