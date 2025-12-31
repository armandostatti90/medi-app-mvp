import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilfe'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Häufig gestellte Fragen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildFAQItem(
            context,
            'Wie füge ich ein Medikament hinzu?',
            'Gehe zu "Therapie" und tippe auf "Verwalten". Dort kannst du mit dem Plus-Button neue Medikamente hinzufügen.',
          ),

          _buildFAQItem(
            context,
            'Wie ändere ich Einnahmezeiten?',
            'Gehe zu "Therapie" → "Verwalten", wähle das Medikament aus dem Menü und tippe auf "Bearbeiten".',
          ),

          _buildFAQItem(
            context,
            'Was passiert wenn ich eine Einnahme vergesse?',
            'Du kannst die Einnahme jederzeit nachholen. Dein Streak wird nur unterbrochen, wenn du einen ganzen Tag verpasst.',
          ),

          _buildFAQItem(
            context,
            'Wie kann ich Partner hinzufügen?',
            'Gehe zu Menü → "Verbundene Partner" und generiere einen Einladungscode, den du mit deinem Partner teilen kannst.',
          ),

          _buildFAQItem(
            context,
            'Wie verbinde ich mein Gerät?',
            'Gehe zu Menü → "Verbundene Geräte" und folge den Pairing-Anweisungen für dein Gerät.',
          ),

          const SizedBox(height: 32),

          const Text(
            'Kontakt',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Brauchst du weitere Hilfe?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Email: support@medirag.com'),
                  const SizedBox(height: 8),
                  const Text('Tel: +49 123 456 7890'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email-Client wird geöffnet...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Support kontaktieren'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Video Tutorials',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildVideoItem(
            context,
            'Erste Schritte',
            'Lerne die Grundfunktionen der App kennen',
            Icons.play_circle_outline,
          ),

          _buildVideoItem(
            context,
            'Medikamente verwalten',
            'So fügst du Medikamente hinzu und verwaltest sie',
            Icons.play_circle_outline,
          ),

          _buildVideoItem(
            context,
            'Geräte verbinden',
            'Anleitung zum Koppeln deiner Geräte',
            Icons.play_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: Text(answer)),
        ],
      ),
    );
  }

  Widget _buildVideoItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video wird geladen...')),
          );
        },
      ),
    );
  }
}
