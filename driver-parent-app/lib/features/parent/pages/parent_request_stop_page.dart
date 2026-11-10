import 'package:flutter/material.dart';

import '../../../services/child_service.dart';
import '../../../services/transport_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/parent_request_stop_form.dart';
import '../forms/parent_request_stop_success_form.dart';
import '../models/child_model.dart';
import '../../../core/l10n/app_localizations.dart';

class ParentRequestStopPage extends StatefulWidget {
  const ParentRequestStopPage({super.key});

  @override
  State<ParentRequestStopPage> createState() => _ParentRequestStopPageState();
}

class _ParentRequestStopPageState extends State<ParentRequestStopPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = true;
  bool _success = false;
  String? _loadError;
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _scheduleShow();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await ChildService.getMyChildren();
      if (!mounted) return;
      setState(() {
        _children = children;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
    _showCurrentForm();
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
    final Widget child;

    if (_success) {
      child = ParentRequestStopSuccessForm(
        onDone: () => Navigator.pop(context, true),
      );
    } else if (_loading) {
      child = const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_loadError != null) {
      child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      );
    } else if (_children.isEmpty) {
      child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            AppLocalizations.of(context).parAddChildFirstRequestStop,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    } else {
      child = ParentRequestStopForm(
        children: _children,
        onSave: ({
          required String childId,
          required double latitude,
          required double longitude,
          required String address,
          required String description,
        }) async {
          await TransportService.createRouteRequest(
            childId: childId,
            latitude: latitude,
            longitude: longitude,
            address: address,
            description: description,
          );

          if (!mounted) return;

          setState(() => _success = true);
          _showCurrentForm();
        },
        onCancel: () => Navigator.pop(context),
      );
    }

    _formCtrl.show(
      MobileFormShell(
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
    final l10n = AppLocalizations.of(context);
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
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    l10n.parRequestStopTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
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
