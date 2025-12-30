import 'package:flutter/material.dart';
import 'package:medi_rag_app/screens/home/home_screen.dart';
import 'package:medi_rag_app/screens/main_navigation.dart';
import 'screens/auth/login_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MediRagApp());
}

class MediRagApp extends StatelessWidget {
  const MediRagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEDI RAG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // ← Neu!
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

// Splash Screen mit Auto-Login Check
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1)); // Optional: Splash delay

    final token = await _apiService.getToken();

    if (token != null) {
      // Token exists - verify it's valid
      try {
        await _apiService.getMe(); // Test if token works
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Token invalid/expired
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      // No token
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'MEDI RAG',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
