import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://medi-rag-mvp.onrender.com';
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
  }) async {
    final token = await getToken();
    
    final response = await http.patch(
      Uri.parse('$baseUrl/me/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        if (transplantType != null) 'transplant_type': transplantType,
        if (transplantDate != null) 'transplant_date': transplantDate,
        if (notes != null) 'notes': notes,
        if (onboardingCompleted != null) 'onboarding_completed': onboardingCompleted,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Profile update failed');
    }
  }
  
  Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user data');
    }
  }
}