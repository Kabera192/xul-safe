import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverEditStopSuccessForm extends StatelessWidget {
  final VoidCallback onDone;

  const DriverEditStopSuccessForm({
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

          // ✅ icon + shadow (same pattern as edit)
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assests/backgrounds/mobile/success_checkmark.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 2),
                SvgPicture.asset(
                  'assests/backgrounds/mobile/edit_pen_shadow.svg',
                  height: 14,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Bus stop Updated',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF001B3D),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'You have successfully updated this bus stop. The changes will now appear in the route stops list.',
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