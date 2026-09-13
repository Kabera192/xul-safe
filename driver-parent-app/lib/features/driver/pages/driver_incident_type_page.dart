import 'package:flutter/material.dart';

import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_incident_type_form.dart';
import 'driver_incident_student_selection_page.dart';
import 'driver_incident_details_page.dart';

class DriverIncidentTypePage extends StatefulWidget {
  const DriverIncidentTypePage({super.key});

  @override
  State<DriverIncidentTypePage> createState() =>
      _DriverIncidentTypePageState();
}

class _DriverIncidentTypePageState
    extends State<DriverIncidentTypePage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;

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

  void _showCurrentForm() {
    final h =
        MediaQuery.of(context).size.height * 0.78;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: DriverIncidentTypeForm(
          onClose: () {
            Navigator.pop(context);
          },
          onIncidentTypeSelected: (type) {
            if (type == 'MEDICAL' || type == 'CHILD_BEHAVIOR') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DriverIncidentStudentSelectionPage(
                    incidentType: type,
                  ),
                ),
              );

              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverIncidentDetailsPage(
                  incidentType: type,
                ),
              ),
            );
          },
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
    final formHeight =
        MediaQuery.of(context).size.height * 0.78;

    return Scaffold(
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
    );
  }
}