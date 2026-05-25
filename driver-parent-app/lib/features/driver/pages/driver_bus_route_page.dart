import 'package:flutter/material.dart';

import '../../../services/transport_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_bus_route_form.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../../../services/child_service.dart';
import '../models/child_model.dart';

class DriverBusRoutePage extends StatefulWidget {
  const DriverBusRoutePage({super.key});

  @override
  State<DriverBusRoutePage> createState() => _DriverBusRoutePageState();
}

class _DriverBusRoutePageState extends State<DriverBusRoutePage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  BusModel? _bus;
  RouteModel? _route;
  List<StopModel> _stops = [];
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _scheduleShow();
    _loadBusAndRoute();
  }

  Future<void> _loadBusAndRoute() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final busJson = await TransportService.getMyBus();
      final routeJson = await TransportService.getMyRoute();
      final rawChildren = await ChildService.getMyBusChildren();
final children = rawChildren
    .map((e) => ChildModel.fromApiResponse(e))
    .toList();

      final bus = BusModel.fromApiResponse(busJson);
      final route = RouteModel.fromApiResponse(routeJson);

      final stopsJson = await TransportService.getMyStops();

      final stops = stopsJson
          .map((json) => StopModel.fromApiResponse(json))
          .toList();

      if (!mounted) return;

      setState(() {
        _bus = bus;
        _route = route;
        _stops = stops;
          _children = children;
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

      if (!mounted) return;

      _showCurrentForm();
    });
  }
  Map<int, int> _computeStopCounts() {
  final Map<int, int> counts = {};

  for (final child in _children) {
    if (child.pickupStopId != null) {
      counts[child.pickupStopId!] =
          (counts[child.pickupStopId!] ?? 0) + 1;
    }
  }

  return counts;
}

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled) return;
    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.82;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notif) => true,
          child: DriverBusRouteForm(
            bus: _bus,
            route: _route,
            stops: _stops,
            stopCounts: _computeStopCounts(),
            loading: _loading,
            error: _error,
            onRefreshStops: _loadBusAndRoute,
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
    final formHeight = MediaQuery.of(context).size.height * 0.82;

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
                  onTap: () => Navigator.of(context).pop(),
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
                    'Bus & route settings',
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
    );
  }
}