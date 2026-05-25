import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverCreateStopSuccessForm extends StatelessWidget {
  final VoidCallback onDone;

  const DriverCreateStopSuccessForm({
    super.key,
    required this.onDone,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // ✅ Success icon (same pattern as edit forms)
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assests/backgrounds/mobile/success_checkmark.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                SvgPicture.asset(
                  'assests/backgrounds/mobile/edit_pen_shadow.svg',
                  height: 14,
                ),
              ],
            ),
          ),

          // ✅ Title (centered)
          const Center(
            child: Text(
              'Bus stop Saved',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF001B3D),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Description (centered)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'You have successfully added a new bus stop to the route you can see it among other bus stops and assign students to it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const Spacer(),

          // ✅ Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}