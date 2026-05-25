import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../features/driver/models/notification_model.dart';

class ParentNotificationsForm extends StatefulWidget {
  final List<NotificationModel> notifications;
  final bool loading;
  final String? error;
  final Future<void> Function(NotificationModel) onNotificationTap;

  const ParentNotificationsForm({
    super.key,
    required this.notifications,
    required this.loading,
    required this.error,
    required this.onNotificationTap,
  });

  @override
  State<ParentNotificationsForm> createState() =>
      _ParentNotificationsFormState();
}

class _ParentNotificationsFormState extends State<ParentNotificationsForm> {
  static const green = Color(0xFF21C260);
  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  bool _showAll = true;
  final _searchCtrl = TextEditingController();

  // Emergency-type notification type identifiers
  static const _emergencyTypes = {'EMERGENCY', 'ALERT'};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<NotificationModel> get _filtered {
    final query = _searchCtrl.text.trim().toLowerCase();
    final list = _showAll
        ? widget.notifications
        : widget.notifications
            .where((n) => _emergencyTypes.contains(n.type.toUpperCase()))
            .toList();
    if (query.isEmpty) return list;
    return list
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.message.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;

    final filtered = _filtered;
    final newNotifs = filtered.where((n) => n.isUnread).toList();
    final oldNotifs = filtered.where((n) => !n.isUnread).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search bar ─────────────────────────────────────────────────────
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

          // ── Tabs ────────────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showAll = true),
                  child: Center(
                    child: Text(
                      'All notifications',
                      style: TextStyle(
                        color:
                            _showAll ? green : onSurface.withValues(alpha: 0.7),
                        fontWeight:
                            _showAll ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showAll = false),
                  child: Center(
                    child: Text(
                      'Emergencies',
                      style: TextStyle(
                        color: !_showAll
                            ? green
                            : onSurface.withValues(alpha: 0.7),
                        fontWeight:
                            !_showAll ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Stack(
            children: [
              Container(
                  height: 1.2,
                  color: onSurface.withValues(alpha: 0.12)),
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: _showAll
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  height: 2.6,
                  width: MediaQuery.of(context).size.width * 0.42,
                  color: green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Content ─────────────────────────────────────────────────────────
          if (widget.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (widget.error != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  widget.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ] else if (filtered.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'You have no notifications',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            if (newNotifs.isNotEmpty) ...[
              _SectionTitle('NEW', onSurface: onSurface),
              const SizedBox(height: 10),
              ...newNotifs.map((n) => _NotifCard(
                    notification: n,
                    isNew: true,
                    isDark: isDark,
                    onSurface: onSurface,
                    onTap: () => widget.onNotificationTap(n),
                  )),
              const SizedBox(height: 16),
            ],
            if (oldNotifs.isNotEmpty) ...[
              _SectionTitle('EARLIER', onSurface: onSurface),
              const SizedBox(height: 10),
              ...oldNotifs.map((n) => _NotifCard(
                    notification: n,
                    isNew: false,
                    isDark: isDark,
                    onSurface: onSurface,
                    onTap: () => widget.onNotificationTap(n),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

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
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isNew;
  final bool isDark;
  final Color onSurface;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notification,
    required this.isNew,
    required this.isDark,
    required this.onSurface,
    required this.onTap,
  });

  static const blue = Color(0xFF0D4896);
  static const green = Color(0xFF21C260);
  static const orange = Color(0xFFE67E22);
  static const stroke = Color(0xFFDCE6F5);

  IconData get _icon {
    final t = notification.type.toUpperCase();
    if (t == 'ABSENCE') return Icons.event_busy_rounded;
    if (t == 'ABSENCE_CANCELLED') return Icons.event_available_rounded;
    if (t == 'EMERGENCY' || t == 'ALERT') return Icons.warning_amber_rounded;
    return Icons.notifications_outlined;
  }

  Color get _iconColor {
    final t = notification.type.toUpperCase();
    if (t == 'ABSENCE') return orange;
    if (t == 'ABSENCE_CANCELLED') return green;
    if (t == 'EMERGENCY' || t == 'ALERT') return Colors.red;
    return blue;
  }

  Color _iconBg(bool isDark) {
    final t = notification.type.toUpperCase();
    if (t == 'ABSENCE') {
      return isDark ? const Color(0xFF3D2200) : const Color(0xFFFFF3E6);
    }
    if (t == 'ABSENCE_CANCELLED') {
      return isDark ? const Color(0xFF0A2E18) : const Color(0xFFEAFAF1);
    }
    if (t == 'EMERGENCY' || t == 'ALERT') {
      return isDark ? const Color(0xFF2E0A0A) : const Color(0xFFFDEDED);
    }
    return isDark ? const Color(0xFF1E3050) : const Color(0xFFEBF1FE);
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isNew
        ? (isDark ? const Color(0xFF1A2530) : const Color(0xFFF1F5FA))
        : (isDark ? const Color(0xFF141E28) : Colors.white);
    final borderC = isDark ? const Color(0xFF2A3A50) : stroke;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderC, width: 1),
            ),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _iconBg(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _iconColor, size: 20),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isNew)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                        color: green, shape: BoxShape.circle),
                  )
                else
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A3A50)
                          : const Color(0xFFE9EDF2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check,
                        color: onSurface.withValues(alpha: 0.4), size: 12),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}