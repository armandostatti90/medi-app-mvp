import 'package:flutter/material.dart';
import 'package:medi_rag_app/widgets/onboarding_banner.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();

  List<dynamic> _medications = [];
  bool _isLoading = true;
  bool _isOnboardingCompleted = false; // ← NEU!

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData(); // Reload when coming back
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final meds = await _apiService.getMedications();
      final completed = await _apiService.isOnboardingCompleted(); // ← NEU!

      setState(() {
        _medications = meds;
        _isOnboardingCompleted = completed; // ← NEU!
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Onboarding Banner
                if (!_isOnboardingCompleted) const OnboardingBanner(),

                if (!_isOnboardingCompleted) // ← NEU!
                  const SizedBox(height: 24),
                // Medications
                const Text(
                  'Medikamente',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (_medications.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.medication,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('Noch keine Medikamente'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Add medication
                            },
                            child: const Text('Medikament hinzufügen'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._medications.map(
                    (med) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.medication),
                        title: Text(med['name']),
                        subtitle: Text('${med['dose']} - ${med['frequency']}'),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Chat
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Chat
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat öffnen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
