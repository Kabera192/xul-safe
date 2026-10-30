import '../l10n/app_localizations.dart';
import '../../features/driver/models/notification_model.dart';

class LocalizedNotification {
  final String title;
  final String message;
  const LocalizedNotification(this.title, this.message);
}

/// Renders a notification's title/message in the viewer's own language,
/// using the structured `category`/`params` the backend sends alongside
/// the English fallback — instead of displaying that English text verbatim
/// regardless of the app's language setting.
///
/// Falls back to the raw `title`/`message` from the server for any
/// category/shape this function doesn't recognize (including a missing or
/// unexpected param), so an unlocalized notification still displays
/// something rather than nothing.
LocalizedNotification localizeNotification(
  AppLocalizations l10n,
  NotificationModel notification,
) {
  final p = notification.params;
  final fallback =
      LocalizedNotification(notification.title, notification.message);

  String? name(String key) => p[key];

  switch (notification.category) {
    case 'ROUTE_REQUEST_APPROVED':
      final childName = name('childName');
      if (childName == null) return fallback;
      return LocalizedNotification(
        l10n.notifRouteRequestApprovedTitle,
        l10n.notifRouteRequestApprovedBody(childName),
      );

    case 'ROUTE_REQUEST_REJECTED':
      final childName = name('childName');
      if (childName == null) return fallback;
      return LocalizedNotification(
        l10n.notifRouteRequestRejectedTitle,
        l10n.notifRouteRequestRejectedBody(childName),
      );

    default:
      return fallback;
  }
}
