import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ConnectedPartnersScreen extends StatefulWidget {
  const ConnectedPartnersScreen({super.key});

  @override
  State<ConnectedPartnersScreen> createState() =>
      _ConnectedPartnersScreenState();
}

class _ConnectedPartnersScreenState extends State<ConnectedPartnersScreen> {
  final _apiService = ApiService();

  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _apiService.getFullProfile();
      final users = profile['connected_users'] as List? ?? [];

      setState(() {
        _partners = users.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading partners: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateInviteCode() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Einladungscode generieren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wähle die Zugriffsebene:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Vollzugriff'),
              subtitle: const Text('Kann alles sehen und verwalten'),
              onTap: () {
                Navigator.pop(context);
                _showInviteCode('ABC123');
              },
            ),
            ListTile(
              title: const Text('Nur Ansicht'),
              subtitle: const Text('Kann nur Daten sehen'),
              onTap: () {
                Navigator.pop(context);
                _showInviteCode('XYZ789');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteCode(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Einladungscode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Teile diesen Code mit deinem Partner:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Der Code ist 7 Tage gültig',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Copy to clipboard
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Code kopiert!')));
            },
            child: const Text('Kopieren'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verbundene Partner'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPartners,
              child: _partners.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Noch keine verbundenen Partner',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _generateInviteCode,
                            icon: const Icon(Icons.add),
                            label: const Text('Partner hinzufügen'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _partners.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _partners.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: OutlinedButton.icon(
                              onPressed: _generateInviteCode,
                              icon: const Icon(Icons.add),
                              label: const Text('Partner hinzufügen'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          );
                        }

                        final partner = _partners[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(partner['name']),
                            subtitle: Text(partner['type']),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Bearbeiten'),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Entfernen'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'remove') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Partner entfernen'),
                                      content: Text(
                                        'Möchtest du ${partner['name']} wirklich entfernen?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Abbrechen'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Partner entfernt',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Entfernen',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
