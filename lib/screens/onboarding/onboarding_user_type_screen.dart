import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../onboarding/onboarding_medical_info_screen.dart';

class OnboardingUserTypeScreen extends StatefulWidget {
  final int userId;
  final String email;

  const OnboardingUserTypeScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<OnboardingUserTypeScreen> createState() =>
      _OnboardingUserTypeScreenState();
}

class _OnboardingUserTypeScreenState extends State<OnboardingUserTypeScreen> {
  String? _selectedType;
  final _apiService = ApiService();
  bool _isLoading = false;

  final Map<String, Map<String, String>> _userTypes = {
    'patient': {
      'title': 'Patient',
      'subtitle': 'Ich bin transplantiert und nutze die App für mich',
      'icon': '🏥',
    },
    'care_recipient': {
      'title': 'Pflegebedürftig',
      'subtitle': 'Ich werde von anderen betreut',
      'icon': '👤',
    },
    'caregiver': {
      'title': 'Pflegender Angehöriger',
      'subtitle': 'Ich betreue andere Personen',
      'icon': '❤️',
    },
  };

  Future<void> _continue() async {
    if (_selectedType == null) return;

    setState(() => _isLoading = true);

    try {
      // Login first to get token
      await _apiService.login(widget.email, 'temp');

      // Navigate based on user type
      if (_selectedType == 'patient' || _selectedType == 'care_recipient') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingMedicalInfoScreen(),
            ),
          );
        }
      } else {
        // Caregiver skips medical info
        await _apiService.updateProfile(onboardingCompleted: true);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fehler beim Fortfahren')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wer bist du?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Wähle deine Rolle',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dies hilft uns, die App für dich zu personalisieren',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: _userTypes.entries.map((entry) {
                    final type = entry.key;
                    final info = entry.value;
                    final isSelected = _selectedType == type;

                    return Card(
                      elevation: isSelected ? 4 : 1,
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: ListTile(
                        leading: Text(
                          info['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(
                          info['title']!,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(info['subtitle']!),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () => setState(() => _selectedType = type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedType != null && !_isLoading
                    ? _continue
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Weiter', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
