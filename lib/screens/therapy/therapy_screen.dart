import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/add_medication_modal.dart';
import '../../widgets/locked_screen_overlay.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  final _apiService = ApiService();

  Map<String, dynamic>? _schedule;
  bool _isLoading = true;
  bool _isOnboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkOnboardingAndLoad();
  }

  Future<void> _checkOnboardingAndLoad() async {
    setState(() => _isLoading = true);

    try {
      final completed = await _apiService.isOnboardingCompleted();

      setState(() {
        _isOnboardingCompleted = completed;
      });

      if (completed) {
        await _loadSchedule();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final schedule = await _apiService.getTodaySchedule();

      setState(() {
        _schedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading schedule: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTimeUntil(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return 'in ${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return 'in ${minutes}m';
    } else {
      return 'jetzt';
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schedule = _schedule?['schedule'] as List? ?? [];
    final nextIntake = _schedule?['next_intake'] as Map<String, dynamic>?;

    return RefreshIndicator(
      onRefresh: _loadSchedule,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Next Intake Hero (grouped)
          if (nextIntake != null) ...[
            Card(
              color: Colors.blue.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Nächste Einnahme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '${nextIntake['time']} • ${_formatTimeUntil(nextIntake['seconds_until'])}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Medications list
                    ...(nextIntake['medications'] as List).map((med) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.medication,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    med['dose'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Als genommen markieren - kommt bald!',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          'Alle ${(nextIntake['medications'] as List).length} Medikamente als genommen markieren',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],

          // Today's Schedule (grouped by time)
          const Text(
            'Heutiger Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (schedule.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: const [
                    Icon(Icons.medication, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Noch keine Medikamente'),
                  ],
                ),
              ),
            )
          else
            ...schedule.map((timeSlot) {
              final time = timeSlot['time'];
              final meds = timeSlot['medications'] as List;
              final allTaken = timeSlot['all_taken'] as bool;
              final isUpcoming = timeSlot['is_upcoming'] as bool;
              final takenCount = timeSlot['taken_count'] as int;
              final totalCount = timeSlot['total_count'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    allTaken ? Icons.check_circle : Icons.access_time,
                    color: allTaken
                        ? Colors.green
                        : (isUpcoming ? Colors.blue : Colors.orange),
                    size: 32,
                  ),
                  title: Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalCount Med${totalCount > 1 ? 'ikamente' : 'ikament'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  subtitle: allTaken
                      ? const Text('Alle genommen ✓')
                      : (takenCount > 0
                            ? Text('$takenCount/$totalCount genommen')
                            : null),
                  trailing: allTaken
                      ? const Chip(
                          label: Text(
                            'Erledigt',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      : (!isUpcoming
                            ? const Chip(
                                label: Text(
                                  'Verpasst',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.orange,
                              )
                            : const Icon(Icons.expand_more)),
                  children: meds.map<Widget>((med) {
                    final medTaken = med['taken'] as bool;
                    return ListTile(
                      leading: Icon(
                        medTaken ? Icons.check_circle : Icons.medication,
                        color: medTaken ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        med['name'],
                        style: TextStyle(
                          decoration: medTaken
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(med['dose']),
                      trailing: medTaken
                          ? null
                          : TextButton(
                              onPressed: () {
                                // TODO: Mark individual med as taken
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${med['name']} als genommen markieren',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Genommen'),
                            ),
                    );
                  }).toList(),
                ),
              );
            }),

          const SizedBox(height: 24),

          // Add Medication Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      AddMedicationModal(onAdded: _loadSchedule),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Medikament hinzufügen'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isOnboardingCompleted) {
      return LockedScreenOverlay(child: _buildContent());
    }

    return _buildContent();
  }
}
