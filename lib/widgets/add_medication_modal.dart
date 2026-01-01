import 'package:flutter/material.dart';
import 'package:medi_rag_app/services/notification_service.dart';
import '../services/api_service.dart';
import '../services/medication_notification_helper.dart';

class AddMedicationModal extends StatefulWidget {
  final Function() onAdded;

  const AddMedicationModal({super.key, required this.onAdded});

  @override
  State<AddMedicationModal> createState() => _AddMedicationModalState();
}

class _AddMedicationModalState extends State<AddMedicationModal> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  int _currentStep = 0;
  List<dynamic> _searchResults = [];
  List<Map<String, dynamic>> _selectedMeds = [];
  Map<int, int> _quantities = {}; // med_id -> quantity
  List<String> _times = [];
  bool _isSearching = false;
  bool _isSaving = false;

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _apiService.searchMedications(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  void _toggleMedSelection(Map<String, dynamic> med) {
    setState(() {
      final index = _selectedMeds.indexWhere((m) => m['id'] == med['id']);
      if (index >= 0) {
        _selectedMeds.removeAt(index);
        _quantities.remove(med['id']);
      } else {
        _selectedMeds.add(med);
        _quantities[med['id']] = 1; // Default 1
      }
    });
  }

  bool _isMedSelected(Map<String, dynamic> med) {
    return _selectedMeds.any((m) => m['id'] == med['id']);
  }

  double _calculateTotalDose() {
    double total = 0;
    for (var med in _selectedMeds) {
      final qty = _quantities[med['id']] ?? 1;
      final strength = med['strength'] as num;
      total += strength * qty;
    }
    return total;
  }

  void _addTime() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
      if (time != null) {
        final timeStr =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        setState(() {
          _times.add(timeStr);
        });
      }
    });
  }

  Future<void> _save() async {
    if (_selectedMeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Medikamente auswählen')),
      );
      return;
    }

    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Einnahmezeiten festlegen')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build medication name
      final medNames = _selectedMeds
          .map((m) => m['active_ingredient'])
          .toSet()
          .join('/');
      final totalDose = _calculateTotalDose();

      // Build composition
      final composition = _selectedMeds
          .map(
            (med) => {
              'med_id': med['id'],
              'strength': '${med['strength']}${med['strength_unit']}',
              'quantity': _quantities[med['id']] ?? 1,
            },
          )
          .toList();

      await _apiService.addMedicationWithComposition(
        name: medNames,
        targetDose: '${totalDose}mg',
        composition: composition,
        times: _times,
      );

      await MedicationNotificationHelper.rescheduleAll();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medikament hinzugefügt!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onAdded();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Medikament suchen',
            hintText: 'z.B. Tacrolimus, Envarsus...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _search,
        ),

        const SizedBox(height: 16),

        // Selected Meds Summary
        if (_selectedMeds.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ausgewählt:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._selectedMeds.map(
                  (med) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text('${med['name']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Search Results
        if (_searchResults.isNotEmpty) ...[
          const Text(
            'Suchergebnisse:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...(_searchResults.take(10).map((med) {
            final isSelected = _isMedSelected(med);
            return Card(
              color: isSelected ? Colors.blue.shade50 : null,
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (checked) {
                  _toggleMedSelection(med);
                },
                secondary: Icon(
                  Icons.medication,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  med['name'],
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${med['active_ingredient']} • ${med['strength']}${med['strength_unit']} • ${med['form']}',
                ),
              ),
            );
          })),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Anzahl pro Einnahme',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ..._selectedMeds.map((med) {
          final qty = _quantities[med['id']] ?? 1;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: qty > 1
                            ? () {
                                setState(() {
                                  _quantities[med['id']] = qty - 1;
                                });
                              }
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$qty Stück',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            _quantities[med['id']] = qty + 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Total Dose
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gesamt pro Einnahme:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_calculateTotalDose()}mg',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Einnahmezeiten',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Times List
        if (_times.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Noch keine Zeiten festgelegt')),
            ),
          )
        else
          ..._times.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _times.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),

        const SizedBox(height: 16),

        // Add Time Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addTime,
            icon: const Icon(Icons.add),
            label: const Text('Zeit hinzufügen'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentStep == 0
                          ? 'Medikament auswählen'
                          : _currentStep == 1
                          ? 'Anzahl festlegen'
                          : 'Zeiten festlegen',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Step Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildStepIndicator(0, 'Auswahl'),
                    Expanded(
                      child: Divider(
                        color: _currentStep > 0 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    _buildStepIndicator(1, 'Anzahl'),
                    Expanded(
                      child: Divider(
                        color: _currentStep > 1 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    _buildStepIndicator(2, 'Zeiten'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (_currentStep == 0) _buildStep1(),
                    if (_currentStep == 1) _buildStep2(),
                    if (_currentStep == 2) _buildStep3(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Zurück'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                if (_currentStep < 2) {
                                  if (_currentStep == 0 &&
                                      _selectedMeds.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Bitte Medikamente auswählen',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _currentStep++;
                                  });
                                } else {
                                  _save();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_currentStep < 2 ? 'Weiter' : 'Speichern'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.blue
                : isActive
                ? Colors.blue
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.blue : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
