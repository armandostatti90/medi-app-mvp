import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _darkMode = false;
  bool _soundEffects = true;
  String _language = 'Deutsch';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Einstellungen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Darstellung',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Dunkler Modus'),
            subtitle: const Text('Aktiviere Dark Mode'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark Mode - kommt bald!')),
              );
            },
          ),

          const Divider(),

          ListTile(
            title: const Text('Sprache'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sprache wählen'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: const Text('Deutsch'),
                        value: 'Deutsch',
                        groupValue: _language,
                        onChanged: (value) {
                          setState(() => _language = value!);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'English',
                        groupValue: _language,
                        onChanged: (value) {
                          setState(() => _language = value!);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Ton & Haptik',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Soundeffekte'),
            subtitle: const Text('Aktiviere Sounds in der App'),
            value: _soundEffects,
            onChanged: (value) {
              setState(() => _soundEffects = value);
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Pet Einstellungen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Pet auswählen'),
            subtitle: const Text('Ändere dein virtuelles Pet'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pet wechseln - kommt bald!')),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Pet umbenennen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pet umbenennen - kommt bald!')),
              );
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
