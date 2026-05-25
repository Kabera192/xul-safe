import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class MobileGpsBanner extends StatelessWidget {
  final String text;

  const MobileGpsBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color(0xFF7A8492),
              ),

              // reuse the same waves svg
              SvgPicture.asset(
                'assests/backgrounds/mobile/mobile_offline_banner_waves.svg',
                fit: BoxFit.fill,
              ),

              Container(
                color: Colors.black.withOpacity(0.12),
              ),

              Row(
                children: [
                  const SizedBox(width: 20),
                  const Icon(
                    IconsaxPlusLinear.location_slash,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectionContainer.disabled(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}