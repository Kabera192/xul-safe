import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../../services/incident_service.dart';
import '../../../services/child_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/parent_incident_details_form.dart';
import '../models/child_model.dart';
import '../models/parent_incident_model.dart';
import '../models/incident_attachment_model.dart';

class ParentIncidentDetailsPage extends StatefulWidget {
  final ParentIncidentModel incident;

  const ParentIncidentDetailsPage({
    super.key,
    required this.incident,
  });

  @override
  State<ParentIncidentDetailsPage> createState() =>
      _ParentIncidentDetailsPageState();
}

class _ParentIncidentDetailsPageState
    extends State<ParentIncidentDetailsPage> {
  final MobileFormController _formCtrl =
      MobileFormController();

  bool _alreadyScheduled = false;
  bool _loadingChildren = false;

  List<ChildModel> _affectedChildren = [];
  List<IncidentAttachmentModel> _attachments = [];

  Uint8List? _imageBytes;
  Uint8List? _audioBytes;

  bool _loadingAttachments = false;

  @override
  void initState() {
    super.initState();

    _scheduleShow();
    _loadAffectedChildren();
    _loadAttachments();
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

  Future<void> _loadAffectedChildren() async {
    if (widget.incident.affectedChildIds.isEmpty) {
      return;
    }

    if (_loadingChildren) return;

    setState(() {
      _loadingChildren = true;
    });

    _refreshShownForm();

    try {
      final children =
          await ChildService.getMyChildrenModels();

      if (!mounted) return;

      final affectedIds =
          widget.incident.affectedChildIds.toSet();

      setState(() {
        _affectedChildren = children
            .where(
              (child) => affectedIds.contains(child.id),
            )
            .toList();
      });
    } catch (_) {
      /*
       * Incident details can still be shown safely if child
       * information fails to load.
       *
       * We simply omit the affected-student rows.
       */
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingChildren = false;
      });

      _refreshShownForm();
    }
  }

  Future<void> _loadAttachments() async {
    if (_loadingAttachments) return;

    setState(() {
      _loadingAttachments = true;
    });

    _refreshShownForm();

    try {
      final attachments =
          await IncidentService.getAttachments(widget.incident.id);

      Uint8List? imageBytes;
      Uint8List? audioBytes;

      for (final attachment in attachments) {
        if (attachment.isImage && imageBytes == null) {
          final bytes = await IncidentService.getAttachmentBytes(
            incidentId: widget.incident.id,
            attachmentId: attachment.id,
          );

          imageBytes = Uint8List.fromList(bytes);
        }

        if (attachment.isAudio && audioBytes == null) {
          final bytes = await IncidentService.getAttachmentBytes(
            incidentId: widget.incident.id,
            attachmentId: attachment.id,
          );

          audioBytes = Uint8List.fromList(bytes);
        }
      }

      if (!mounted) return;

      setState(() {
        _attachments = attachments;
        _imageBytes = imageBytes;
        _audioBytes = audioBytes;
      });
    } catch (_) {
      /*
      * Incident information is still useful if media cannot be loaded,
      * so the details page remains available without attachments.
      */
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingAttachments = false;
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

    final Widget child;

    if ((_loadingChildren &&
        widget.incident.affectedChildIds.isNotEmpty) ||
    _loadingAttachments) {
      child = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      child = ParentIncidentDetailsForm(
        incident: widget.incident,
        affectedChildren: _affectedChildren,
        imageBytes: _imageBytes,
        audioBytes: _audioBytes,
        onClose: () {
          Navigator.pop(context);
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