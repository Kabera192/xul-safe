import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../core/session/session_storage.dart';
import '../../../services/notification_service.dart';

import '../parent/pages/parent_home_page.dart';
import '../parent/pages/parent_profile_page.dart';
import '../parent/pages/parent_notifications_page.dart';
import '../parent/pages/parent_my_children_page.dart';
import '../parent/pages/parent_more_settings_page.dart';

class ParentNav extends StatefulWidget {
  const ParentNav({super.key});

  @override
  State<ParentNav> createState() => _ParentNavState();
}

class _ParentNavState extends State<ParentNav> {
  int _index = 0;
  int _unreadNotificationCount = 0;
  bool _loadingUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadLastTabIndex();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadLastTabIndex() async {
    final savedIndex = await SessionStorage.getParentLastTabIndex();

    if (!mounted) return;

    if (savedIndex >= 0 && savedIndex <= 4) {
      setState(() {
        _index = savedIndex;
      });
    }
  }

  Future<void> _loadUnreadNotificationCount() async {
    if (_loadingUnreadNotifications) return;
    _loadingUnreadNotifications = true;
    try {
      final unread = await NotificationService.getUnreadNotifications();
      if (!mounted) return;
      setState(() {
        _unreadNotificationCount = unread.length;
      });
    } catch (_) {
      // Badge failure should not break navigation.
    } finally {
      _loadingUnreadNotifications = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D4896);
    const barHeight = 64.0;
    const indicatorWidth = 70.0;
    const indicatorHeight = 16.0;

    final items = [
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.home_2),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _NotificationNavIcon(count: _unreadNotificationCount),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.add_square),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.user),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.setting_2),
        label: '',
      ),
    ];

    final pages = [
      const ParentHomePage(),
      ParentNotificationsPage(
        isActive: _index == 1,
        onUnreadChanged: _loadUnreadNotificationCount,
      ),
      ParentMyChildrenPage(isActive: _index == 2),
      ParentProfilePage(isActive: _index == 3),
      ParentMoreSettingsPage(isActive: _index == 4),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final cellWidth = screenWidth / items.length;

    final indicatorLeft =
        cellWidth * _index + (cellWidth - indicatorWidth) / 2;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _index,
                    items: items,
                    onTap: (i) async {
                      setState(() => _index = i);
                      await SessionStorage.saveParentLastTabIndex(i);

                      if (i == 1) {
                        _loadUnreadNotificationCount();
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedItemColor: blue,
                    unselectedItemColor: Colors.grey,
                  ),
                ),

                // Blue indicator bar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  top: -indicatorHeight / 2,
                  left: indicatorLeft,
                  child: Container(
                    width: indicatorWidth,
                    height: indicatorHeight,
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationNavIcon extends StatelessWidget {
  final int count;

  const _NotificationNavIcon({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final display = count > 99 ? '99+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(IconsaxPlusLinear.notification_bing),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFC4A4A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
