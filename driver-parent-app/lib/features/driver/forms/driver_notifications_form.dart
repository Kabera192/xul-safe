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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    final blue = isDark ? const Color(0xFF93B5E8) : const Color(0xFF0D4896);

    final filtered = _filtered;
    final newNotifications = filtered.where((n) => n.isUnread).toList();
    final oldNotifications = filtered.where((n) => !n.isUnread).toList();
    final hasAny = filtered.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search bar ───────────────────────────────────────────────────────
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(IconsaxPlusLinear.search_normal_1,
                    color: blue, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search notifications',
                      hintStyle: TextStyle(
                        color: onSurface.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Content ──────────────────────────────────────────────────────────
          if (widget.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (widget.error != null) ...[
            _MessageCard(
              text: widget.error!,
              textColor: Colors.red,
              bgColor: inputFill,
              borderColor: borderColor,
            ),
          ] else if (!hasAny) ...[
            _MessageCard(
              text: 'You have no notifications',
              textColor: onSurface.withValues(alpha: 0.5),
              bgColor: inputFill,
              borderColor: borderColor,
            ),
          ] else ...[
            if (newNotifications.isNotEmpty) ...[
              _SectionTitle('NEW', onSurface: onSurface),
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
              _SectionTitle('EARLIER', onSurface: onSurface),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color onSurface;

  const _SectionTitle(this.text, {required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _MessageCard({
    required this.text,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
