import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:5000/api/auth";

  // 10.0.2.2 = localhost for Android Emulator
  // Use http://localhost:5000 if running Flutter Web

  // REGISTER
  static Future<Map<String, dynamic>> register(String username, String email,
      String password) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    return _processResponse(response);
  }

  // LOGIN (👉 changed from email+password to username+password)
  static Future<Map<String, dynamic>> login(String username,
      String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    return _processResponse(response);
  }

  // Helper method to decode response
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      return jsonDecode(response.body);
    } else {
      // ERROR: Try to parse error message
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Something went wrong');
      } catch (_) {
        throw Exception('Something went wrong (server error)');
      }
    }
  }
}