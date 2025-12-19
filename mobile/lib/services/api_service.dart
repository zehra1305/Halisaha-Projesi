import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../models/ilan_model.dart';
import '../models/randevu_model.dart';

class ApiService {
  // Singleton pattern
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal();
  // Backend URL'inizi buraya yazın
  // Android Emulator için 10.0.2.2 kullanılır (localhost yerine)
  static const String baseUrl = 'http://10.0.2.2:3001/api';
  // iOS Simulator için: 'http://localhost:3001/api'
  // Gerçek sunucu için: 'https://yourdomain.com/api'

  // Timeout süresi
  static const Duration timeout = Duration(seconds: 10);

  // Login endpoint
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'rememberMe': rememberMe,
            }),
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
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google-login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  // Get profile
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/profile/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Profil alınamadı',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile(
    String userId, {
    String? name,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final response = await http
          .put(
            Uri.parse('$baseUrl/profile/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Profil güncellenemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/profile/$userId/change-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'currentPassword': currentPassword,
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

  // Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(
    String userId,
    File imageFile,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/$userId/upload-photo'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Fotoğraf yüklenemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Delete profile photo
  Future<Map<String, dynamic>> deleteProfilePhoto(String userId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/profile/$userId/photo'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Fotoğraf silindi'};
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Fotoğraf silinemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Get appointments for a specific date
  Future<List<Appointment>> getAppointments(String date) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/appointments?date=$date'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body)['appointments'] ?? [];
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Randevu yükleme hatası: $e');
      return [];
    }
  }

  // Book an appointment
  Future<bool> bookAppointment({
    required String date,
    required String time,
    required String userId,
    String? note,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/appointments'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'date': date,
              'time': time,
              'user_id': userId,
              'note': note,
            }),
          )
          .timeout(timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Randevu kaydetme hatası: $e');
      return false;
    }
  }

  // Fetch all ilanlar (listings)
  Future<List<IlanModel>> fetchIlanlar() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/ilanlar'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => IlanModel.fromJson(json)).toList();
      } else {
        throw Exception('İlanlar yüklenemedi');
      }
    } catch (e) {
      print('İlan yükleme hatası: $e');
      throw Exception('İlan yükleme hatası: ${e.toString()}');
    }
  }

  // Add new ilan
  Future<IlanModel> addIlan(IlanModel ilan) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ilanlar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(ilan.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdIlan = jsonDecode(response.body);
        return IlanModel.fromJson(createdIlan);
      } else {
        throw Exception('İlan kaydedilemedi');
      }
    } catch (e) {
      print('İlan kaydetme hatası: $e');
      throw Exception('İlan kaydetme hatası: ${e.toString()}');
    }
  }

  // RANDEVU İŞLEMLERİ

  // Randevu oluştur
  Future<RandevuModel> createRandevu(RandevuModel randevu) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/randevular'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(randevu.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RandevuModel.fromJson(data['data']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Randevu oluşturulamadı');
      }
    } catch (e) {
      print('Randevu oluşturma hatası: $e');
      throw Exception(e.toString());
    }
  }

  // Kullanıcının randevularını getir
  Future<List<RandevuModel>> getRandevularByUser(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/randevular/kullanici/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> randevuList = data['data'];
        return randevuList.map((json) => RandevuModel.fromJson(json)).toList();
      } else {
        throw Exception('Randevular yüklenemedi');
      }
    } catch (e) {
      print('Randevu yükleme hatası: $e');
      throw Exception('Randevu yükleme hatası: ${e.toString()}');
    }
  }

  // Yaklaşan onaylı randevuyu getir (anasayfa için)
  Future<RandevuModel?> getYaklasanRandevu(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/randevular/yaklasan/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return RandevuModel.fromJson(data['data']);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Yaklaşan randevu hatası: $e');
      return null;
    }
  }

  // Tüm yaklaşan onaylı randevuları getir (anasayfa için)
  Future<List<RandevuModel>> getYaklasanRandevular(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/randevular/yaklasanlar/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        print('YaklasanRandevular response: ${response.body}');
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => RandevuModel.fromJson(item))
              .toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Yaklaşan randevular hatası: $e');
      return [];
    }
  }

  // Müsait saatleri getir
  Future<List<Map<String, String>>> getMusaitSaatler(String tarih) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/randevular/musait-saatler?tarih=$tarih'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> saatler = data['data'];
        return saatler
            .map(
              (s) => {
                'baslangic': s['baslangic'].toString(),
                'bitis': s['bitis'].toString(),
              },
            )
            .toList();
      } else {
        throw Exception('Müsait saatler yüklenemedi');
      }
    } catch (e) {
      print('Müsait saatler hatası: $e');
      throw Exception('Müsait saatler hatası: ${e.toString()}');
    }
  }

  // Randevu iptal et
  Future<bool> cancelRandevu(String randevuId, String kullaniciId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/randevular/$randevuId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'kullaniciId': kullaniciId}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Randevu iptal edilemedi');
      }
    } catch (e) {
      print('Randevu iptal hatası: $e');
      throw Exception('Randevu iptal hatası: ${e.toString()}');
    }
  }
}
