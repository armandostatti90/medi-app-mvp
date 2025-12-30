import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class OnboardingMedicalInfoScreen extends StatefulWidget {
  const OnboardingMedicalInfoScreen({super.key});

  @override
  State<OnboardingMedicalInfoScreen> createState() =>
      _OnboardingMedicalInfoScreenState();
}

class _OnboardingMedicalInfoScreenState
    extends State<OnboardingMedicalInfoScreen> {
  String? _selectedOrgan;
  DateTime? _selectedDate;
  final _notesController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  final List<Map<String, String>> _organs = [
    {'value': 'kidney', 'label': 'Niere', 'icon': '🫘'},
    {'value': 'liver', 'label': 'Leber', 'icon': '🫀'},
    {'value': 'heart', 'label': 'Herz', 'icon': '❤️'},
    {'value': 'lung', 'label': 'Lunge', 'icon': '🫁'},
    {'value': 'pancreas', 'label': 'Pankreas', 'icon': '🩺'},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('de', 'DE'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _skip() async {
    await _finish(skipData: true);
  }

  Future<void> _continue() async {
    await _finish(skipData: false);
  }

  Future<void> _finish({required bool skipData}) async {
    setState(() => _isLoading = true);

    try {
      if (!skipData) {
        await _apiService.updateProfile(
          transplantType: _selectedOrgan,
          transplantDate: _selectedDate?.toIso8601String(),
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          onboardingCompleted: true,
        );
      } else {
        await _apiService.updateProfile(onboardingCompleted: true);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fehler beim Speichern')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medizinische Informationen'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _skip,
            child: const Text('Überspringen'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Deine Transplantation',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Diese Angaben sind optional und helfen uns, bessere Empfehlungen zu geben',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welches Organ?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _organs.map((organ) {
                  final isSelected = _selectedOrgan == organ['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(organ['icon']!),
                        const SizedBox(width: 4),
                        Text(organ['label']!),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedOrgan = organ['value']);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text(
                'Wann war die Transplantation?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                      : 'Datum wählen',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Notizen (optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'z.B. Besonderheiten, Allergien...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Fertig', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
