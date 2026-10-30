import 'package:flutter/material.dart';

import '../../../services/child_service.dart';
import '../../../services/transport_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/parent_choose_stop_form.dart';
import '../forms/parent_request_stop_success_form.dart';
import '../models/child_model.dart';
import 'parent_request_stop_page.dart';
import '../../../core/l10n/app_localizations.dart';

/// Lets a parent browse routes/stops that already exist before falling back
/// to the free-form "request a new stop" flow. Previously the app only
/// offered the request form, even though the backend already exposed a
/// browsable route/stop list.
class ParentChooseStopPage extends StatefulWidget {
  const ParentChooseStopPage({super.key});

  @override
  State<ParentChooseStopPage> createState() => _ParentChooseStopPageState();
}

class _ParentChooseStopPageState extends State<ParentChooseStopPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = true;
  bool _success = false;
  String? _loadError;
  List<ChildModel> _children = [];
  List<Map<String, dynamic>> _routes = [];

  @override
  void initState() {
    super.initState();
    _scheduleShow();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final children = await ChildService.getMyChildren();
      final routes = await TransportService.getAllRoutes();
      if (!mounted) return;
      setState(() {
        _children = children;
        _routes = routes;
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

  Future<void> _goToRequestForm() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ParentRequestStopPage()),
    );
    if (added == true && mounted) {
      Navigator.pop(context, true);
    }
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
            AppLocalizations.of(context).parAddChildFirstChooseStop,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    } else {
      child = ParentChooseStopForm(
        children: _children,
        routes: _routes,
        loadStops: (routeId) => TransportService.getStopsForRoute(routeId),
        onSelectStop: ({required childId, required busStopId}) async {
          await TransportService.selectBusStop(
            childId: childId,
            busStopId: busStopId,
          );
          if (!mounted) return;
          setState(() => _success = true);
          _showCurrentForm();
        },
        onRequestNewStop: _goToRequestForm,
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
                    l10n.parChooseStopTitle,
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
