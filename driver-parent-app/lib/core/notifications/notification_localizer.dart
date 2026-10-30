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
    case 'ABSENCE_CREATED':
      final childName = name('childName');
      final session = p['session'];
      if (childName == null || session == null) return fallback;
      return LocalizedNotification(
        l10n.notifAbsenceMarkedTitle,
        session == 'MORNING'
            ? l10n.notifAbsenceMarkedMorning(childName)
            : l10n.notifAbsenceMarkedAfternoon(childName),
      );

    case 'ABSENCE_REPORTED_BY_PARENT':
      final childName = name('childName');
      final absenceType = p['absenceType'];
      if (childName == null || absenceType == null) return fallback;
      final title = l10n.notifAbsenceReportedTitle(childName);
      switch (absenceType) {
        case 'MORNING':
          return LocalizedNotification(
              title, l10n.notifAbsenceReportedMorning(childName));
        case 'EVENING':
          return LocalizedNotification(
              title, l10n.notifAbsenceReportedEvening(childName));
        case 'MULTIPLE_DAYS':
          return LocalizedNotification(
            title,
            l10n.notifAbsenceReportedRange(
              childName,
              p['startDate'] ?? '',
              p['endDate'] ?? '',
            ),
          );
        default:
          return fallback;
      }

    case 'STUDENT_BOARDED_BUS':
      final childName = name('childName');
      final session = p['session'];
      if (childName == null || session == null) return fallback;
      return session == 'MORNING'
          ? LocalizedNotification(
              l10n.notifBoardedMorningTitle,
              l10n.notifBoardedMorningBody(childName),
            )
          : LocalizedNotification(
              l10n.notifBoardedAfternoonTitle,
              l10n.notifBoardedAfternoonBody(childName),
            );

    case 'STUDENT_EXITED_BUS':
      final childName = name('childName');
      final session = p['session'];
      if (childName == null || session == null) return fallback;
      return session == 'MORNING'
          ? LocalizedNotification(
              l10n.notifExitedMorningTitle,
              l10n.notifExitedMorningBody(childName),
            )
          : LocalizedNotification(
              l10n.notifExitedAfternoonTitle,
              l10n.notifExitedAfternoonBody(childName),
            );

    case 'BUS_REACHED_STOP':
      final childName = name('childName');
      final stopName = name('stopName');
      final session = p['session'];
      if (childName == null || stopName == null || session == null) {
        return fallback;
      }
      return LocalizedNotification(
        l10n.notifBusReachedStopTitle(stopName),
        session == 'MORNING'
            ? l10n.notifBusReachedStopMorning(childName, stopName)
            : l10n.notifBusReachedStopAfternoon(childName, stopName),
      );

    case 'JOURNEY_STARTED':
      final tripType = p['tripType'];
      if (tripType == null) return fallback;
      return LocalizedNotification(
        l10n.notifJourneyStartedTitle,
        tripType == 'MORNING_PICKUP'
            ? l10n.notifJourneyStartedMorning
            : l10n.notifJourneyStartedAfternoon,
      );

    case 'JOURNEY_ENDED':
      return LocalizedNotification(
        l10n.notifJourneyEndedTitle,
        l10n.notifJourneyEndedBody,
      );

    case 'INCIDENT_REPORTED':
      final kind = p['kind'];
      if (kind == 'OPERATIONAL') {
        final impact = p['journeyImpact'];
        final body = switch (impact) {
          'STOPPED' => l10n.notifJourneyStoppedBody,
          'DELAYED' => l10n.notifJourneyDelayedBody,
          'NONE' => l10n.notifIncidentReportedDefaultBody,
          _ => null,
        };
        if (body == null) return fallback;
        return LocalizedNotification(l10n.notifJourneyAffectedTitle, body);
      }
      if (kind == 'DETAILED') {
        // The body is the reporter's own free-text description — not
        // something to translate, only the title is localized.
        return LocalizedNotification(
          l10n.notifIncidentReportedTitle,
          notification.message,
        );
      }
      return fallback;

    case 'PARENT_REGISTERED':
      final firstName = p['firstName'];
      final lastName = p['lastName'];
      if (firstName == null || lastName == null) return fallback;
      return LocalizedNotification(
        l10n.notifNewParentRegisteredTitle,
        l10n.notifNewParentRegisteredBody(firstName, lastName),
      );

    case 'STUDENT_ADDED':
      final childName = name('childName');
      if (childName == null) return fallback;
      return LocalizedNotification(
        l10n.notifNewStudentAddedTitle,
        l10n.notifNewStudentAddedBody(childName),
      );

    case 'BUS_CAPACITY_EXCEEDED':
      final plate = p['plateNumber'];
      final capacity = p['capacity'];
      if (plate == null || capacity == null) return fallback;
      return LocalizedNotification(
        l10n.notifBusCapacityExceededTitle,
        l10n.notifBusCapacityExceededBody(plate, capacity),
      );

    default:
      return fallback;
  }
}
