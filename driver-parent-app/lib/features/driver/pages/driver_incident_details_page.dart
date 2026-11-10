import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
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

  /// Set only when the incident itself was created successfully but an
  /// attachment failed to upload. See _submitIncident for why this is
  /// never treated as a submission failure.
  String? _attachmentWarning;

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
    File? image,
    File? audio,
  }) async {
    if (_submitting) return;

    final l10n = AppLocalizations.of(context);

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
          l10n.drvCouldNotDetermineBus,
        );
      }

      final isChildSpecific =
        widget.incidentType == 'MEDICAL' ||
        widget.incidentType == 'CHILD_BEHAVIOR';

      final shouldAffectBus =
          !isChildSpecific || journeyImpact != 'NONE';

      // The incident report is the critical part -- it's what gets the
      // relevant people notified. Once this succeeds, nothing below may
      // turn this submission into a reported failure: that would let the
      // driver retry and file a duplicate report for something that
      // already went through.
      final incident = await IncidentService.createIncident(
        type: widget.incidentType,
        description: description,
        journeyImpact: journeyImpact,
        affectedBusIds:
            shouldAffectBus ? {busId} : <int>{},
        affectedChildIds:
            Set<String>.from(widget.affectedChildIds),
      );

      // Each attachment is independent: a failed photo upload must not
      // stop the voice note from being attempted, and either failing is
      // a notice on the success screen, never a blocking error.
      final failedAttachments = <String>[];

      if (image != null) {
        try {
          await IncidentService.addAttachment(
            incidentId: incident.id,
            file: image,
            type: 'IMAGE',
          );
        } catch (_) {
          failedAttachments.add(l10n.drvAttachmentFailedPhoto);
        }
      }

      if (audio != null) {
        try {
          await IncidentService.addAttachment(
            incidentId: incident.id,
            file: audio,
            type: 'AUDIO',
          );
        } catch (_) {
          failedAttachments.add(l10n.drvAttachmentFailedVoiceNote);
        }
      }

      if (!mounted) return;

      setState(() {
        _submitting = false;
        _success = true;
        _attachmentWarning = failedAttachments.isEmpty
            ? null
            : l10n.drvAttachmentWarningBody(
                failedAttachments.join(' ${l10n.drvAttachmentAnd} '),
                failedAttachments.length > 1
                    ? l10n.drvThemPronoun
                    : l10n.drvItPronoun,
              );
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

    final Widget child = _success
        ? DriverIncidentSuccessForm(
            incidentType: widget.incidentType,
            onDone: _cancelIncidentFlow,
            attachmentWarning: _attachmentWarning,
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
    final l10n = AppLocalizations.of(context);

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
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      l10n.drvTripIncidentsTitle,
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
      ),
    );
  }
}
