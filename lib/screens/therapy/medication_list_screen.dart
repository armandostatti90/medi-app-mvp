import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/add_medication_modal.dart';
import '../../widgets/edit_medication_modal.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final _apiService = ApiService();

  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);

    try {
      final meds = await _apiService.getAllMedications(); // ← Geändert!

      print('🔍 Loaded medications: $meds');

      setState(() {
        _medications = meds.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMedication(int id, String name) async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medikament löschen?'),
        content: Text('Möchtest du "$name" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteMedication(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name gelöscht'),
          backgroundColor: Colors.green,
        ),
      );

      _loadMedications();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future<void> _toggleMedication(
    int id,
    String name,
    bool currentlyActive,
  ) async {
    try {
      await _apiService.toggleMedication(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentlyActive ? '$name pausiert' : '$name aktiviert'),
          backgroundColor: Colors.green,
        ),
      );

      _loadMedications();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Widget _buildMedicationCard(Map<String, dynamic> med, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? null : Colors.grey.shade100,
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: isActive ? Colors.blue : Colors.grey,
          size: 32,
        ),
        title: Text(
          med['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${med['dose']} • ${med['frequency']}'),
            if (!isActive)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Chip(
                  label: Text('Pausiert', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => EditMedicationModal(
                  medication: med,
                  onUpdated: _loadMedications,
                ),
              );
            } else if (value == 'toggle') {
              _toggleMedication(med['id'], med['name'], isActive);
            } else if (value == 'delete') {
              _deleteMedication(med['id'], med['name']);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Bearbeiten'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(isActive ? Icons.pause : Icons.play_arrow, size: 20),
                  const SizedBox(width: 12),
                  Text(isActive ? 'Pausieren' : 'Aktivieren'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Löschen', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Medikamente')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Keine Medikamente',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Active Medications
                if (_medications
                    .where((m) => m['active'] == true)
                    .isNotEmpty) ...[
                  const Text(
                    'Aktive Medikamente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ..._medications
                      .where((m) => m['active'] == true)
                      .map((med) => _buildMedicationCard(med, true)),
                ],

                // Paused Medications
                if (_medications
                    .where((m) => m['active'] == false)
                    .isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Pausierte Medikamente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._medications
                      .where((m) => m['active'] == false)
                      .map((med) => _buildMedicationCard(med, false)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddMedicationModal(onAdded: _loadMedications),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
