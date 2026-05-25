import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class DriverProfilePhotoForm extends StatelessWidget {
  static const blue = Color(0xFF0D4896);
  static const uploadTextBlue = Color(0xFF1358B6);
  static const cancelBg = Color(0xFFEBF1FE);
  static const uploadBoxBg = Color(0xFFF1F5FA);
  static const dashColor = Color(0xFFD6E2F3);

  final File? selectedImage;
  final bool saving;
  final String? error;
  final VoidCallback onPickPhoto;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const DriverProfilePhotoForm({
    super.key,
    required this.selectedImage,
    required this.saving,
    required this.error,
    required this.onPickPhoto,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: saving ? null : onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: cancelBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Image.asset(
                    'assests/backgrounds/mobile/edit_pen.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                SvgPicture.asset(
                  'assests/backgrounds/mobile/edit_pen_shadow.svg',
                  height: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Change profile picture',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          if (error != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: saving ? null : onPickPhoto,
            child: _DashedUploadBox(
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) {
                          return const _UploadPlaceholder();
                        },
                      ),
                    )
                  : const _UploadPlaceholder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (saving || !hasImage) ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                elevation: 0,
                disabledBackgroundColor: blue.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                saving ? 'Saving…' : 'Save changes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    const uploadTextBlue = DriverProfilePhotoForm.uploadTextBlue;

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.profile_add,
            color: uploadTextBlue,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'Profile picture',
            style: TextStyle(
              color: uploadTextBlue,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedUploadBox extends StatelessWidget {
  final Widget child;

  const _DashedUploadBox({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const uploadBoxBg = DriverProfilePhotoForm.uploadBoxBg;
    const dashColor = DriverProfilePhotoForm.dashColor;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: uploadBoxBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: dashColor,
          radius: 18,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox.expand(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    const strokeWidth = 1.4;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}