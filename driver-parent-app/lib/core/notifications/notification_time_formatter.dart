import '../l10n/app_localizations.dart';

/// Formats a notification's `sentAt` (epoch millis from the backend) as a
/// clock time plus how long ago that was, e.g. "14:32 · 3h ago" today,
/// "Yesterday · 09:05", or "24/11 · 09:05" for anything older.
String formatNotificationTimestamp(int? sentAtMillis, AppLocalizations l10n) {
  if (sentAtMillis == null) return '';

  final sentAt = DateTime.fromMillisecondsSinceEpoch(sentAtMillis);
  final now = DateTime.now();

  final time =
      '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}';

  final sentDate = DateTime(sentAt.year, sentAt.month, sentAt.day);
  final nowDate = DateTime(now.year, now.month, now.day);
  final dayDiff = nowDate.difference(sentDate).inDays;
  final elapsed = now.difference(sentAt);

  if (dayDiff == 0) {
    if (elapsed.inMinutes < 1) return l10n.notifTimeJustNow;
    if (elapsed.inMinutes < 60) {
      return '$time · ${l10n.notifTimeMinutesAgo(elapsed.inMinutes)}';
    }
    return '$time · ${l10n.notifTimeHoursAgo(elapsed.inHours)}';
  }

  if (dayDiff == 1) {
    return '${l10n.notifTimeYesterday} · $time';
  }

  if (dayDiff < 7) {
    return '$time · ${l10n.notifTimeDaysAgo(dayDiff)}';
  }

  final date =
      '${sentAt.day.toString().padLeft(2, '0')}/${sentAt.month.toString().padLeft(2, '0')}';
  return '$date · $time';
}
