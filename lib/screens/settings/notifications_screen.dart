import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _medicationReminders = true;
  bool _dailySummary = true;
  bool _achievementNotifications = true;
  bool _petReminders = false;

  String _reminderTime = '08:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Push Benachrichtigungen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Medikamenten-Erinnerungen'),
            subtitle: const Text('Erhalte Erinnerungen zur Einnahme'),
            value: _medicationReminders,
            onChanged: (value) {
              setState(() => _medicationReminders = value);
            },
          ),

          if (_medicationReminders) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  const Text('Erinnerungszeit: '),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _reminderTime =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    child: Text(_reminderTime),
                  ),
                ],
              ),
            ),
          ],

          const Divider(),

          SwitchListTile(
            title: const Text('Tägliche Zusammenfassung'),
            subtitle: const Text('Erhalte eine tägliche Übersicht'),
            value: _dailySummary,
            onChanged: (value) {
              setState(() => _dailySummary = value);
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text('Erfolge & Badges'),
            subtitle: const Text('Werde über neue Erfolge informiert'),
            value: _achievementNotifications,
            onChanged: (value) {
              setState(() => _achievementNotifications = value);
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text('Pet Erinnerungen'),
            subtitle: const Text('Erinnere mich an mein virtuelles Pet'),
            value: _petReminders,
            onChanged: (value) {
              setState(() => _petReminders = value);
            },
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Einstellungen gespeichert!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
