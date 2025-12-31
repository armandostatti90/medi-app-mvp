import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class OnboardingInviteScreen extends StatefulWidget {
  const OnboardingInviteScreen({super.key});

  @override
  State<OnboardingInviteScreen> createState() => _OnboardingInviteScreenState();
}

class _OnboardingInviteScreenState extends State<OnboardingInviteScreen> {
  final _apiService = ApiService();

  bool _wantsToInvite = false;
  String? _selectedAccessLevel;
  String? _generatedCode;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _accessLevels = [
    {
      'value': 'family',
      'title': 'Familie/Freunde',
      'subtitle': 'Kann Medikamente und Status sehen',
      'icon': Icons.people,
    },
    {
      'value': 'caregiver',
      'title': 'Pflegedienst',
      'subtitle': 'Kann Medikamente verwalten und Status sehen',
      'icon': Icons.local_hospital,
    },
    {
      'value': 'doctor',
      'title': 'Arztpraxis',
      'subtitle': 'Vollzugriff inkl. medizinische Daten',
      'icon': Icons.medical_services,
    },
  ];

  Future<void> _generateCode() async {
    if (_selectedAccessLevel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte wähle eine Option')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.generateInviteCode(
        accessLevel: _selectedAccessLevel!,
        daysValid: 7,
      );

      setState(() {
        _generatedCode = response['code'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      await _apiService.completeOnboarding();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyCode() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code kopiert!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fast fertig!')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Jemanden einladen?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Teile deine Therapie mit Familie, Pflegedienst oder Arzt',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          if (!_wantsToInvite) ...[
            // Initial Choice
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.group_add, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Möchtest du jemanden einladen?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _wantsToInvite = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Ja, jemanden einladen'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Später'),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_generatedCode == null) ...[
            // Access Level Selection
            const Text(
              'Wen möchtest du einladen?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ..._accessLevels.map((level) {
              final isSelected = _selectedAccessLevel == level['value'];

              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Colors.blue.shade50 : null,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    level['icon'],
                    size: 40,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    level['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(level['subtitle']),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAccessLevel = level['value'];
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Code generieren'),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                setState(() {
                  _wantsToInvite = false;
                });
              },
              child: const Text('Zurück'),
            ),
          ] else ...[
            // Code Display
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dein Einladungscode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _generatedCode!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Gültig für 7 Tage',
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _copyCode,
                        icon: const Icon(Icons.copy),
                        label: const Text('Code kopieren'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Fertig'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
