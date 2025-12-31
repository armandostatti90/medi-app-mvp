import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/next_intake_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();

  Map<String, dynamic>? _schedule;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final schedule = await _apiService.getTodaySchedule();
      final stats = await _apiService.getStats();
      // TODO: Load stats from API

      setState(() {
        _schedule = schedule;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsTaken(Map<String, dynamic> nextIntake) async {
    try {
      for (var med in nextIntake['medications']) {
        await _apiService.markMedicationTaken(
          medicationId: med['medication_id'],
          scheduledTime: nextIntake['time'],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alle Medikamente als genommen markiert! ✓'),
            backgroundColor: Colors.green,
          ),
        );

        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final nextIntake = _schedule?['next_intake'] as Map<String, dynamic>?;
    final tomorrowIntake =
        _schedule?['tomorrow_first_intake'] as Map<String, dynamic>?;
    final allTodayTaken = _schedule?['all_today_taken'] == true;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Hallo! 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hier ist deine Übersicht',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Next Intake Card
            NextIntakeCard(
              nextIntake: nextIntake,
              tomorrowFirstIntake: tomorrowIntake,
              allTodayTaken: allTodayTaken,
              onMarkAllTaken: _markAllAsTaken,
            ),

            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              'Deine Statistiken',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    label: 'Streak',
                    value: '${_stats?['streak'] ?? 0} Tage', // TODO: From API
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    iconColor: Colors.green,
                    label: 'Adhärenz',
                    value:
                        '${_stats?['adherence_this_week'] ?? 0}%', // TODO: From API
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.medication,
                    iconColor: Colors.blue,
                    label: 'Genommen',
                    value:
                        '${_stats?['total_medications_taken'] ?? 0}', // TODO: From API
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    iconColor: Colors.amber,
                    label: 'Level',
                    value: '${_stats?['level'] ?? 1}', // TODO: From API
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Schnellzugriff',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildQuickAction(
              icon: Icons.calendar_today,
              title: 'Therapieplan',
              subtitle: 'Heutiger Medikationsplan',
              onTap: () {
                // Navigate to therapy tab
                DefaultTabController.of(context).animateTo(1);
              },
            ),

            const SizedBox(height: 12),

            _buildQuickAction(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Fragen zu deiner Therapie',
              onTap: () {
                // Navigate to chat tab
                DefaultTabController.of(context).animateTo(2);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
