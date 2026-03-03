import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Using 10.0.2.2 to connect to localhost from Android emulator
  // Change to localhost if running on web/iOS simulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'x-auth-token': token,
    };
  }

  // Auth Group
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _processResponse(response);
  }

  // Onboarding Group
  static Future<Map<String, dynamic>> updateOnboarding(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/onboarding'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  // Company Group
  static Future<List<dynamic>> getCompanies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/companies'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load companies');
    }
  }

  static Future<Map<String, dynamic>> registerCompany(Map<String, dynamic> companyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/companies'),
      headers: await getHeaders(),
      body: jsonEncode(companyData),
    );
    return _processResponse(response);
  }

  // Tax Group
  static Future<Map<String, dynamic>> generateTaxReport(Map<String, dynamic> taxData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taxes/generate'),
      headers: await getHeaders(),
      body: jsonEncode(taxData),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> compareRegimes(String taxYear, Map<String, dynamic> financialData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taxes/compare'),
      headers: await getHeaders(),
      body: jsonEncode({
        'taxYear': taxYear,
        'financialData': financialData
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to compare regimes');
    }
  }

  static Future<List<dynamic>> getTaxReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/taxes'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tax reports');
    }
  }

  static String getDownloadUrl(String reportId) {
    return '$baseUrl/taxes/download/$reportId';
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Success but failed to parse response: ${response.statusCode} - ${response.body.substring(0, 100)}');
      }
    } else {
      try {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Unknown API error');
      } catch (e) {
        throw Exception('Server Error (${response.statusCode}): ${response.body.length > 50 ? response.body.substring(0, 50) + "..." : response.body}');
      }
    }
  }
}
