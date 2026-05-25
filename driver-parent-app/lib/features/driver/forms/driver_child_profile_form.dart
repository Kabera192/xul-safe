import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/child_model.dart';

class DriverChildProfileForm extends StatelessWidget {
  final ChildModel? child;
  final bool loading;
  final String? error;

  const DriverChildProfileForm({
    super.key,
    required this.child,
    required this.loading,
    required this.error,
  });

  static const blue = Color(0xFF0D4896);
  static const cardBg = Color(0xFFE6EDF6);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final fullName = child?.fullName ?? 'Not available';

    final guardianPhone =
        (child?.guardianPhoneNumber == null ||
                child!.guardianPhoneNumber!.isEmpty)
            ? 'Not available'
            : child!.guardianPhoneNumber!;

    final stopName = child?.pickupStopName ?? 'Not assigned';
    final stopCoordinates = child?.pickupStopId == null
        ? 'No coordinates available'
        : 'Coordinates not available yet';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Student profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),

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
            _InfoCard(
              rows: [
                _InfoRow(label: 'Full names', value: fullName),
              ],
            ),

            const SizedBox(height: 16),

            const _SectionTitle('Parent/ Guardian contacts'),
            const SizedBox(height: 10),
            _InfoCard(
              rows: [
                _InfoRow(
                  label: "Guardian's number",
                  value: guardianPhone,
                ),
              ],
            ),

            const SizedBox(height: 16),

            const _SectionTitle('Bus stop'),
            const SizedBox(height: 10),
            _BusStopCard(
              stopName: stopName,
              coordinates: stopCoordinates,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------- Section title ----------------

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ---------------- Info card ----------------

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoCard({
    required this.rows,
  });

  static const cardBg = DriverChildProfileForm.cardBg;
  static const stroke = DriverChildProfileForm.stroke;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stroke, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Divider(height: 1, color: stroke),
          ],
        ],
      ),
    );
  }
}

// ---------------- Info row ----------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  static const blue = DriverChildProfileForm.blue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: blue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value.isEmpty ? 'Not available' : value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF001B3D),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Bus stop card ----------------

class _BusStopCard extends StatelessWidget {
  final String stopName;
  final String coordinates;

  const _BusStopCard({
    required this.stopName,
    required this.coordinates,
  });

  static const blue = DriverChildProfileForm.blue;
  static const cardBg = DriverChildProfileForm.cardBg;
  static const stroke = DriverChildProfileForm.stroke;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stroke, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stopName,
                  style: const TextStyle(
                    color: Color(0xFF001B3D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  coordinates,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            IconsaxPlusLinear.location,
            color: blue,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ---------------- Error ----------------

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  static const cardBg = DriverChildProfileForm.cardBg;
  static const stroke = DriverChildProfileForm.stroke;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stroke, width: 1),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}