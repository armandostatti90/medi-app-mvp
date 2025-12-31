import 'package:flutter/material.dart';
import 'onboarding_banner.dart';

class LockedScreenOverlay extends StatelessWidget {
  final Widget child; // Der eigentliche Screen-Content

  const LockedScreenOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Actual content (transparent/disabled)
        Opacity(opacity: 0.3, child: AbsorbPointer(child: child)),

        // Onboarding Banner drüber
        const Positioned(top: 0, left: 0, right: 0, child: OnboardingBanner()),
      ],
    );
  }
}
