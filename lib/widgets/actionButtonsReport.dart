import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final Animation<double> rippleAnimation;
  final VoidCallback onCameraTap;
  final VoidCallback onVideoTap;

  const ActionButtons({
    super.key,
    required this.rippleAnimation,
    required this.onCameraTap,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: rippleAnimation,
          builder: (context, child) {
            final double progress = rippleAnimation.value;
            final double opacity = (0.05 + (1 - progress) * 0.4).clamp(0.0, 1.0);

            return GestureDetector(
              onTap: onCameraTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
                child: child,
              ),
            );
          },
          child: const Icon(
            Icons.camera_alt,
            color: Colors.blueAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),

        AnimatedBuilder(
          animation: rippleAnimation,
          builder: (context, child) {
            final double progress = rippleAnimation.value;
            final double opacity = (0.05 + (1 - progress) * 0.4).clamp(0.0, 1.0);

            return GestureDetector(
              onTap: onVideoTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(opacity),
                  shape: BoxShape.circle,
                  // Xóa boxShadow
                ),
                child: child,
              ),
            );
          },
          child: const Icon(
            Icons.videocam,
            color: Colors.redAccent,
            size: 24,
          ),
        ),
      ],
    );
  }
}
