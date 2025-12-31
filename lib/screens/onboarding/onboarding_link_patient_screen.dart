import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'onboarding_medications_screen.dart';

class OnboardingLinkPatientScreen extends StatefulWidget {
  const OnboardingLinkPatientScreen({super.key});

  @override
  State<OnboardingLinkPatientScreen> createState() =>
      _OnboardingLinkPatientScreenState();
}

class _OnboardingLinkPatientScreenState
    extends State<OnboardingLinkPatientScreen> {
  final _apiService = ApiService();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _linkPatient() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte Code eingeben')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.useInviteCode(code);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erfolgreich verbunden!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingMedicationsScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler: Code ungültig oder abgelaufen'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _skip() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingMedicationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient verbinden')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mit Patient verbinden',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Gib den Einladungscode des Patienten ein',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.link, size: 64, color: Colors.blue),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Einladungscode',
                        hintText: 'ABC-DEF-123',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _linkPatient,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Verbinden',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Center(
              child: Column(
                children: [
                  Text(
                    'Noch keinen Code?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Später verbinden'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
