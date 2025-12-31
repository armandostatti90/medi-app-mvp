import 'package:flutter/material.dart';
import 'onboarding_banner.dart';

class OnboardingRequired extends StatelessWidget {
  const OnboardingRequired({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Feature gesperrt',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bitte vervollständige zuerst dein Profil, um diese Funktion nutzen zu können.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const OnboardingBanner(),
          ],
        ),
      ),
    );
  }
}
