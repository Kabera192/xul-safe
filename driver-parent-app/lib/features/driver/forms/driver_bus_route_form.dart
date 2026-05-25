import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

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
  final Map<int, int> stopCounts;

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
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF1FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bus details',
            style: TextStyle(
              color: Colors.black87,
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
                color: detailsBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (plateNumber == null || plateNumber.isEmpty)
                        ? 'No bus assigned yet'
                        : plateNumber,
                    style: TextStyle(
                      color: (plateNumber == null || plateNumber.isEmpty)
                          ? Colors.black45
                          : const Color(0xFF001B3D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: stroke),
                  const SizedBox(height: 14),
                  Text(
                    (routeName == null || routeName.isEmpty)
                        ? 'No route assigned yet'
                        : routeName,
                    style: TextStyle(
                      color: (routeName == null || routeName.isEmpty)
                          ? Colors.black45
                          : const Color(0xFF001B3D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Bus stops',
            style: TextStyle(
              color: Colors.black87,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: detailsBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: stroke, width: 1),
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
  final Map<int, int> stopCounts;
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
    return Material(
      color: createBg,
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconsaxPlusLinear.add_circle,
                size: 17,
                color: blue,
              ),
              SizedBox(width: 8),
              Text(
                'Create new bus stop',
                style: TextStyle(
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
            color: Colors.white,
            border: Border.all(color: stroke, width: 1),
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
                      'Bus stop ${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF001B3D),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stop.locationName.isEmpty
                          ? 'Unnamed bus stop'
                          : stop.locationName,
                      style: const TextStyle(
                        color: Color(0xFF233A5A),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
  '$studentCount ${studentCount == 1 ? 'student' : 'students'}',
  style: const TextStyle(
    color: blue,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  ),
),],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: stroke, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'No bus stops created yet',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}