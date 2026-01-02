import 'package:flutter/material.dart';
import 'package:medi_rag_app/screens/auth/login_screen.dart';
import '../services/api_service.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/settings/notifications_screen.dart';
import '../screens/settings/app_settings_screen.dart';
import '../screens/relationships/connected_partners_screen.dart';
import '../screens/devices/connected_devices_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/privacy/privacy_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _apiService = ApiService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final profile = await _apiService.getFullProfile();
      setState(() {
        _user = profile['user'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchtest du dich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abmelden', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.logout();

      // Pop the drawer first
      Navigator.of(context).pop();

      // Small delay to let drawer close
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          '${_user?['first_name']?[0] ?? ''}${_user?['last_name']?[0] ?? ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                if (!_isLoading && _user != null)
                  Text(
                    '${_user!['first_name'] ?? ''} ${_user!['last_name'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
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
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Benachrichtigungen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('App Einstellungen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSettingsScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Verbundene Partner'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectedPartnersScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Verbundene Geräte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectedDevicesScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Hilfe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Datenschutz'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: _logout, // ← HIER!
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Abmelden',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
