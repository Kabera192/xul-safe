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

  static const _green = Color(0xFF21C260);

  bool get _isAltRow => index.isEven;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    final bgColor = _isAltRow
        ? (isDark ? const Color(0xFF1A2A3E) : const Color(0xFFF1F5FA))
        : surface;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    final iconColor =
        isDark ? const Color(0xFF93B5E8) : const Color(0xFF0D4896);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: _isAltRow
              ? null
              : Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            MobileNotificationVisualTemplate.iconForCategory(
              notification.category,
              iconColor: iconColor,
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
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            notification.isUnread
                ? const _UnreadDot()
                : _ReadCheck(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF21C260),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ReadCheck extends StatelessWidget {
  final bool isDark;

  const _ReadCheck({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3850) : const Color(0xFFE9EDF2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: isDark ? Colors.white38 : Colors.black38,
        size: 13,
      ),
    );
  }
}
