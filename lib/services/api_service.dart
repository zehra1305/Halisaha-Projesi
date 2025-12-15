import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ilan_model.dart';

// Backend olmadığı için bu adresler artık kullanılmıyor.
// const String _baseUrl = "http://10.0.2.2:5000/api";

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // --- İLAN İŞLEMLERİ (SAHTE VERİ İLE) ---

  Future<List<IlanModel>> fetchIlanlar() async {
    print("Sahte (mock) ilan verileri getiriliyor...");
    // Gerçek bir API çağrısı yerine sahte bir gecikme ekliyoruz.
    await Future.delayed(const Duration(seconds: 1));

    // Backend'den geliyormuş gibi sahte bir veri listesi oluşturuyoruz.
    final List<Map<String, dynamic>> sahteIlanlar = [
      {
        "adSoyad": "Ahmet Yılmaz",
        "yas": "30",
        "mevki": "Forvet",
        "konum": "Kayseri",
        "kisiSayisi": "1",
        "saat": "21:00",
        "isExpired": false,
        "aciklama": "Tecrübeli forvet aranıyor."
      },
      {
        "adSoyad": "Mehmet Kaya",
        "yas": "25",
        "mevki": "Orta Saha",
        "konum": "Ankara",
        "kisiSayisi": "2",
        "saat": "22:00",
        "isExpired": false,
        "aciklama": "Koşu kapasitesi yüksek orta saha oyuncuları aranıyor."
      },
      {
        "adSoyad": "Can Demir",
        "yas": "28",
        "mevki": "Defans",
        "konum": "İstanbul",
        "kisiSayisi": "1",
        "saat": "20:00",
        "isExpired": false,
        "aciklama": "Güçlü ve hızlı bir defans oyuncusu aranıyor."
      },
      {
        "adSoyad": "Ali Vural",
        "yas": "35",
        "mevki": "Kaleci",
        "konum": "İzmir",
        "kisiSayisi": "1",
        "saat": "19:00",
        "isExpired": true, // Bu ilan eski tarihli gibi görünecek
        "aciklama": "Refleksleri kuvvetli kaleci aranıyor."
      },
    ];

    // Sahte JSON listesini IlanModel nesnelerine çeviriyoruz.
    return sahteIlanlar.map((json) => IlanModel.fromJson(json)).toList();
  }

  Future<IlanModel> addIlan(IlanModel ilan) async {
    print("Sahte (mock) ilan ekleniyor...");
    await Future.delayed(const Duration(seconds: 1));
    // Yeni ilanı sadece yerel olarak eklenmiş gibi varsayıyoruz.
    return ilan;
  }

   // --- AUTH (GİRİŞ/KAYIT) İŞLEMLERİ (SAHTE VERİ İLE) ---

  Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = false}) async {
    print("Giriş Yapılıyor: $email");
    await Future.delayed(const Duration(seconds: 1));
    return {
      "success": true,
      "data": {
        "token": "fake_token_for_${email}",
        "user": {
          "id": "123",
          "name": "Ayşe Ben",
          "email": email,
          "createdAt": DateTime.now().toIso8601String()
        }
      }
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    print("Kayıt olunuyor: $name");
    await Future.delayed(const Duration(seconds: 1));
    return {
      "success": true,
      "data": {
        "token": "new_fake_token_for_${email}",
        "user": {
          "id": "456",
          "name": name,
          "email": email,
          "phone": phone,
          "createdAt": DateTime.now().toIso8601String()
        }
      }
    };
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    print("Google ile giriş yapılıyor...");
    await Future.delayed(const Duration(seconds: 1));
    return {
      "success": true,
      "data": {
        "user": {
          "id": "789",
          "name": "Google Kullanıcısı",
          "email": "google@example.com",
          "createdAt": DateTime.now().toIso8601String()
        }
      }
    };
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    print("Şifre sıfırlama isteği: $email");
    await Future.delayed(const Duration(seconds: 1));
    return {"success": true};
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    print("Sıfırlama kodu doğrulanıyor: $code");
    await Future.delayed(const Duration(seconds: 1));
    return {"success": true, "temporaryToken": "temp_token_123"};
  }

  Future<Map<String, dynamic>> confirmResetPassword(
      String temporaryToken, String newPassword) async {
    print("Yeni şifre onaylanıyor...");
    await Future.delayed(const Duration(seconds: 1));
    return {"success": true};
  }

  Future<Map<String, dynamic>> updateProfile(String userId, {String? name, String? phone}) async {
    print("Profil güncelleniyor: $name");
    await Future.delayed(const Duration(seconds: 1));
    return {
      "success": true,
      "data": {
        "user": {
          "id": userId,
          "name": name ?? "İsimsiz",
          "email": "test@example.com",
          "phone": phone,
          "createdAt": DateTime.now().toIso8601String()
        }
      }
    };
  }

  Future<Map<String, dynamic>> changePassword(
      String userId, String currentPassword, String newPassword) async {
    print("Şifre değiştiriliyor...");
    await Future.delayed(const Duration(seconds: 1));
    return {"success": true};
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String userId, File imageFile) async {
    print("Profil fotoğrafı yükleniyor...");
    await Future.delayed(const Duration(seconds: 1));
    return {
      "success": true,
      "data": {
        "photoPath": "https://example.com/new_photo.jpg"
      }
    };
  }

  Future<Map<String, dynamic>> deleteProfilePhoto(String userId) async {
    print("Profil fotoğrafı siliniyor...");
    await Future.delayed(const Duration(seconds: 1));
    return {"success": true};
  }
}
