import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../pages/driver_create_stop_page.dart';
import '../pages/driver_edit_stop_page.dart';

class DriverBusRouteForm extends StatelessWidget {
  final BusModel? bus;
  final RouteModel? route;
  final List<StopModel> stops;
  final bool loading;
  final String? error;
  final VoidCallback? onRefreshStops;
  final Map<String, int> stopCounts;

  const DriverBusRouteForm({
    super.key,
    required this.bus,
    required this.stopCounts,
    required this.route,
    required this.stops,
    required this.loading,
    required this.error,
    this.onRefreshStops,
  });

  static const blue = Color(0xFF0D4896);
  static const detailsBg = Color(0xFFF5F8FB);
  static const createBg = Color(0xFFF1F5FA);
  static const timelineColor = Color(0xFFDADBDC);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : detailsBg;
    final dividerColor = isDark ? const Color(0xFF2A3A50) : stroke;
    final closeBtnBg = isDark ? const Color(0xFF1E3050) : const Color(0xFFEBF1FE);
    final plateNumber = bus?.plateNumber;
    final routeName = route?.name;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: closeBtnBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.drvBusDetailsTitle,
            style: TextStyle(
              color: onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (loading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (error != null) ...[
            _ErrorCard(message: error!),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (plateNumber == null || plateNumber.isEmpty)
                        ? l10n.drvNoBusAssignedYet
                        : plateNumber,
                    style: TextStyle(
                      color: (plateNumber == null || plateNumber.isEmpty)
                          ? onSurface.withValues(alpha: 0.4)
                          : onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: dividerColor),
                  const SizedBox(height: 14),
                  Text(
                    (routeName == null || routeName.isEmpty)
                        ? l10n.drvNoRouteAssignedYet
                        : routeName,
                    style: TextStyle(
                      color: (routeName == null || routeName.isEmpty)
                          ? onSurface.withValues(alpha: 0.4)
                          : onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.drvBusStopsTitle,
            style: TextStyle(
              color: onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _StopsTimeline(
            stops: stops,
            stopCounts: stopCounts,
            onRefreshStops: onRefreshStops,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  static const detailsBg = DriverBusRouteForm.detailsBg;
  static const stroke = DriverBusRouteForm.stroke;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2530) : detailsBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A50) : stroke,
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StopsTimeline extends StatelessWidget {
  final List<StopModel> stops;
  final Map<String, int> stopCounts;
  final VoidCallback? onRefreshStops;

  const _StopsTimeline({
    required this.stops,
    required this.stopCounts,
    this.onRefreshStops,
  });

  static const timelineColor = DriverBusRouteForm.timelineColor;

  @override
  Widget build(BuildContext context) {
    final itemCount = stops.isEmpty ? 1 : stops.length + 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          child: Column(
            children: List.generate(itemCount, (index) {
              final isLast = index == itemCount - 1;

              return Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: timelineColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: index == 0 ? 74 : 86,
                      color: timelineColor,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _CreateStopButton(onRefreshStops: onRefreshStops),
              const SizedBox(height: 8),
              if (stops.isEmpty)
                const _EmptyStopsCard()
              else
                ...stops.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _StopCard(

                          stop: entry.value,

                          index: entry.key,
                          studentCount: stopCounts[entry.value.id] ?? 0,

                          onRefreshStops: onRefreshStops,

                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateStopButton extends StatelessWidget {
  final VoidCallback? onRefreshStops;

  const _CreateStopButton({
    this.onRefreshStops,
  });

  static const blue = DriverBusRouteForm.blue;
  static const createBg = DriverBusRouteForm.createBg;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A2530) : createBg;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const DriverCreateStopPage(),
            ),
          );

          if (created == true) {
            onRefreshStops?.call();
          }
        },
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                IconsaxPlusLinear.add_circle,
                size: 17,
                color: blue,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.drvCreateNewBusStopBtn,
                style: const TextStyle(
                  color: blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final StopModel stop;
  final int index;
  final int studentCount;
  final VoidCallback? onRefreshStops;

  const _StopCard({
    required this.stop,
    required this.index,
    required this.studentCount,
    this.onRefreshStops,
  });

  static const blue = DriverBusRouteForm.blue;
  static const stroke = DriverBusRouteForm.stroke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () async {
          final updated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => DriverEditStopPage(stop: stop),
            ),
          );

          if (updated == true) {
            onRefreshStops?.call();
          }
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.drvBusStopNumbered(index + 1),
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stop.locationName.isEmpty
                          ? l10n.drvUnnamedBusStop
                          : stop.locationName,
                      // The timeline connector next to this card assumes a
                      // fixed card height — letting this wrap to 2+ lines
                      // would grow the card and drift the connector out of
                      // alignment with the dots it's meant to link.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.drvStudentCountLabel(studentCount),
                      style: const TextStyle(
                        color: blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                IconsaxPlusLinear.location,
                color: blue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStopsCard extends StatelessWidget {
  const _EmptyStopsCard();

  static const stroke = DriverBusRouteForm.stroke;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        l10n.drvNoBusStopsYet,
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.45),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}