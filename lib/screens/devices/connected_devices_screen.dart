import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  final _apiService = ApiService();

  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _apiService.getFullProfile();
      final devices = profile['devices'] as List? ?? [];

      setState(() {
        _devices = devices.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading devices: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addDevice() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wähle dein Gerät:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('PillBox Pro'),
              subtitle: const Text('Smarte Medikamentenbox'),
              onTap: () {
                Navigator.pop(context);
                _showPairingInstructions('PillBox Pro');
              },
            ),
            ListTile(
              leading: const Icon(Icons.watch),
              title: const Text('Smart Watch'),
              subtitle: const Text('Erinnerungen am Handgelenk'),
              onTap: () {
                Navigator.pop(context);
                _showPairingInstructions('Smart Watch');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPairingInstructions(String deviceType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$deviceType koppeln'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pairing-Anleitung:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('1. Schalte dein Gerät ein'),
            const Text('2. Aktiviere Bluetooth'),
            const Text('3. Drücke den Pairing-Button am Gerät'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('Pairing Code:'),
                  SizedBox(height: 8),
                  Text(
                    '1234',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gerät wird gekoppelt...'),
                  duration: Duration(seconds: 2),
                ),
              );
              // TODO: Actual pairing logic
            },
            child: const Text('Koppeln'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'connected':
        return Colors.green;
      case 'not_connected':
        return Colors.grey;
      case 'low_battery':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'pillbox':
        return Icons.medication;
      case 'smartwatch':
        return Icons.watch;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verbundene Geräte'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDevices,
              child: _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Noch keine Geräte verbunden',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _addDevice,
                            icon: const Icon(Icons.add),
                            label: const Text('Gerät hinzufügen'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _devices.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _devices.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: OutlinedButton.icon(
                              onPressed: _addDevice,
                              icon: const Icon(Icons.add),
                              label: const Text('Gerät hinzufügen'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          );
                        }

                        final device = _devices[index];
                        final status = device['status'] ?? 'not_connected';
                        final statusColor = _getStatusColor(status);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              _getDeviceIcon(device['type']),
                              size: 40,
                              color: statusColor,
                            ),
                            title: Text(device['name']),
                            subtitle: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status == 'connected'
                                      ? 'Verbunden'
                                      : 'Nicht verbunden',
                                  style: TextStyle(color: statusColor),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'settings',
                                  child: Text('Einstellungen'),
                                ),
                                const PopupMenuItem(
                                  value: 'disconnect',
                                  child: Text('Trennen'),
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
                                      title: const Text('Gerät entfernen'),
                                      content: Text(
                                        'Möchtest du ${device['name']} wirklich entfernen?',
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
                                                content: Text('Gerät entfernt'),
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
