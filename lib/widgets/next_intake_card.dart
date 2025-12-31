import 'package:flutter/material.dart';

class NextIntakeCard extends StatelessWidget {
  final Map<String, dynamic>? nextIntake;
  final Map<String, dynamic>? tomorrowFirstIntake;
  final bool allTodayTaken;
  final Function(Map<String, dynamic>)? onMarkAllTaken;

  const NextIntakeCard({
    super.key,
    this.nextIntake,
    this.tomorrowFirstIntake,
    this.allTodayTaken = false,
    this.onMarkAllTaken,
  });

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

  @override
  Widget build(BuildContext context) {
    // Show "All done + Tomorrow" card
    if (allTodayTaken && tomorrowFirstIntake != null) {
      return Card(
        color: Colors.green.shade50,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Heute alles genommen! 🎉',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nächste Einnahme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Morgen ${tomorrowFirstIntake!['time']} • ${_formatTimeUntil(tomorrowFirstIntake!['seconds_until'])}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ...(tomorrowFirstIntake!['medications'] as List).map((med) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.medication, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${med['name']} ${med['dose']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    // Show "Next Intake Today" card
    if (nextIntake != null) {
      return Card(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${nextIntake!['time']} • ${_formatTimeUntil(nextIntake!['seconds_until'])}',
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
              ...(nextIntake!['medications'] as List).map((med) {
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

              if (onMarkAllTaken != null) ...[
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onMarkAllTaken!(nextIntake!),
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Alle ${(nextIntake!['medications'] as List).length} Medikamente als genommen markieren',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // No upcoming medications
    return const SizedBox.shrink();
  }
}
