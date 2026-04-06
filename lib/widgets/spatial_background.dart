import 'package:flutter/material.dart';

class SpatialBackground extends StatelessWidget {
  final Widget child;

  const SpatialBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Base Gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF121418), Color(0xFF161A1E)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF4F7F6),
                        Color(0xFFE8ECE5),
                        Color(0xFFF3EAE3),
                      ],
                    ),
            ),
          ),
          
          // Dark Mode Glowing Radial Gradients
          if (isDark) ...[
            Positioned(
              top: -100,
              left: -100,
              child: _GlowCircle(color: const Color(0xFF1E2824).withOpacity(0.4)),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: _GlowCircle(color: const Color(0xFF1E2824).withOpacity(0.3)),
            ),
          ],

          // Content
          child,
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}
