import 'package:flutter/material.dart';

import '../../../services/incident_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/parent_incidents_form.dart';
import '../models/parent_incident_model.dart';
import 'parent_incident_details_page.dart';

class ParentIncidentsPage extends StatefulWidget {
  const ParentIncidentsPage({
    super.key,
  });

  @override
  State<ParentIncidentsPage> createState() =>
      _ParentIncidentsPageState();
}

class _ParentIncidentsPageState
    extends State<ParentIncidentsPage> {
  final MobileFormController _formCtrl =
      MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  List<ParentIncidentModel> _incidents = [];

  @override
  void initState() {
    super.initState();

    _scheduleShow();
    _loadIncidents();
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

  Future<void> _loadIncidents() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    _refreshShownForm();

    try {
      final incidents =
          await IncidentService.getParentIncidents();

      if (!mounted) return;

      setState(() {
        _incidents = incidents;
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
    final h =
        MediaQuery.of(context).size.height * 0.82;

    final child = ParentIncidentsForm(
      incidents: _incidents,
      loading: _loading,
      error: _error,

      onClose: () {
        Navigator.pop(context);
      },

      onIncidentTap: (incident) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ParentIncidentDetailsPage(
              incident: incident,
            ),
          ),
        );
      },
    );

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: child,
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
        MediaQuery.of(context).size.height * 0.82;

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