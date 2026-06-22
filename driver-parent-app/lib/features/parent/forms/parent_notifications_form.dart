import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../features/driver/models/notification_model.dart';
import '../../../widgets/mobile_notification_card_template.dart';

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
              ...newNotifs.asMap().entries.map(
                (entry) => InkWell(
                  onTap: () => widget.onNotificationTap(entry.value),
                  borderRadius: BorderRadius.circular(10),
                  child: MobileNotificationCardTemplate(
                    notification: entry.value,
                    index: entry.key,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (oldNotifs.isNotEmpty) ...[
              _SectionTitle('EARLIER', onSurface: onSurface),
              const SizedBox(height: 10),
              ...oldNotifs.asMap().entries.map(
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
