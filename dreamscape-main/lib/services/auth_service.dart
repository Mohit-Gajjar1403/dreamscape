// lib/pages/auth_service.dart (example structure)
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static final _baseUrl = const String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:3000');

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    final payload = {'username': username, 'password': password};

    // Diagnostics
    // print('[AuthService] POST $url payload=$payload');

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    // print('[AuthService] status=${resp.statusCode} body=${resp.body}');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Try to surface backend error message
      try {
        final err = jsonDecode(resp.body);
        throw Exception(err['message'] ?? 'HTTP ${resp.statusCode}');
      } catch (_) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;

    // Normalize return shape for UI expectations
    // Ensure there's a 'username' key used by your SnackBar
    if (data['user'] is Map && data['user']['username'] != null) {
      return {'username': data['user']['username'], ...data};
    }
    if (data['username'] != null) return data;

    // If backend returns token only, adapt
    return {'username': username, ...data};
  }
}
