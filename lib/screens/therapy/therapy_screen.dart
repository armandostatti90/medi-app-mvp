import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/locked_screen_overlay.dart';
import '../../widgets/onboarding_banner.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  final _apiService = ApiService();
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOnboarding(); // Reload when coming back
  }

  Future<void> _checkOnboarding() async {
    final completed = await _apiService.isOnboardingCompleted();
    setState(() {
      _isOnboardingCompleted = completed;
      _isLoading = false;
    });
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Content hier (wird transparent wenn locked)
        const Text('Adhärenz Charts'),
        const SizedBox(height: 100),
        Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: Text('Chart Placeholder')),
        ),
        const SizedBox(height: 20),
        const Text('Medikamente'),
        // ... more content
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Adhärenz Übersicht',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: Text('Chart Placeholder')),
        ),
        // ... more content
      ],
    );

    if (!_isOnboardingCompleted) {
      return LockedScreenOverlay(child: content);
    }

    // Unlocked - mit Banner oben
    return ListView(children: [const OnboardingBanner(), content]);
  }
}
