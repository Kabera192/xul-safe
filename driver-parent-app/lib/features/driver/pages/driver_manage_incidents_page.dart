import 'package:flutter/material.dart';

import '../../../core/session/session_storage.dart';
import '../../../services/incident_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_manage_incidents_form.dart';
import '../forms/driver_resolve_incident_form.dart';
import '../forms/driver_incident_details_form.dart';
import '../models/driver_incident_model.dart';

class DriverManageIncidentsPage extends StatefulWidget {
  const DriverManageIncidentsPage({
    super.key,
  });

  @override
  State<DriverManageIncidentsPage> createState() =>
      _DriverManageIncidentsPageState();
}

class _DriverManageIncidentsPageState
    extends State<DriverManageIncidentsPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  int? _currentUserId;

  List<DriverIncidentModel> _incidents = [];

  DriverIncidentModel? _incidentBeingResolved;
  bool _resolving = false;
  String? _resolveError;

  DriverIncidentModel? _incidentBeingEdited;
  bool _savingEdit = false;
  String? _editError;

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
      final results = await Future.wait([
        IncidentService.getMyIncidents(),
        SessionStorage.getUserId(),
      ]);

      final incidents =
          results[0] as List<DriverIncidentModel>;

      final currentUserId =
          results[1] as int?;

      if (!mounted) return;

      setState(() {
        _incidents = incidents;
        _currentUserId = currentUserId;
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

  Future<void> _resolveIncident() async {
    final incident = _incidentBeingResolved;

    if (incident == null || _resolving) return;

    setState(() {
      _resolving = true;
      _resolveError = null;
    });

    _showCurrentForm();

    try {
      final updated =
          await IncidentService.resolveIncident(incident.id);

      if (!mounted) return;

      setState(() {
        _incidents = _incidents.map((item) {
          return item.id == updated.id ? updated : item;
        }).toList();

        _incidentBeingResolved = null;
        _resolving = false;
        _resolveError = null;
      });

      _showCurrentForm();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _resolving = false;
        _resolveError =
            e.toString().replaceFirst('Exception: ', '');
      });

      _showCurrentForm();
    }
  }
  
  Future<void> _saveEditedIncident({
    required String description,
    required String journeyImpact,
  }) async {
    final incident = _incidentBeingEdited;

    if (incident == null || _savingEdit) return;

    setState(() {
      _savingEdit = true;
      _editError = null;
    });

    _showCurrentForm();

    try {
      final updated = await IncidentService.updateIncident(
        incidentId: incident.id,
        description: description,
        journeyImpact: journeyImpact,
      );

      if (!mounted) return;

      setState(() {
        _incidents = _incidents.map((item) {
          return item.id == updated.id ? updated : item;
        }).toList();

        _incidentBeingEdited = null;
        _savingEdit = false;
        _editError = null;
      });

      _showCurrentForm();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _savingEdit = false;
        _editError =
            e.toString().replaceFirst('Exception: ', '');
      });

      _showCurrentForm();
    }
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled) return;

    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h =
        MediaQuery.of(context).size.height * 0.82;

    final Widget child;

    if (_incidentBeingResolved != null) {
      child = DriverResolveIncidentForm(
        incident: _incidentBeingResolved!,
        resolving: _resolving,
        error: _resolveError,

        onCancel: () {
          if (_resolving) return;

          setState(() {
            _incidentBeingResolved = null;
            _resolveError = null;
          });

          _showCurrentForm();
        },

        onConfirm: _resolveIncident,
      );
    } else if (_incidentBeingEdited != null) {
      child = DriverIncidentDetailsForm(
        incidentType: _incidentBeingEdited!.type,
        initialDescription:
            _incidentBeingEdited!.description,
        initialJourneyImpact:
            _incidentBeingEdited!.journeyImpact,
        isEditing: true,
        submitting: _savingEdit,
        error: _editError,

        onClose: () {
          if (_savingEdit) return;

          setState(() {
            _incidentBeingEdited = null;
            _editError = null;
          });

          _showCurrentForm();
        },

        onSubmit: _saveEditedIncident,
      );
    } else {
      child = DriverManageIncidentsForm(
        incidents: _incidents,
        loading: _loading,
        error: _error,
        currentUserId: _currentUserId,

        onClose: () {
          Navigator.pop(context);
        },

        onEdit: (incident) {
          setState(() {
            _incidentBeingEdited = incident;
            _editError = null;
          });

          _showCurrentForm();
        },

        onResolve: (incident) {
          setState(() {
            _incidentBeingResolved = incident;
            _resolveError = null;
          });

          _showCurrentForm();
        },
      );
    }

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