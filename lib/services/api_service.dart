import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  final storage = const FlutterSecureStorage();

  // ============================================
  // AUTH
  // ============================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'token', value: data['access_token']);
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String userType = 'patient',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'user_type': userType,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  // ============================================
  // PROFILE
  // ============================================

  Future<void> updateProfile({
    String? transplantType,
    String? transplantDate,
    String? notes,
    bool? onboardingCompleted,
    String? userType,
    String? organType,
    String? medicalNotes,
    Map<String, dynamic>? customData, // ← NEU!
  }) async {
    final token = await getToken();

    // Build data map
    final data = <String, dynamic>{
      if (transplantType != null) 'transplant_type': transplantType,
      if (transplantDate != null) 'transplant_date': transplantDate,
      if (notes != null) 'notes': notes,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (userType != null) 'user_type': userType,
      if (organType != null) 'organ_type': organType,
      if (medicalNotes != null) 'medical_notes': medicalNotes,
    };

    // Merge custom data if provided
    if (customData != null) {
      data.addAll(customData);
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/me/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Profile update failed');
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('🔍 getMe Status: ${response.statusCode}'); // DEBUG
    print('🔍 getMe Body: ${response.body}'); // DEBUG

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(
        '🔍 onboarding_completed: ${data['onboarding_completed']}',
      ); // DEBUG
      return data;
    } else {
      throw Exception('Failed to get user data');
    }
  }

  // Pet erstellen
  Future<Map<String, dynamic>> createPet(String petType, String name) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/me/pet'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'pet_type': petType, 'name': name}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create pet');
    }
  }

  // Invite Code generieren
  Future<Map<String, dynamic>> generateInviteCode({
    required String accessLevel,
    int daysValid = 7,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/relationships/generate-code'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'access_level': accessLevel, 'days_valid': daysValid}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate code');
    }
  }

  // Use invite code (for supporters/medical to link to patient)
  Future<Map<String, dynamic>> useInviteCode(String code) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/relationships/use-code'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'code': code}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to use invite code');
    }
  }

  // ============================================
  // ONBOARDING
  // ============================================

  Future<bool> isOnboardingCompleted() async {
    try {
      final user = await getMe();
      return user['onboarding_completed'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/me/complete-onboarding'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete onboarding');
    }
  }

  // ============================================
  // GAMIFACTION
  // ============================================

  Future<Map<String, dynamic>> getStats() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get stats');
    }
  }

  Future<Map<String, dynamic>> getBadges() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me/badges'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get badges');
    }
  }

  Future<Map<String, dynamic>> getPet() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me/pet'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get pet');
    }
  }

  Future<List<dynamic>> getMedications() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['medications'];
    } else {
      throw Exception('Failed to get medications');
    }
  }

  // ============================================
  // MEDICATION
  // ============================================

  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dose,
    required String frequency,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/medications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name, 'dose': dose, 'frequency': frequency}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add medication');
    }
  }
}
