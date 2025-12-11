import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// Modellerimizi import ediyoruz
import '../models/customer.dart';
import '../models/message.dart';
import '../models/appointment.dart'; // Yeni eklediğimiz model
import '../models/duyuru.dart'; // Duyurular modeli

class ApiService {
  // Platform'a göre API URL'si seç
  // - Web (Chrome): localhost:3001
  // - Android/iOS emülatör: 10.0.2.2:3001
  late final String baseUrl;

  ApiService() {
    if (kIsWeb) {
      // Web platform (Chrome, Firefox, vb)
      baseUrl = 'http://localhost:3001';
    } else if (Platform.isAndroid) {
      // Android emülatör
      baseUrl = 'http://10.0.2.2:3001';
    } else if (Platform.isIOS) {
      // iOS simülatörü
      baseUrl = 'http://localhost:3001';
    } else {
      // Diğer platform (Desktop)
      baseUrl = 'http://localhost:3001';
    }
    
    print('DEBUG: API Base URL: $baseUrl');
  }

  // ==================================================
  // 1. MÜŞTERİLERİ GETİR (GET /users)
  // ==================================================
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Customer.fromJson(item)).toList();
      } else {
        // Sunucu hatası durumunda boş liste dönelim ki uygulama çökmesin
        print('Müşteriler yüklenemedi: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("API Hatası (Müşteriler): $e");
      return [];
    }
  }

  // ==================================================
  // 2. MESAJLARI GETİR (GET /messages)
  // ==================================================
  Future<List<Message>> getMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Message.fromJson(item)).toList();
      } else {
        print('Mesajlar yüklenemedi: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("API Hatası (Mesajlar): $e");
      return [];
    }
  }

  // ==================================================
  // 4. DUYURULARI GETİR (GET /duyurular)
  // ==================================================
  Future<List<Duyuru>> getDuyurular() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/duyurular'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Duyuru.fromJson(item)).toList();
      } else {
        print('Duyurular yüklenemedi: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("API Hatası (Duyurular): $e");
      return [];
    }
  }

  // ==================================================
  // 5. YENİ DUYURU EKLE (POST /duyurular)
  // ==================================================
  Future<bool> addDuyuru(String baslik, String resimUrl, String metin) async {
    try {
      print("DEBUG: Duyuru gönderiliyor...");
      print("URL: $baseUrl/duyurular");
      print("Body: {baslik: $baslik, resim_url: $resimUrl, metin: $metin}");
      
      // NOT: Şu anda baslik veritabanında olmadığı için göndermiyor
      // İleride veritabanına baslik sütunu eklenirse: baslik: baslik ekle
      final response = await http.post(
        Uri.parse('$baseUrl/duyurular'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "resim_url": resimUrl,
          "metin": metin,
        }),
      ).timeout(const Duration(seconds: 10));

      print("DEBUG: Response Status: ${response.statusCode}");
      print("DEBUG: Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Başarılı
      } else {
        print("Duyuru ekleme hatası: ${response.statusCode} - ${response.body}");
        return false;
      }
    } on Exception catch (e) {
      print("API Hatası (Duyuru Ekleme): $e");
      return false;
    }
  }

  // ==================================================
  // 6. DUYURU SİL (DELETE /duyurular/:id)
  // ==================================================
  Future<bool> deleteDuyuru(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/duyurular/$id'));

      if (response.statusCode == 200) {
        return true; // Başarılı
      } else {
        print("Duyuru silme hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("API Hatası (Duyuru Silme): $e");
      return false;
    }
  }

  // ==================================================
  // 7. RANDEVULARI GETİR (GET /appointments?date=YYYY-MM-DD)
  // ==================================================
  Future<List<Appointment>> getAppointmentsForDate(DateTime date) async {
    // Tarihi veritabanının anlayacağı formata çeviriyoruz (2023-11-14 gibi)
    // ignore: unused_local_variable
    String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      // ---------------------------------------------------------
      // A) GERÇEK BACKEND KODU (Node.js hazır olunca burayı aç)
      // ---------------------------------------------------------
      /*
      final response = await http.get(Uri.parse('$baseUrl/appointments?date=$formattedDate'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Appointment.fromJson(item)).toList();
      } else {
        return [];
      }
      */

      // ---------------------------------------------------------
      // B) SİMÜLASYON KODU (Backend hazır olana kadar bunu kullan)
      // ---------------------------------------------------------
      await Future.delayed(const Duration(milliseconds: 600)); // İnternet gecikmesi taklidi

      // Resimdeki gibi 14'üne basınca o veriler gelsin diye manuel kontrol:
      if (date.day == 14) {
        return [
          Appointment(time: "15:00", status: "REZERVE", customerName: "Ahmet Yılmaz"),
          Appointment(time: "16:00", status: "MÜSAİT"),
          Appointment(time: "17:00", status: "TAMAMLANDI", customerName: "Ayşe Demir"),
          Appointment(time: "18:00", status: "İPTAL"),
          Appointment(time: "19:00", status: "REZERVE", customerName: "Mehmet Öz"),
          Appointment(time: "20:00", status: "ONAY BEKLİYOR", customerName: "Selin Can"),
        ];
      }
      // Hafta sonları boş olsun örneği
      else if (date.weekday == 6 || date.weekday == 7) {
        return [];
      }
      // Diğer günler rastgele veri
      else {
        return [
          Appointment(time: "09:00", status: "MÜSAİT"),
          Appointment(time: "10:00", status: "REZERVE", customerName: "Test Müşterisi"),
          Appointment(time: "11:00", status: "MÜSAİT"),
        ];
      }
      // ---------------------------------------------------------

    } catch (e) {
      print("Randevu API Hatası: $e");
      return [];
    }
  }
}