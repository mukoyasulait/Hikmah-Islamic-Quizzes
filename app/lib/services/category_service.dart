
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CategoryService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to view categories.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((category) => Map<String, dynamic>.from(category))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please sign in again.');
    }

    throw Exception('Could not load categories. Please try again.');
  }
}
