
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class QuizService {
  static String get baseUrl => AuthService.baseUrl;

  static Future<List<Map<String, dynamic>>> getQuestions({
    required int categoryId,
    required String difficulty,
    int limit = 20,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to start a quiz.');
    }

    final uri = Uri.parse('$baseUrl/quiz/questions').replace(
      queryParameters: {
        'category_id': categoryId.toString(),
        'difficulty': difficulty,
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((question) => Map<String, dynamic>.from(question))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please sign in again.');
    }

    throw Exception('Could not load quiz questions. Please try again.');
  }

  static Future<Map<String, dynamic>> submitQuiz({
    required int categoryId,
    required String difficulty,
    required List<Map<String, dynamic>> answers,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to submit your quiz.');
    }

    final uri = Uri.parse('$baseUrl/quiz/submit');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'difficulty': difficulty,
        'answers': answers,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }

    if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please sign in again.');
    }

    String message = 'Could not submit your quiz. Please try again.';

    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData['detail'] != null) {
        message = errorData['detail'].toString();
      }
    } catch (_) {
      // Keep the default error message.
    }

    throw Exception(message);
  }

  
  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to view your quiz history.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/quiz/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((attempt) => Map<String, dynamic>.from(attempt))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please sign in again.');
    }

    throw Exception('Could not load your quiz history. Please try again.');
  }

}
