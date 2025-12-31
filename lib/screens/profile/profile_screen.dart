import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();

  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _apiService.getFullProfile();

      print('🔍 Profile loaded: $profile');

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildUserInfo() {
    if (_profile == null) {
      print('⚠️ _buildUserInfo: profile is null');
      return const SizedBox.shrink();
    }

    final user = _profile!['user'];
    final meds = _profile!['medications'] as List? ?? [];

    print('✅ Building user info: ${user['first_name']} ${user['last_name']}');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                '${user['first_name']?[0] ?? 'U'}${user['last_name']?[0] ?? 'U'}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (user['organ_type'] != null)
              Text(
                user['organ_type'],
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),
            if (meds.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Aktuelle Medikamente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: meds
                    .map<Widget>(
                      (med) => Chip(
                        label: Text(med),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetAndStats() {
    if (_profile == null) return const SizedBox.shrink();

    final pet = _profile!['pet'];
    final stats = _profile!['stats'];
    final badges = _profile!['badges'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (pet != null) ...[
              Icon(Icons.pets, size: 80, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                pet['name'] ?? 'Mein Pet',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (stats != null) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Level', '${stats['level']}'),
                  _buildStatItem('XP', '${stats['xp']}'),
                  _buildStatItem('Streak', '${stats['streak']}🔥'),
                ],
              ),
            ],
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Badges',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: badges.take(6).map<Widget>((badge) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge['icon'] ?? '🏆',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 50,
                        child: Text(
                          badge['name'] ?? '',
                          style: const TextStyle(fontSize: 9),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildConnectedUsers() {
    if (_profile == null) return const SizedBox.shrink();

    final users = _profile!['connected_users'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verbundene Nutzer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (users.isEmpty)
              const Text(
                'Noch keine verbundenen Nutzer',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...users.map<Widget>(
                (user) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person, size: 20),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['type']),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevices() {
    if (_profile == null) return const SizedBox.shrink();

    final devices = _profile!['devices'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Angeschlossene Geräte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...devices.map<Widget>(
              (device) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.devices,
                  color: device['status'] == 'connected'
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(device['name']),
                subtitle: Text(
                  device['status'] == 'connected'
                      ? 'Verbunden'
                      : 'Nicht verbunden',
                  style: TextStyle(
                    color: device['status'] == 'connected'
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildUserInfo(),
            _buildPetAndStats(),
            _buildConnectedUsers(),
            _buildDevices(),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}
