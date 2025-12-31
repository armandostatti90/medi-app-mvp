import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditMedicationModal extends StatefulWidget {
  final Map<String, dynamic> medication;
  final Function() onUpdated;

  const EditMedicationModal({
    super.key,
    required this.medication,
    required this.onUpdated,
  });

  @override
  State<EditMedicationModal> createState() => _EditMedicationModalState();
}

class _EditMedicationModalState extends State<EditMedicationModal> {
  final _apiService = ApiService();
  final _doseController = TextEditingController();

  List<String> _times = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill existing data
    _doseController.text = widget.medication['dose'];
    _times = List<String>.from(widget.medication['times']);
  }

  void _addTime() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
      if (time != null) {
        final timeStr =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        setState(() {
          _times.add(timeStr);
          _times.sort();
        });
      }
    });
  }

  void _removeTime(int index) {
    setState(() {
      _times.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_doseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte Dosierung eingeben')));
      return;
    }

    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte mindestens eine Zeit festlegen')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _apiService.updateMedication(
        medicationId: widget.medication['id'],
        name: widget.medication['name'],
        dose: _doseController.text.trim(),
        frequency: '${_times.length}x täglich',
        times: _times,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medikament aktualisiert!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                    const Text(
                      'Medikament bearbeiten',
                      style: TextStyle(
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Medication Name (read-only)
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Medikament',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      controller: TextEditingController(
                        text: widget.medication['name'],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dose (editable)
                    TextField(
                      controller: _doseController,
                      decoration: const InputDecoration(
                        labelText: 'Dosierung',
                        hintText: 'z.B. 3.5mg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Times
                    const Text(
                      'Einnahmezeiten',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_times.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text('Noch keine Zeiten festgelegt'),
                          ),
                        ),
                      )
                    else
                      ..._times.asMap().entries.map((entry) {
                        final index = entry.key;
                        final time = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.access_time,
                              color: Colors.blue,
                            ),
                            title: Text(
                              time,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTime(index),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Add Time Button
                    OutlinedButton.icon(
                      onPressed: _addTime,
                      icon: const Icon(Icons.add),
                      label: const Text('Zeit hinzufügen'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Save Button
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
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
                        : const Text('Speichern'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _doseController.dispose();
    super.dispose();
  }
}
