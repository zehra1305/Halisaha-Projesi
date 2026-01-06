import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Modeller
import '../models/customer.dart';
import '../models/message.dart';
import '../models/appointment.dart'; 
import '../models/duyuru.dart'; 
import '../models/conversation.dart'; // YENİ EKLENDİ ✅

class ApiService {
  late final String baseUrl;

  // Singleton yapısı
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:3001/api'; 
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3001/api';
    } else {
      baseUrl = 'http://localhost:3001/api';
    }
  }

  // Bozulmaması gereken ana adres
  String get _basePath => baseUrl;

  // ==================================================
  // AUTH İŞLEMLERİ
  // ==================================================

  // 1. Login
  Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin-login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        try {
           return jsonDecode(response.body);
        } catch (_) {
           return {'success': false, 'message': 'Giriş başarısız.'};
        }
      }
    } catch (e) {
      debugPrint("Login Hatası: $e");
      return {'success': false, 'message': 'Sunucu hatası: Bağlantı kurulamadı'};
    }
  }

  // 2. Register (Mock)
  Future<Map<String, dynamic>> register({
    required String name, 
    required String email, 
    required String password,
    String? phone, 
  }) async {
    return {'success': true, 'message': 'Kayıt başarılı'};
  }

  // 3. Profil Güncelleme (Mock)
  Future<Map<String, dynamic>> updateProfile({
    String? name, 
    String? email,
    String? phone, 
  }) async {
    return {'success': true, 'message': 'Profil güncellendi'};
  }
  
  // 4. Şifre Değiştirme (Mock)
  Future<Map<String, dynamic>> changePassword(String current, String newPass) async { 
    return {'success': true, 'message': 'Şifre güncellendi'};
  }

  // 5. Profil Fotoğrafı Yükleme (Mock)
  Future<Map<String, dynamic>> uploadProfilePhoto(dynamic imagePath) async { 
    return {'success': true, 'message': 'Fotoğraf yüklendi'};
  }

  // 6. Profil Fotoğrafı Silme (Mock)
  Future<Map<String, dynamic>> deleteProfilePhoto() async { 
    return {'success': true, 'message': 'Fotoğraf silindi'};
  }

  // Şifre Sıfırlama (Mail)
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Mail gönderilemedi.'};
    } catch (e) {
      return {'success': false, 'message': 'Hata: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "code": code}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Kod hatalı.'};
    } catch (e) {
      return {'success': false, 'message': 'Hata: $e'};
    }
  }

  Future<Map<String, dynamic>> confirmResetPassword(String token, String newPass) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password-confirm'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "newPassword": newPass}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Hata.'};
    } catch (e) {
      return {'success': false, 'message': 'Hata: $e'};
    }
  }

  // ==================================================
  // DUYURU İŞLEMLERİ
  // ==================================================

  Future<List<Duyuru>> getDuyurular() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/duyurular'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Duyuru.fromJson(item)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> addDuyuru(String baslik, String resimUrl, String metin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/duyurular'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "baslik": baslik,
          "resim_url": resimUrl, 
          "metin": metin
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> deleteDuyuru(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/duyurular/$id'));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // ==================================================
  // RANDEVU İŞLEMLERİ
  // ==================================================

  Future<List<Appointment>> getAppointmentsForDate(DateTime date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/randevular'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Appointment> allApps = body.map((item) => Appointment.fromJson(item)).toList();

        String targetDate = DateFormat('yyyy-MM-dd').format(date);
        
        return allApps.where((app) {
          return app.date == targetDate;
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Randevu çekme hatası: $e");
      return [];
    }
  }

  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/randevular'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Appointment.fromJson(item)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> updateAppointmentStatus(int id, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/randevular/$id/durum'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"durum": newStatus}), 
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Güncelleme hatası: $e");
      return false;
    }
  }

  // ==================================================
  // DASHBOARD DİĞER VERİLERİ (Müşteri & Mesaj)
  // ==================================================

  // Müşterileri Getir
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kullanicilar'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Customer.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Müşteri getirme hatası: $e");
      return [];
    }
  }

  // Müşteri Sil
  Future<bool> deleteCustomer(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/kullanicilar/$id'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Silme hatası: $e");
      return false;
    }
  }

  Future<List<Message>> getMessages() async {
    return [
      Message(id: 1, sender: "Sistem", subject: "Hoşgeldiniz", content: "Admin paneli aktif edildi.", isRead: true, createdAt: "Bugün", isAdmin: true),
    ];
  }

  // ==================================================
  // MESAJLAŞMA İŞLEMLERİ (YENİ EKLENDİ ✅)
  // ==================================================

  // 1. Sohbet Listesini Getir
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sohbetler'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Conversation.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Sohbet listesi hatası: $e");
      return [];
    }
  }

  // 2. Mesajları Getir
  Future<List<Message>> getChatMessages(int chatId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mesajlar/$chatId'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Message.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Mesaj getirme hatası: $e");
      return [];
    }
  }

  // 3. Mesaj Gönder
  Future<bool> sendMessage(int chatId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mesajlar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sohbet_id": chatId,
          "icerik": content
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Mesaj gönderme hatası: $e");
      return false;
    }
  }
}