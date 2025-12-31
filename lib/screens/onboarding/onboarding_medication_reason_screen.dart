import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'onboarding_medical_info_screen.dart';
import 'onboarding_pet_screen.dart';
import 'onboarding_supplements_reason_screen.dart';

class OnboardingMedicationReasonScreen extends StatefulWidget {
  const OnboardingMedicationReasonScreen({super.key});

  @override
  State<OnboardingMedicationReasonScreen> createState() =>
      _OnboardingMedicationReasonScreenState();
}

class _OnboardingMedicationReasonScreenState
    extends State<OnboardingMedicationReasonScreen> {
  final _apiService = ApiService();
  String? _selectedReason;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _reasons = [
    {
      'value': 'chronic',
      'title': 'Chronisch krank / Dauertherapie',
      'subtitle': 'Langfristige medizinische Behandlung',
      'icon': Icons.healing,
    },
    {
      'value': 'care_dependent',
      'title': 'Pflegebedürftig',
      'subtitle': 'Benötige Unterstützung bei der Einnahme',
      'icon': Icons.accessibility_new,
    },
    {
      'value': 'supplements',
      'title': 'Supplements / Vitamine',
      'subtitle': 'Nahrungsergänzungsmittel',
      'icon': Icons.energy_savings_leaf,
    },
  ];

  Future<void> _continue() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte wähle eine Option')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updateProfile(
        customData: {'medication_reason': _selectedReason},
      );

      if (_selectedReason == 'chronic' || _selectedReason == 'care_dependent') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OnboardingMedicalInfoScreen(reason: _selectedReason!),
          ),
        );
      } else {
        // Supplements → ask why
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingSupplementsReasonScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deine Medikamente')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warum nimmst du Medikamente?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hilft uns, dich optimal zu unterstützen',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView.builder(
                itemCount: _reasons.length,
                itemBuilder: (context, index) {
                  final reason = _reasons[index];
                  final isSelected = _selectedReason == reason['value'];

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected ? Colors.blue.shade50 : null,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(
                        reason['icon'],
                        size: 40,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        reason['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(reason['subtitle']),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedReason = reason['value'];
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Weiter', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
