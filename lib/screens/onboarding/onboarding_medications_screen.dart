import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/add_medication_modal.dart';
import 'onboarding_pet_screen.dart';

class OnboardingMedicationsScreen extends StatefulWidget {
  const OnboardingMedicationsScreen({super.key});

  @override
  State<OnboardingMedicationsScreen> createState() =>
      _OnboardingMedicationsScreenState();
}

class _OnboardingMedicationsScreenState
    extends State<OnboardingMedicationsScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final meds = await _apiService.getMedications();
      setState(() {
        _medications = meds.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Error loading medications: $e');
    }
  }

  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMedicationModal(onAdded: _loadMedications),
    );
  }

  Future<void> _continue() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medikamente')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deine Medikamente',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Du kannst jetzt oder später Medikamente hinzufügen',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Medications List
            if (_medications.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Noch keine Medikamente',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final med = _medications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.medication,
                          color: Colors.blue,
                        ),
                        title: Text(
                          med['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${med['dose']} - ${med['frequency']}'),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: const Text('Medikament hinzufügen'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        _medications.isEmpty ? 'Überspringen' : 'Weiter',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            if (_medications.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _continue,
                child: const Text('Später weitere hinzufügen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
