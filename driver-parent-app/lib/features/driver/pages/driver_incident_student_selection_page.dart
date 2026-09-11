import 'package:flutter/material.dart';

import '../../../services/child_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_incident_student_selection_form.dart';
import 'driver_incident_details_page.dart';
import '../models/child_model.dart';

class DriverIncidentStudentSelectionPage extends StatefulWidget {
  final String incidentType;

  const DriverIncidentStudentSelectionPage({
    super.key,
    required this.incidentType,
  });

  @override
  State<DriverIncidentStudentSelectionPage> createState() =>
      _DriverIncidentStudentSelectionPageState();
}

class _DriverIncidentStudentSelectionPageState
    extends State<DriverIncidentStudentSelectionPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _scheduleShow();
    _loadChildren();
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

  Future<void> _loadChildren() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    _refreshShownForm();

    try {
      final raw = await ChildService.getMyBusChildren();

      final children = raw
          .map(
            (json) => ChildModel.fromApiResponse(json),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _children = children;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _refreshShownForm();
    }
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled) return;

    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.86;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: DriverIncidentStudentSelectionForm(
          incidentType: widget.incidentType,
          children: _children,
          loading: _loading,
          error: _error,

          // X = one logical step backward to incident type selection.
          onClose: () {
            Navigator.pop(context);
          },

          onContinue: (childIds) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverIncidentDetailsPage(
                  incidentType: widget.incidentType,
                  affectedChildIds: childIds,
                ),
              ),
            );
          },
        ),
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
    final formHeight =
        MediaQuery.of(context).size.height * 0.86;

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
                  duration:
                      const Duration(milliseconds: 400),
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