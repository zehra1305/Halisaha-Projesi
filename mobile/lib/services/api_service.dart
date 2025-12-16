import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Web kontrolü için
import 'package:http/http.dart' as http;

// --- YENİ EKLENEN MODEL IMPORTLARI ---
// Eğer bu satırlar kırmızı yanarsa, lib/models klasöründe bu dosyaları oluşturmamışsın demektir.
import '../models/duyuru.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/message.dart';

class ApiService {
  // --- DİNAMİK URL SEÇİMİ (MEVCUT YAPI) ---
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api'; // Web için
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001/api';  // Android Emülatör için
    } else {
      return 'http://localhost:3001/api'; // iOS ve diğerleri
    }
  }

  // Timeout süresi
  static const Duration timeout = Duration(seconds: 10);

  // ===========================================================================
  // BÖLÜM 1: MEVCUT KULLANICI İŞLEMLERİ (ESKİ KODLARIN AYNISI)
  // ===========================================================================

  // Login endpoint
  Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'rememberMe': rememberMe}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Giriş başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Register endpoint
  Future<Map<String, dynamic>> register({required String name, required String email, required String phone, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'phone': phone, 'password': password}),
      ).timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Kayıt başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Google OAuth login
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Google girişi başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Şifre Sıfırlama İstediği
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Şifre sıfırlama kodu gönderildi'};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'İşlem başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Kod Doğrulama
  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': 'Kod doğrulandı', 'temporaryToken': data['temporaryToken']};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Geçersiz kod'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Yeni Şifre Belirleme
  Future<Map<String, dynamic>> confirmResetPassword(String temporaryToken, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/confirm-reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'temporaryToken': temporaryToken, 'newPassword': newPassword}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Şifreniz değiştirildi'};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Hata oluştu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Profil Getir
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/$userId')).timeout(timeout);
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Profil alınamadı'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Profil Güncelle
  Future<Map<String, dynamic>> updateProfile(String userId, {String? name, String? phone}) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final response = await http.put(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Güncelleme başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Şifre Değiştir (Profil içinden)
  Future<Map<String, dynamic>> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile/$userId/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Şifre değiştirildi'};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Hata'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Fotoğraf Yükle
  Future<Map<String, dynamic>> uploadProfilePhoto(String userId, File imageFile) async {
    if (kIsWeb) return {'success': false, 'message': 'Web desteği henüz yok'};
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/$userId/upload-photo'));
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Yükleme başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası'};
    }
  }

  // Fotoğraf Sil
  Future<Map<String, dynamic>> deleteProfilePhoto(String userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/profile/$userId/photo')).timeout(timeout);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Fotoğraf silindi'};
      } else {
        return {'success': false, 'message': 'Silme başarısız'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası'};
    }
  }

  // ===========================================================================
  // BÖLÜM 2: YENİ EKLENEN ADMIN FONKSİYONLARI (DUYURULAR & MOCK DATA)
  // ===========================================================================

  // 1. Duyuruları Getir (Gerçek Veri)
  Future<List<Duyuru>> getDuyurular() async {
    try {
      // /api/duyurular adresine istek at
      final response = await http.get(Uri.parse('$baseUrl/duyurular'));

      if (response.statusCode == 200) {
        // Gelen JSON listesini Duyuru listesine çevir
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Duyuru.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Duyuru çekme hatası: $e");
      return [];
    }
  }

  // 2. Duyuru Ekle (Gerçek Veri)
  Future<bool> addDuyuru(String baslik, String resimUrl, String metin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/duyurular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'baslik': baslik,
          'resim_url': resimUrl,
          'metin': metin,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Duyuru ekleme hatası: $e");
      return false;
    }
  }

  // 3. Duyuru Sil (Gerçek Veri)
  Future<bool> deleteDuyuru(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/duyurular/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print("Duyuru silme hatası: $e");
      return false;
    }
  }

  // --- AŞAĞIDAKİLER MOCK DATA (Admin Paneli boş görünmesin diye sahte veriler) ---

  // Randevuları Getir (Mock)
  Future<List<Appointment>> getAppointmentsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Bekleme simülasyonu
    return [
      Appointment(time: "09:00", status: "DOLU", customerName: "Ahmet Yılmaz"),
      Appointment(time: "10:00", status: "MÜSAİT", customerName: ""),
      Appointment(time: "11:00", status: "REZERVE", customerName: "Mehmet Demir"),
      Appointment(time: "12:00", status: "MÜSAİT", customerName: ""),
      Appointment(time: "13:00", status: "DOLU", customerName: "Ayşe Kaya"),
      Appointment(time: "14:00", status: "MÜSAİT", customerName: ""),
    ];
  }

  // Müşterileri Getir (Mock)
  Future<List<Customer>> getCustomers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Customer(name: "Ahmet Yılmaz", email: "ahmet@mail.com"),
      Customer(name: "Mehmet Demir", email: "mehmet@mail.com"),
      Customer(name: "Ayşe Kaya", email: "ayse@mail.com"),
      Customer(name: "Fatma Çelik", email: "fatma@mail.com"),
    ];
  }

  // Mesajları Getir (Mock)
  Future<List<Message>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Message(sender: "Sistem", subject: "Hoşgeldiniz", content: "Yönetici paneline hoşgeldiniz. Buradan duyuru ekleyebilirsiniz.", createdAt: "Şimdi", isRead: false),
      Message(sender: "Ahmet Yılmaz", subject: "Rezervasyon", content: "Yarınki maç için soru soracaktım.", createdAt: "1 saat önce", isRead: true),
    ];
  }
}