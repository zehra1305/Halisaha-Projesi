import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';

class ApiService {
  // Arkadaşın backend'i hangi IP ve Port'ta çalıştırıyorsa buraya yazacaksın.
  // Android Emülatör için genelde: 'http://10.0.2.2:3000'
  // Gerçek cihaz veya iOS için bilgisayarının yerel IP'si: 'http://192.168.1.XX:3000'
  static const String _baseUrl = "http://10.0.2.2:3000";

  // --- 1. RANDEVULARI GETİR (GET Request) ---
  Future<List<Appointment>> getAppointments(String dateStr) async {
    // URL Örneği: http://10.0.2.2:3000/appointments?date=2025-12-14
    final url = Uri.parse('$_baseUrl/appointments?date=$dateStr');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Sunucudan cevap başarılı döndü.
        List<dynamic> body = json.decode(response.body);

        List<Appointment> appointments = body
            .map((dynamic item) => Appointment.fromJson(item))
            .toList();

        return appointments;
      } else {
        // Sunucu hata kodu döndürdü (404, 500 vb.)
        print("Sunucu Hatası: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Sunucu kapalıysa veya internet yoksa buraya düşer.
      print("Bağlantı Hatası: $e");
      return []; // Uygulama çökmesin diye boş liste dönüyoruz.
    }
  }

  // --- 2. RANDEVU OLUŞTUR (POST Request) ---
  Future<bool> bookAppointment(String timeSlot) async {
    final url = Uri.parse('$_baseUrl/appointments');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "time": timeSlot,
          "date": DateTime.now().toString().split(" ")[0], // Örnek tarih formatı
          // "userId": "123" // Gerekirse kullanıcı ID'si de gönderilir
          "userId": "1",
        }),
      );

      // 200: OK, 201: Created
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Randevu oluşturulamadı: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Randevu isteği hatası: $e");
      return false;
    }
  }
}