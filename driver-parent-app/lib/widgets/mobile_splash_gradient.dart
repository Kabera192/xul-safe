import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final String svgAsset;

  const GradientBackground({
    super.key,
    required this.child,
    required this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: isDark
                  ? const [
                      Color(0xFF04090F),
                      Color(0xFF071224),
                    ]
                  : const [
                      Color(0xFF0D4896),
                      Color(0xFF1A6DE3),
                    ],
            ),
          ),
        ),

        SvgPicture.asset(
          svgAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}