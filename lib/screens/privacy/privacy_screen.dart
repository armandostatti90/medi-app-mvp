import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Datenschutzerklärung',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const Text('Stand: 01.01.2026', style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 24),

          _buildSection(
            'Datenerfassung',
            'Wir erfassen nur die Daten, die für die Funktion der App notwendig sind:\n\n'
                '• Medikamenteninformationen\n'
                '• Einnahmezeiten und -historie\n'
                '• Gesundheitsdaten (Organ-Typ, Diagnose)\n'
                '• Verbundene Geräte und Partner',
          ),

          _buildSection(
            'Datenspeicherung',
            'Alle deine Daten werden verschlüsselt auf unseren Servern in Deutschland gespeichert. '
                'Wir nutzen modernste Sicherheitsstandards zum Schutz deiner Daten.',
          ),

          _buildSection(
            'Datenverwendung',
            'Deine Daten werden ausschließlich verwendet, um:\n\n'
                '• Dir Erinnerungen zu senden\n'
                '• Statistiken zu erstellen\n'
                '• Die App-Funktionalität zu gewährleisten\n\n'
                'Wir geben deine Daten NIEMALS an Dritte weiter.',
          ),

          _buildSection(
            'Deine Rechte',
            'Du hast jederzeit das Recht:\n\n'
                '• Deine Daten einzusehen\n'
                '• Deine Daten zu korrigieren\n'
                '• Deine Daten zu löschen\n'
                '• Der Datenverarbeitung zu widersprechen',
          ),

          _buildSection(
            'Cookies & Tracking',
            'Wir verwenden keine Tracking-Cookies. Nur technisch notwendige Cookies werden verwendet.',
          ),

          const SizedBox(height: 32),

          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue),
                      SizedBox(width: 12),
                      Text(
                        'Deine Daten sind sicher',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Wir nehmen Datenschutz sehr ernst und halten uns strikt an die DSGVO.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vollständige Datenschutzerklärung wird geöffnet...',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('Vollständige Erklärung lesen'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Kontakt Datenschutz',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datenschutzbeauftragter:'),
                  SizedBox(height: 8),
                  Text('privacy@medirag.com'),
                  SizedBox(height: 4),
                  Text('+49 123 456 7890'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content),
        const SizedBox(height: 24),
      ],
    );
  }
}
