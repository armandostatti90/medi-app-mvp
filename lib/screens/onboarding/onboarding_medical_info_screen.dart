import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'onboarding_medications_screen.dart';

class OnboardingMedicalInfoScreen extends StatefulWidget {
  final String reason; // 'chronic' or 'care_dependent'

  const OnboardingMedicalInfoScreen({super.key, required this.reason});

  @override
  State<OnboardingMedicalInfoScreen> createState() =>
      _OnboardingMedicalInfoScreenState();
}

class _OnboardingMedicalInfoScreenState
    extends State<OnboardingMedicalInfoScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Disease category
  String? _selectedCategory;
  String? _selectedOrgan; // For transplantation

  // Common fields
  DateTime? _diagnosisDate;
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  // Care dependent specific
  String? _careLevel;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _diseaseCategories = [
    {
      'value': 'transplantation',
      'title': 'Transplantation',
      'icon': Icons.favorite,
      'hasSubcategory': true,
    },
    {
      'value': 'diabetes',
      'title': 'Diabetes',
      'icon': Icons.water_drop,
      'hasSubcategory': false,
    },
    {
      'value': 'autoimmune',
      'title': 'Autoimmunerkrankung',
      'icon': Icons.shield,
      'hasSubcategory': false,
    },
    {
      'value': 'cardiovascular',
      'title': 'Herz-Kreislauf',
      'icon': Icons.monitor_heart,
      'hasSubcategory': false,
    },
    {
      'value': 'mental',
      'title': 'Psychische Erkrankung',
      'icon': Icons.psychology,
      'hasSubcategory': false,
    },
    {
      'value': 'respiratory',
      'title': 'Atemwegserkrankung',
      'icon': Icons.air,
      'hasSubcategory': false,
    },
    {
      'value': 'multiple',
      'title': 'Mehrfacherkrankung',
      'icon': Icons.medical_services,
      'hasSubcategory': false,
    },
    {
      'value': 'other',
      'title': 'Sonstige',
      'icon': Icons.more_horiz,
      'hasSubcategory': false,
    },
  ];

  final List<String> _organs = [
    'Niere',
    'Leber',
    'Herz',
    'Lunge',
    'Pankreas',
    'Dünndarm',
    'Multiorgan',
  ];

  final List<String> _careLevels = [
    'Pflegegrad 1',
    'Pflegegrad 2',
    'Pflegegrad 3',
    'Pflegegrad 4',
    'Pflegegrad 5',
  ];

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('de', 'DE'),
    );

    if (date != null) {
      setState(() {
        _diagnosisDate = date;
      });
    }
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.reason == 'chronic' && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle eine Kategorie')),
      );
      return;
    }

    if (_selectedCategory == 'transplantation' && _selectedOrgan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte wähle ein Organ')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{};

      if (widget.reason == 'chronic') {
        data['disease_category'] = _selectedCategory;
        if (_selectedCategory == 'transplantation') {
          data['organ_type'] = _selectedOrgan;
        }
      }

      data['diagnosis_date'] = _diagnosisDate?.toIso8601String();
      data['treating_doctor'] = _doctorController.text.trim();
      data['medical_notes'] = _notesController.text.trim();

      if (widget.reason == 'care_dependent') {
        data['care_level'] = _careLevel;
      }

      await _apiService.updateProfile(customData: data);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingMedicationsScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getTitle() {
    if (widget.reason == 'chronic') {
      return 'Deine Erkrankung';
    } else {
      return 'Deine Situation';
    }
  }

  String _getSubtitle() {
    if (widget.reason == 'chronic') {
      return 'Hilft uns, dich optimal zu unterstützen';
    } else {
      return 'Diese Infos helfen uns bei der Betreuung';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medizinische Info')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              _getTitle(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getSubtitle(),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Disease Category (only for chronic)
            if (widget.reason == 'chronic') ...[
              const Text(
                'Was trifft auf dich zu?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _diseaseCategories.map((category) {
                  final isSelected = _selectedCategory == category['value'];
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['icon'],
                          size: 20,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(category['title']),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category['value'] : null;
                        // Reset organ selection when changing category
                        if (_selectedCategory != 'transplantation') {
                          _selectedOrgan = null;
                        }
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Organ Selection (only if transplantation selected)
              if (_selectedCategory == 'transplantation') ...[
                const Text(
                  'Welches Organ?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _organs.map((organ) {
                    final isSelected = _selectedOrgan == organ;
                    return ChoiceChip(
                      label: Text(organ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedOrgan = selected ? organ : null;
                        });
                      },
                      selectedColor: Colors.blue.shade100,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
              ],
            ],

            // Care Level (only for care_dependent)
            if (widget.reason == 'care_dependent') ...[
              const Text(
                'Pflegegrad (optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _careLevels.map((level) {
                  final isSelected = _careLevel == level;
                  return ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _careLevel = selected ? level : null;
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
            ],

            // Diagnosis Date
            const Text(
              'Seit wann? (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _diagnosisDate == null
                      ? 'Datum wählen'
                      : '${_diagnosisDate!.day}.${_diagnosisDate!.month}.${_diagnosisDate!.year}',
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: _selectDate,
              ),
            ),

            const SizedBox(height: 24),

            // Treating Doctor (only for chronic)
            if (widget.reason == 'chronic') ...[
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Behandelnder Arzt (optional)',
                  hintText: 'Dr. Müller, Internist',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 24),
            ],

            // Notes
            const Text(
              'Weitere Informationen (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'z.B. Allergien, Unverträglichkeiten, Besonderheiten...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

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

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingMedicationsScreen(),
                  ),
                );
              },
              child: const Text('Überspringen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
