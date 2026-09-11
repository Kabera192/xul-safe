import 'package:flutter/material.dart';

import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_incident_details_form.dart';
import '../forms/driver_incident_success_form.dart';

import '../../../services/incident_service.dart';
import '../../../services/transport_service.dart';

class DriverIncidentDetailsPage extends StatefulWidget {
  final String incidentType;
  final Set<String> affectedChildIds;

  const DriverIncidentDetailsPage({
    super.key,
    required this.incidentType,
    this.affectedChildIds = const <String>{},
  });

  @override
  State<DriverIncidentDetailsPage> createState() =>
      _DriverIncidentDetailsPageState();
}

class _DriverIncidentDetailsPageState
    extends State<DriverIncidentDetailsPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;

  bool _success = false;

  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _scheduleShow();
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;

    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(
        const Duration(milliseconds: 1),
      );

      if (!mounted) return;

      _showCurrentForm();
    });
  }

  Future<void> _submitIncident({
    required String description,
    required String journeyImpact,
  }) async {
    if (_submitting) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    _showCurrentForm();

    try {
      final bus = await TransportService.getMyBus();

      final busIdRaw = bus['id'];

      final int? busId = busIdRaw is int
          ? busIdRaw
          : int.tryParse(busIdRaw?.toString() ?? '');

      if (busId == null || busId <= 0) {
        throw Exception(
          'Could not determine the bus assigned to this driver',
        );
      }

      final isChildSpecific =
        widget.incidentType == 'MEDICAL' ||
        widget.incidentType == 'CHILD_BEHAVIOR';

      final shouldAffectBus =
          !isChildSpecific || journeyImpact != 'NONE';

      await IncidentService.createIncident(
        type: widget.incidentType,
        description: description,
        journeyImpact: journeyImpact,
        affectedBusIds:
            shouldAffectBus ? {busId} : <int>{},
        affectedChildIds:
            Set<String>.from(widget.affectedChildIds),
      );

      if (!mounted) return;

      setState(() {
        _submitting = false;
        _success = true;
      });

      _showCurrentForm();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _submitError =
            e.toString().replaceFirst('Exception: ', '');
      });

      _showCurrentForm();
    }
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.8;

    final Widget child = _success
        ? DriverIncidentSuccessForm(
            incidentType: widget.incidentType,
            onDone: _cancelIncidentFlow,
          )
        : DriverIncidentDetailsForm(
            incidentType: widget.incidentType,
            submitting: _submitting,
            error: _submitError,

            // X = one logical step backward.
            onClose: () {
              Navigator.pop(context);
            },

            onSubmit: _submitIncident,
          );

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: child,
      ),
    );
  }
  void _cancelIncidentFlow() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _cancelIncidentFlow();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GradientBackground(
          svgAsset:
              'assests/backgrounds/mobile/mobile_background_profile.svg',
          child: SafeArea(
            child: Stack(
              children: [
                const Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Trip incidents',
                      style: TextStyle(
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
      ),
    );
  }
}