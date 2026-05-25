import 'package:flutter/material.dart';

import '../../../services/child_service.dart';
import '../../../services/transport_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_children_form.dart';
import '../models/child_model.dart';
import '../models/stop_model.dart';

class DriverChildrenPage extends StatefulWidget {
  final bool isActive;

  const DriverChildrenPage({
    super.key,
    required this.isActive,
  });

  @override
  State<DriverChildrenPage> createState() => _DriverChildrenPageState();
}

class _DriverChildrenPageState extends State<DriverChildrenPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  List<ChildModel> _children = [];
  List<StopModel> _stops = [];

  @override
  void didUpdateWidget(covariant DriverChildrenPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
      _loadData();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
    }
  }

  Future<void> _loadData() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rawChildren = await ChildService.getMyBusChildren();
      final children = rawChildren
          .map((e) => ChildModel.fromApiResponse(e))
          .toList();

      final stopsJson = await TransportService.getMyStops();
      final stops = stopsJson
          .map((e) => StopModel.fromApiResponse(e))
          .toList();

      if (!mounted) return;

      setState(() {
        _children = children;
        _stops = stops;
      });

      _refreshShownForm();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });

      _refreshShownForm();
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _refreshShownForm();
    }
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));

      if (!mounted || !widget.isActive) return;

      _showCurrentForm();
    });
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled || !widget.isActive) return;
    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.8;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notif) => true,
          child: DriverChildrenForm(
            children: _children,
            stops: _stops,
            loading: _loading,
            error: _error,
          ),
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
    final formHeight = MediaQuery.of(context).size.height * 0.8;

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
                    'Children(${_children.length})',
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
                height: formHeight,
                duration: const Duration(milliseconds: 400),
                respectKeyboard: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}