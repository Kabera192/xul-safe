import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/notification_service.dart';

import '../driver/pages/driver_home_page.dart';
import '../driver/pages/driver_profile_page.dart';
import '../driver/pages/driver_notifications_page.dart';
import '../driver/pages/driver_children_page.dart';
import '../driver/pages/driver_attendance_page.dart';

class DriverNav extends StatefulWidget {
  const DriverNav({super.key});

  @override
  State<DriverNav> createState() => _DriverNavState();
}

class _DriverNavState extends State<DriverNav> {
  int _index = 0;

  int _unreadNotificationCount = 0;
  bool _loadingUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationCount();
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

  void _onNavTap(int i) {
    setState(() {
      _index = i;
    });

    if (i == 3) {
      _loadUnreadNotificationCount();
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
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.document_normal),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.people),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _NotificationNavIcon(count: _unreadNotificationCount),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(IconsaxPlusLinear.user),
        label: '',
      ),
    ];

    final pages = [
      const DriverHomePage(),
      DriverAttendancePage(isActive: _index == 1),
      DriverChildrenPage(isActive: _index == 2),
      DriverNotificationsPage(

  isActive: _index == 3,

  onUnreadChanged: _loadUnreadNotificationCount,

),
      DriverProfilePage(isActive: _index == 4),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = items.length;
    final cellWidth = screenWidth / itemCount;

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
                    onTap: _onNavTap,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedItemColor: blue,
                    unselectedItemColor: Colors.grey,
                  ),
                ),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}