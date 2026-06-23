import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/notification_model.dart';
import '../../../widgets/mobile_notification_card_template.dart';

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
              ...newNotifications.asMap().entries.map(
                (entry) => InkWell(
                  onTap: () => widget.onNotificationTap(entry.value),
                  borderRadius: BorderRadius.circular(10),
                  child: MobileNotificationCardTemplate(
                    notification: entry.value,
                    index: entry.key,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (oldNotifications.isNotEmpty) ...[
              const _SectionTitle('OLD'),
              const SizedBox(height: 10),
              ...oldNotifications.asMap().entries.map(
                (entry) => InkWell(
                  onTap: () => widget.onNotificationTap(entry.value),
                  borderRadius: BorderRadius.circular(10),
                  child: MobileNotificationCardTemplate(
                    notification: entry.value,
                    index: entry.key,
                  ),
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