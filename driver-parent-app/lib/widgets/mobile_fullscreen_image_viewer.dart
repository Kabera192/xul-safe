import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom view of an image already held in memory.
///
/// Opened by tapping a cropped thumbnail elsewhere in the app (the same
/// "tap a profile photo to see the full image" pattern as social apps).
class MobileFullscreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;
  final Object? heroTag;

  const MobileFullscreenImageViewer({
    super.key,
    required this.imageBytes,
    this.heroTag,
  });

  /// Pushes the viewer as a fullscreen, fade-in route.
  static Future<void> show(
    BuildContext context, {
    required Uint8List imageBytes,
    Object? heroTag,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: MobileFullscreenImageViewer(
              imageBytes: imageBytes,
              heroTag: heroTag,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.memory(
      imageBytes,
      fit: BoxFit.contain,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: heroTag != null
                    ? Hero(tag: heroTag!, child: image)
                    : image,
              ),
            ),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              child: Material(
                color: Colors.white.withValues(alpha: 0.15),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
