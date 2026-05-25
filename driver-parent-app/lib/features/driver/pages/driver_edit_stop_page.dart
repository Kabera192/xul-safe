import 'package:flutter/material.dart';

import '../../../services/child_service.dart';
import '../../../services/transport_service.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_splash_gradient.dart';

import '../forms/driver_assign_students_form.dart';
import '../forms/driver_delete_stop_confirm_form.dart';
import '../forms/driver_delete_stop_success_form.dart';
import '../forms/driver_edit_stop_form.dart';
import '../forms/driver_edit_stop_success_form.dart';
import '../forms/driver_assign_students_success_form.dart';
import '../models/child_model.dart';
import '../models/stop_model.dart';

enum _EditStopView {
  edit,
  editSuccess,
  deleteConfirm,
  deleteSuccess,
  assignStudents,
  assignSuccess,
}

class DriverEditStopPage extends StatefulWidget {
  final StopModel stop;

  const DriverEditStopPage({
    super.key,
    required this.stop,
  });

  @override
  State<DriverEditStopPage> createState() => _DriverEditStopPageState();
}

class _DriverEditStopPageState extends State<DriverEditStopPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loadingChildren = false;

  _EditStopView _view = _EditStopView.edit;
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _scheduleShow();
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

  Future<void> _loadChildren() async {
    setState(() {
      _loadingChildren = true;
    });

    try {
      final raw = await ChildService.getMyBusChildren();

      final children = raw
          .map((e) => ChildModel.fromApiResponse(e))
          .toList();

      if (!mounted) return;

      setState(() {
        _children = children;
        _loadingChildren = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _children = [];
        _loadingChildren = false;
      });
    }
  }

  void _setView(_EditStopView view) {
    setState(() {
      _view = view;
    });

    _showCurrentForm();
  }

  double _currentFormHeight() {
    final h = MediaQuery.of(context).size.height;

    switch (_view) {
      case _EditStopView.edit:
        return h * 0.75;
      case _EditStopView.deleteConfirm:
      case _EditStopView.assignStudents:
        return h * 0.82;
      case _EditStopView.editSuccess:
      case _EditStopView.deleteSuccess:
      case _EditStopView.assignSuccess:
        return h * 0.65;
    }
  }

  void _showCurrentForm() {
    final h = _currentFormHeight();

    final Widget child;

    switch (_view) {
      case _EditStopView.edit:
        child = DriverEditStopForm(
          stop: widget.stop,
          onCancel: () => Navigator.pop(context),
          onSave: ({
            required String locationName,
            required double locationLat,
            required double locationLong,
          }) async {
            await TransportService.updateMyStop(
              stopId: widget.stop.id,
              locationName: locationName,
              locationLat: locationLat,
              locationLong: locationLong,
            );

            if (!mounted) return;
            _setView(_EditStopView.editSuccess);
          },
          onDeleteTap: () {
            _setView(_EditStopView.deleteConfirm);
          },
          onAssignStudentsTap: () async {
            await _loadChildren();
            if (!mounted) return;
            _setView(_EditStopView.assignStudents);
          },
        );
        break;

      case _EditStopView.editSuccess:
        child = DriverEditStopSuccessForm(
          onDone: () {
            Navigator.pop(context, true);
          },
        );
        break;

      case _EditStopView.deleteConfirm:
        child = DriverDeleteStopConfirmForm(
          onCancel: () {
            _setView(_EditStopView.edit);
          },
          onConfirm: (reason) async {
            await TransportService.deleteMyStop(
              stopId: widget.stop.id,
              reason: reason,
            );

            if (!mounted) return;
            _setView(_EditStopView.deleteSuccess);
          },
        );
        break;

      case _EditStopView.deleteSuccess:
        child = DriverDeleteStopSuccessForm(
          onDone: () {
            Navigator.pop(context, true);
          },
        );
        break;

      case _EditStopView.assignStudents:
        child = _loadingChildren
            ? const Center(child: CircularProgressIndicator())
            : DriverAssignStudentsForm(
                stopId: widget.stop.id,
                children: _children,
                onCancel: () {
                  _setView(_EditStopView.edit);
                },
                onComplete: (childIds) async {
                  await ChildService.assignChildrenToStop(
                    stopId: widget.stop.id,
                    childIds: childIds,
                  );

                  if (!mounted) return;
                  _setView(_EditStopView.assignSuccess);
                },
              );
        break;

      case _EditStopView.assignSuccess:
        child = DriverAssignStudentsSuccessForm(
          onDone: () {
            Navigator.pop(context, true);
          },
        );
        break;
    }

    _formCtrl.show(
      MobileFormShell(
        height: h,
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
    final formHeight = _currentFormHeight();
    final media = MediaQuery.of(context);

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
                  onTap: () {
                    if (_view == _EditStopView.deleteConfirm ||
                        _view == _EditStopView.assignStudents) {
                      _setView(_EditStopView.edit);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Modify bus stop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              MediaQuery(
                data: media.copyWith(viewInsets: EdgeInsets.zero),
                child: MobileAnimatedFormHost(
                  controller: _formCtrl,
                  height: formHeight,
                  duration: const Duration(milliseconds: 400),
                  respectKeyboard: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}