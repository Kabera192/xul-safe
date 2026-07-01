import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class MobileNotificationVisualTemplate {
  static Widget iconForCategory(String category, {required Color iconColor}) {
    final normalized = category.trim().toUpperCase();

    if (normalized == 'ABSENCE_CREATED') {
      return SvgPicture.asset(
        'assests/backgrounds/mobile/abscence_icon.svg',
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    }

    if (normalized == 'CHILD_ASSIGNED_TO_BUS') {
      return Icon(IconsaxPlusLinear.profile_add, color: iconColor, size: 28);
    }

    if (normalized == 'STUDENT_BOARDED_BUS') {
      return Icon(IconsaxPlusLinear.login, color: iconColor, size: 28);
    }

    if (normalized == 'STUDENT_EXITED_BUS') {
      return Icon(IconsaxPlusLinear.logout, color: iconColor, size: 28);
    }

    if (normalized == 'BUS_PROBLEM_REPORTED') {
      return Icon(IconsaxPlusLinear.warning_2, color: iconColor, size: 28);
    }

    if (normalized == 'BUS_REACHED_STOP') {
      return Icon(IconsaxPlusLinear.location, color: iconColor, size: 28);
    }

    if (normalized == 'JOURNEY_STARTED') {
      return Icon(IconsaxPlusLinear.route_square, color: iconColor, size: 28);
    }

    if (normalized == 'JOURNEY_ENDED') {
      return Icon(IconsaxPlusLinear.tick_circle, color: iconColor, size: 28);
    }

    return Icon(IconsaxPlusLinear.notification, color: iconColor, size: 28);
  }
}
