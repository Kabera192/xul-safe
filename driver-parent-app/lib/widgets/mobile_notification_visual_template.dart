import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class MobileNotificationVisualTemplate {
  static Widget iconForCategory(String category) {
    final normalized = category.trim().toUpperCase();

    if (normalized == 'ABSENCE_CREATED') {
      return SvgPicture.asset(
        'assests/backgrounds/mobile/abscence_icon.svg',
        width: 30,
        height: 30,
      );
    }

    if (normalized == 'CHILD_ASSIGNED_TO_BUS') {
      return const Icon(
        IconsaxPlusLinear.profile_add,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    if (normalized == 'STUDENT_BOARDED_BUS') {
      return const Icon(
        IconsaxPlusLinear.login,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    if (normalized == 'STUDENT_EXITED_BUS') {
      return const Icon(
        IconsaxPlusLinear.logout,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    if (normalized == 'BUS_PROBLEM_REPORTED') {
      return const Icon(
        IconsaxPlusLinear.warning_2,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    if (normalized == 'BUS_REACHED_STOP') {
      return const Icon(
        IconsaxPlusLinear.location,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    if (normalized == 'JOURNEY_STARTED') {
      return const Icon(
        IconsaxPlusLinear.route_square,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    if (normalized == 'JOURNEY_ENDED') {
      return const Icon(
        IconsaxPlusLinear.tick_circle,
        color: Color(0xFF0D4896),
        size: 28,
      );
    }

    return const Icon(
      IconsaxPlusLinear.notification,
      color: Color(0xFF0D4896),
      size: 28,
    );
  }
}