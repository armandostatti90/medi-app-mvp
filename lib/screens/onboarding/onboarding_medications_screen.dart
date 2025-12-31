import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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
  final List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;

  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddMedicationSheet(
        onAdd: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _continue() async {
    setState(() => _isLoading = true);

    try {
      // Save all medications
      for (var med in _medications) {
        await _apiService.addMedication(
          name: med['name'],
          dose: med['dose'],
          frequency: med['frequency'],
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPetScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _skip() async {
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeMedication(index),
                        ),
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
                onPressed: _skip,
                child: const Text('Später weitere hinzufügen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Add Medication Bottom Sheet
class _AddMedicationSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _AddMedicationSheet({required this.onAdd});

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  String _frequency = '1x täglich';

  final List<String> _frequencies = [
    '1x täglich',
    '2x täglich',
    '3x täglich',
    'Bei Bedarf',
    'Wöchentlich',
  ];

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({
        'name': _nameController.text.trim(),
        'dose': _doseController.text.trim(),
        'frequency': _frequency,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medikament hinzufügen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z.B. Aspirin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte Name eingeben';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Dose
            TextFormField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dosierung',
                hintText: 'z.B. 100mg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte Dosierung eingeben';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Frequency
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Häufigkeit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              items: _frequencies.map((freq) {
                return DropdownMenuItem(value: freq, child: Text(freq));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Hinzufügen'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }
}
