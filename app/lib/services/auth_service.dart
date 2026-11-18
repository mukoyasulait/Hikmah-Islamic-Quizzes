
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // Register a new learner
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['detail'] ?? 'Registration failed. Please try again.',
    );
  }

  // Login and securely save the access token
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['access_token'];

      if (token == null) {
        throw Exception('Login response did not contain an access token.');
      }

      await _storage.write(
        key: 'access_token',
        value: token,
      );

      return data;
    }

    throw Exception(
      data['detail'] ?? 'Login failed. Please check your credentials.',
    );
  }

  // Retrieve the saved access token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Retrieve the logged-in user's profile
  static Future<Map<String, dynamic>> getCurrentUser(
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ?? 'Could not retrieve your account.',
    );
  }

  // Log out and remove the saved token
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }
}
