import 'package:flutter/material.dart';

import '../../../services/notification_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_notifications_form.dart';
import '../models/notification_model.dart';

class DriverNotificationsPage extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onUnreadChanged;
  

  const DriverNotificationsPage({
    super.key,
    required this.isActive,
    this.onUnreadChanged,
  });

  @override
  State<DriverNotificationsPage> createState() =>
      _DriverNotificationsPageState();
}

class _DriverNotificationsPageState extends State<DriverNotificationsPage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  List<NotificationModel> _notifications = [];

  @override
  void didUpdateWidget(covariant DriverNotificationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
      _loadNotifications();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
    }
  }

  Future<void> _loadNotifications() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await NotificationService.getMyNotifications();
      debugPrint('[DriverNotifications] raw count: ${raw.length}');
      if (raw.isNotEmpty) debugPrint('[DriverNotifications] first item keys: ${raw.first.keys.toList()}');

      final notifications = raw
          .map((json) => NotificationModel.fromApiResponse(json))
          .toList();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
      });

      _refreshShownForm();
    } catch (e) {
      debugPrint('[DriverNotifications] ERROR: $e');
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

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isUnread) return;

    await NotificationService.markAsRead(notification.notificationId);

    if (!mounted) return;

    setState(() {
      _notifications = _notifications.map((item) {
        if (item.notificationId != notification.notificationId) {
          return item;
        }

        return item.copyWith(
          status: 'READ',
          readAt: DateTime.now().millisecondsSinceEpoch,
        );
      }).toList();
    });

    _refreshShownForm();
    widget.onUnreadChanged?.call();
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));

      if (!mounted || !widget.isActive) return;

      _showCurrentForm();
    });
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled || !widget.isActive) return;
    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.8;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: DriverNotificationsForm(
          notifications: _notifications,
          loading: _loading,
          error: _error,
          onNotificationTap: _markAsRead,
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
    final formHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Notifications',
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