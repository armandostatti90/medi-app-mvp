import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'onboarding_invite_screen.dart';

class OnboardingPetScreen extends StatefulWidget {
  const OnboardingPetScreen({super.key});

  @override
  State<OnboardingPetScreen> createState() => _OnboardingPetScreenState();
}

class _OnboardingPetScreenState extends State<OnboardingPetScreen> {
  final _apiService = ApiService();
  final _nameController = TextEditingController();

  String? _selectedPet;
  bool _isLoading = false;

  final List<Map<String, String>> _pets = [
    {'type': 'dog', 'emoji': '🐶', 'name': 'Hund'},
    {'type': 'cat', 'emoji': '🐱', 'name': 'Katze'},
    {'type': 'rabbit', 'emoji': '🐰', 'name': 'Hase'},
    {'type': 'fox', 'emoji': '🦊', 'name': 'Fuchs'},
  ];

  Future<void> _continue() async {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle einen Begleiter')),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Namen ein')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.createPet(_selectedPet!, name);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingInviteScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dein Begleiter')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Wähle deinen Begleiter',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Dein Begleiter motiviert dich auf deiner Therapiereise',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Pet Selection
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _pets.length,
            itemBuilder: (context, index) {
              final pet = _pets[index];
              final isSelected = _selectedPet == pet['type'];

              return Card(
                elevation: isSelected ? 8 : 2,
                color: isSelected ? Colors.blue.shade50 : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPet = pet['type'];
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(pet['emoji']!, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        pet['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Name Input
          const Text(
            'Wie soll dein Begleiter heißen?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'z.B. Buddy',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _continue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Weiter', style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingInviteScreen(),
                ),
              );
            },
            child: const Text('Überspringen'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
