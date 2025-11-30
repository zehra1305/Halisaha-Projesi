import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Backend URL'inizi buraya yazın
  // Android Emulator için 10.0.2.2 kullanılır (localhost yerine)
  static const String baseUrl = 'http://10.0.2.2:3001/api';
  // iOS Simulator için: 'http://localhost:3001/api'
  // Gerçek sunucu için: 'https://yourdomain.com/api'

  // Timeout süresi
  static const Duration timeout = Duration(seconds: 10);

  // Login endpoint
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Giriş başarısız',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Register endpoint
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'password': password,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Kayıt başarısız',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Google OAuth login
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Google girişi başarısız',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Password reset request
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Şifre sıfırlama kodu e-postanıza gönderildi',
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'İşlem başarısız',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Verify reset code
  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-reset-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Kod doğrulandı',
          'temporaryToken': data['temporaryToken'],
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Geçersiz kod',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Confirm reset password with new password
  Future<Map<String, dynamic>> confirmResetPassword(
    String temporaryToken,
    String newPassword,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/confirm-reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'temporaryToken': temporaryToken,
              'newPassword': newPassword,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Şifreniz başarıyla değiştirildi'};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Şifre değiştirilemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }
}
