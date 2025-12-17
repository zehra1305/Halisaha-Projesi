import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'storage_service.dart';

class ApiService {
  // GELİŞTİRME MODU: Backend sunucusu hazır olmadığı veya çalışmadığı durumlarda
  // uygulamanın arayüzünü test edebilmek için bu değeri TRUE yapın.
  static const bool useMockData = true;

  static const String baseUrl = 'http://localhost:3000/api'; 
  
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _storageService.getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (!isMultipart) headers['Content-Type'] = 'application/json';
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
    if (useMockData) return _mockLogin(email, password);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (useMockData) return _mockRegister(name, email);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'email': email, 'phone': phone, 'password': password}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // --- RESET PASSWORD FLOW ---
  Future<Map<String, dynamic>> resetPassword(String email) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'message': 'Kod gönderildi'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      if (code == '123456') {
        return {'success': true, 'temporaryToken': 'mock-temp-token'};
      }
      return {'success': false, 'message': 'Hatalı kod (Test için 123456 girin)'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-code'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email, 'code': code}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> confirmResetPassword(String temporaryToken, String newPassword) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $temporaryToken',
        },
        body: jsonEncode({'password': newPassword}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // --- PROFILE UPDATES ---
  Future<Map<String, dynamic>> updateProfile(String userId, {String? name, String? phone}) async {
    if (useMockData) {
       await Future.delayed(const Duration(seconds: 1));
       return {
         'success': true,
         'data': {
           'user': {'id': userId, 'name': name ?? 'Güncel İsim', 'email': 'admin@test.com'}
         }
       };
    }

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> changePassword(String userId, String currentPassword, String newPassword) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true};
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/password'),
        headers: await _getHeaders(),
        body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // --- PHOTO OPERATIONS ---
  Future<Map<String, dynamic>> uploadProfilePhoto(String userId, File imageFile) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true, 'data': {'photoPath': 'https://via.placeholder.com/150'}};
    }
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/$userId/photo'));
      request.headers.addAll(await _getHeaders(isMultipart: true));
      request.files.add(await http.MultipartFile.fromPath(
        'photo', imageFile.path, contentType: MediaType('image', 'jpeg')));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteProfilePhoto(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return {'success': true};
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId/photo'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // --- HELPER & MOCK DATA ---
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Hata (${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sunucu hatası: ${response.statusCode}'};
    }
  }

  Future<Map<String, dynamic>> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Yapay gecikme
    // Basit bir doğrulama simülasyonu
    if (password.length >= 3) {
      return {
        'success': true,
        'data': {
          'token': 'mock-jwt-token-123456',
          'user': {
            'id': 'user-1',
            'name': 'Admin Kullanıcısı',
            'email': email,
            'createdAt': DateTime.now().toIso8601String(),
            // 'profileImage': 'https://via.placeholder.com/150'
          }
        }
      };
    }
    return {'success': false, 'message': 'Hatalı e-posta veya şifre (Demo Modu)'};
  }

  Future<Map<String, dynamic>> _mockRegister(String name, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'data': {
        'token': 'mock-jwt-token-register',
        'user': {
          'id': 'user-new',
          'name': name,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
        }
      }
    };
  }
}