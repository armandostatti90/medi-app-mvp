import 'notification_service.dart';
import 'api_service.dart';

class MedicationNotificationHelper {
  static final _apiService = ApiService();

  static Future<void> rescheduleAll() async {
    try {
      // Cancel all existing
      await NotificationService.cancelAll();

      // Load all medications
      final medications = await _apiService.getAllMedications();

      print('📋 Got ${medications.length} medications'); // ← ADD

      for (var med in medications) {
        // ← ADD
        print(
          '  Med: ${med['name']}, Active: ${med['active']}, Times: ${med['times']}',
        ); // ← ADD
      } // ← ADD

      // Group by time
      Map<String, List<Map<String, dynamic>>> timeGroups = {};

      for (var med in medications) {
        if (med['active'] != true) continue;

        final times = med['times'] as List;
        for (var time in times) {
          final timeStr = time.toString();
          if (!timeGroups.containsKey(timeStr)) {
            timeGroups[timeStr] = [];
          }
          timeGroups[timeStr]!.add(med);
        }
      }

      // Schedule one notification per time
      int notifId = 0;
      for (var entry in timeGroups.entries) {
        final time = entry.key;
        final meds = entry.value;

        final parts = time.split(':');
        final medCount = meds.length;
        final medNames = meds.map((m) => m['name']).take(2).join(', ');
        final extra = medCount > 2 ? ' +${medCount - 2} weitere' : '';

        await NotificationService.scheduleDaily(
          id: notifId++,
          title: 'Medikamente um $time Uhr',
          body: '$medNames$extra',
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        print('✅ Scheduled notification for $time: $medNames'); // ← EXISTS
        print('   Hour: ${parts[0]}, Minute: ${parts[1]}'); // ← ADD
        print('   ID: ${notifId - 1}'); // ← ADD
      }
    } catch (e) {
      print('Error rescheduling notifications: $e');
    }
  }
}
