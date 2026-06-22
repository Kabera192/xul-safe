import 'package:flutter/material.dart';

import '../features/driver/models/notification_model.dart';
import 'mobile_notification_visual_template.dart';

class MobileNotificationCardTemplate extends StatelessWidget {
  final NotificationModel notification;
  final int index;

  const MobileNotificationCardTemplate({
    super.key,
    required this.notification,
    required this.index,
  });

  static const lightBlueBg = Color(0xFFF1F5FA);
  static const stroke = Color(0xFFDCE6F5);
  static const green = Color(0xFF21C260);
  static const blueText = Color(0xFF001B3D);

  bool get _useLightBlueBackground => index.isEven;

  @override
  Widget build(BuildContext context) {
    final bgColor = _useLightBlueBackground ? lightBlueBg : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: _useLightBlueBackground
              ? null
              : Border.all(color: stroke, width: 1),
        ),
        child: Row(
          children: [
            MobileNotificationVisualTemplate.iconForCategory(
              notification.category,
            ),
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
                      color: blueText,
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
            notification.isUnread ? const _UnreadDot() : const _ReadCheck(),
          ],
        ),
      ),
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