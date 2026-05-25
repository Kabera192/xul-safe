import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MobileOfflineBanner extends StatelessWidget {
  final String text; 
  const MobileOfflineBanner({
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
                color: const Color(0xFF7A8492), // tweak to match Figma
              ),

              // waves svg background, stretched to fill
              SvgPicture.asset(
                'assests/backgrounds/mobile/mobile_offline_banner_waves.svg',
                fit: BoxFit.fill, // stretch, not zoom/crop
              ),

              // optional subtle dark overlay so text stays readable
              Container(
                color: Colors.black.withOpacity(0.12),
              ),

              // content
              Row(
                children: [
                  const SizedBox(width: 20),
                  const Icon(
                    Icons.wifi_off,
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