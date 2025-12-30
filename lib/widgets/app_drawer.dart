import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 12),
                Text(
                  'MEDI RAG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil kommt bald!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Einstellungen kommen bald!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Benachrichtigungen'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Benachrichtigungen kommen bald!'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Hilfe'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Help
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Datenschutz'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Privacy
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Abmelden', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await apiService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
