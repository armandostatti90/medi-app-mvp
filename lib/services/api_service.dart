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

  // Get full profile
  Future<Map<String, dynamic>> getFullProfile() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me/full'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get profile');
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

  // Delete account
  Future<void> deleteAccount() async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/me/account'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
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
      Uri.parse(
        '$baseUrl/gamification/stats',
      ), // ← Von /me/stats zu /gamification/stats
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

  // Search medication database
  Future<List<dynamic>> searchMedications(String query) async {
    if (query.length < 2) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/medications/database/search?q=$query'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to search medications');
    }
  }

  // Get ALL medications (including paused)
  Future<List<dynamic>> getAllMedications() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medications/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['medications'];
    } else {
      throw Exception('Failed to get all medications');
    }
  }

  // Add Medication with Composition (multi-select with quantities)
  Future<Map<String, dynamic>> addMedicationWithComposition({
    required String name,
    required String targetDose,
    required List<Map<String, dynamic>> composition,
    required List<String> times,
  }) async {
    final token = await getToken();

    final body = {
      'name': name,
      'dose': targetDose,
      'frequency': '${times.length}x täglich',
      'times': times,
      'composition': composition,
    };

    print('🔍 Sending medication: $body'); // DEBUG

    final response = await http.post(
      Uri.parse('$baseUrl/medications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    print('🔍 Status: ${response.statusCode}'); // DEBUG
    print('🔍 Response: ${response.body}'); // DEBUG

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add medication: ${response.body}');
    }
  }

  // Update Medication
  Future<Map<String, dynamic>> updateMedication({
    required int medicationId,
    required String name,
    required String dose,
    required String frequency,
    required List<String> times,
  }) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/medications/$medicationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'times': times,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update medication');
    }
  }

  // Delete Medication
  Future<void> deleteMedication(int medicationId) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/medications/$medicationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete medication');
    }
  }

  // Toggle Medication (Pause/Resume)
  Future<Map<String, dynamic>> toggleMedication(int medicationId) async {
    final token = await getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/medications/$medicationId/toggle'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle medication');
    }
  }

  // Mark medication as taken
  Future<Map<String, dynamic>> markMedicationTaken({
    required int medicationId,
    required String scheduledTime,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/medications/mark-taken'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'medication_id': medicationId,
        'scheduled_time': scheduledTime,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark as taken: ${response.body}');
    }
  }

  // Get today's medication schedule
  Future<Map<String, dynamic>> getTodaySchedule() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medications/today-schedule'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get today schedule');
    }
  }

  // Get calendar month
  Future<Map<String, dynamic>> getCalendarMonth(String month) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medications/calendar?month=$month'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get calendar');
    }
  }

  // Get schedule for specific date
  Future<Map<String, dynamic>> getScheduleForDate(String date) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medications/schedule?date=$date'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get schedule');
    }
  }

  // ============================================
  // CHAT
  // ============================================

  // Send chat message
  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}
