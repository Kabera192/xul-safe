import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/notification_model.dart';

class DriverNotificationsForm extends StatefulWidget {
  final List<NotificationModel> notifications;
  final bool loading;
  final String? error;
  final Future<void> Function(NotificationModel notification) onNotificationTap;

  const DriverNotificationsForm({
    super.key,
    required this.notifications,
    required this.loading,
    required this.error,
    required this.onNotificationTap,
  });

  @override
  State<DriverNotificationsForm> createState() =>
      _DriverNotificationsFormState();
}

class _DriverNotificationsFormState extends State<DriverNotificationsForm> {
  // static const blue = Color(0xFF0D4896);
  // static const newBg = Color(0xFFF1F5FA);
  // static const stroke = Color(0xFFDCE6F5);
  // static const green = Color(0xFF21C260);

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<NotificationModel> get _filtered {
    final query = _searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) return widget.notifications;

    return widget.notifications.where((n) {
      return n.title.toLowerCase().contains(query) ||
          n.message.toLowerCase().contains(query) ||
          n.type.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final newNotifications = filtered.where((n) => n.isUnread).toList();
    final oldNotifications = filtered.where((n) => !n.isUnread).toList();

    final hasAny = filtered.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchBar(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),

          if (widget.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (widget.error != null) ...[
            _MessageCard(
              text: widget.error!,
              color: Colors.red,
            ),
          ] else if (!hasAny) ...[
            const _MessageCard(
              text: 'You have no notifications',
              color: Colors.black54,
            ),
          ] else ...[
            if (newNotifications.isNotEmpty) ...[
              const _SectionTitle('NEW'),
              const SizedBox(height: 10),
              ...newNotifications.map(
                (n) => _NotificationCard(
                  notification: n,
                  isNew: true,
                  onTap: () => widget.onNotificationTap(n),
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (oldNotifications.isNotEmpty) ...[
              const _SectionTitle('OLD'),
              const SizedBox(height: 10),
              ...oldNotifications.map(
                (n) => _NotificationCard(
                  notification: n,
                  isNew: false,
                  onTap: () => widget.onNotificationTap(n),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stroke, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            IconsaxPlusLinear.search_normal_1,
            color: blue,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search notifications',
                hintStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isNew;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.isNew,
    required this.onTap,
  });

  static const newBg = Color(0xFFF1F5FA);
  static const stroke = Color(0xFFDCE6F5);
  // static const green = Color(0xFF21C260);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: isNew ? newBg : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isNew
                  ? null
                  : Border.all(color: stroke, width: 1),
            ),
            child: Row(
              children: [
                _NotificationIcon(type: notification.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title.isEmpty
                            ? 'Notification'
                            : notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF001B3D),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                isNew ? const _UnreadDot() : const _ReadCheck(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;

  const _NotificationIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = type.trim().toUpperCase();

    if (normalized == 'ABSENCE') {
      return SvgPicture.asset(
        'assests/backgrounds/mobile/abscence_icon.svg',
        width: 30,
        height: 30,
      );
    }

    return const Icon(
      IconsaxPlusLinear.notification,
      color: Color(0xFF0D4896),
      size: 28,
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  static const green = Color(0xFF21C260);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: green,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ReadCheck extends StatelessWidget {
  const _ReadCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Color(0xFFE9EDF2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.black38,
        size: 13,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String text;
  final Color color;

  const _MessageCard({
    required this.text,
    required this.color,
  });

  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: stroke, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}