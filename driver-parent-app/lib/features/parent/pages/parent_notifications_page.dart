import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import '../../../core/l10n/app_localizations.dart';

import '../../../services/notification_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../../../features/driver/models/notification_model.dart';
import '../forms/parent_notifications_form.dart';

class ParentNotificationsPage extends StatefulWidget {
  final bool isActive;

  const ParentNotificationsPage({
    super.key,
    required this.isActive,
  });

  @override
  State<ParentNotificationsPage> createState() =>
      _ParentNotificationsPageState();
}

class _ParentNotificationsPageState extends State<ParentNotificationsPage> {
  final MobileFormController _formCtrl = MobileFormController();
  bool _alreadyScheduled = false;

  bool _loading = false;
  String? _error;
  List<NotificationModel> _notifications = [];

  @override
  void didUpdateWidget(covariant ParentNotificationsPage oldWidget) {
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
      debugPrint('[ParentNotifications] raw count: ${raw.length}');
      if (raw.isNotEmpty) debugPrint('[ParentNotifications] first item keys: ${raw.first.keys.toList()}');
      if (!mounted) return;
      final notifications =
          raw.map((j) => NotificationModel.fromApiResponse(j)).toList();
      setState(() {
        _notifications = notifications;
      });
      _markAllVisibleAsRead(notifications);
    } catch (e) {
      debugPrint('[ParentNotifications] ERROR: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
      _refreshShownForm();
    }
  }

  /// Opening the notifications section is itself the "read" action — mark
  /// every notification that was unread at load time as read, rather than
  /// requiring the parent to tap each one individually.
  Future<void> _markAllVisibleAsRead(List<NotificationModel> loaded) async {
    final unread = loaded.where((n) => n.isUnread).toList();
    if (unread.isEmpty) return;

    final readIds = <int>{};
    await Future.wait(unread.map((n) async {
      try {
        await NotificationService.markAsRead(n.notificationId);
        readIds.add(n.notificationId);
      } catch (_) {
        // Best-effort — a failed item just stays unread until next view.
      }
    }));

    if (!mounted || readIds.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _notifications = _notifications.map((item) {
        if (!readIds.contains(item.notificationId)) return item;
        return item.copyWith(status: 'READ', readAt: now);
      }).toList();
    });

    _refreshShownForm();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isUnread) return;
    try {
      await NotificationService.markAsRead(notification.notificationId);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.notificationId != notification.notificationId) return n;
        return n.copyWith(
          status: 'READ',
          readAt: DateTime.now().millisecondsSinceEpoch,
        );
      }).toList();
    });
    _refreshShownForm();
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
        child: ParentNotificationsForm(
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
    final media = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).notifications,
                    style: const TextStyle(
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