import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

/// Node.js backend ile iletişim için API servis sınıfı
class ApiService {
  // Backend base URL - Backendci arkadaşın Node.js server URL'ini buraya yazacak
  // Örnek: 'http://localhost:3000' veya 'https://api.ruyahalisaha.com'
  static const String baseUrl = 'http://localhost:3000/api'; // TODO: Backend URL'ini buraya ekle

  /// Yaklaşan maç bilgisini backend'den çeker
  /// 
  /// Node.js backend'den beklenen endpoint: GET /api/upcoming-match
  /// Beklenen JSON response:
  /// {
  ///   "date": "14 Kasım 16:00",
  ///   "details": "Detaylar"
  /// }
  Future<UpcomingMatch?> getUpcomingMatch() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/upcoming-match'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UpcomingMatch.fromJson(jsonData);
      } else {
        // Hata durumunda null döner
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // Network hatası veya diğer hatalar
      print('API Request Error: $e');
      return null;
    }
  }

  /// Slider için resim URL'lerini backend'den çeker (opsiyonel)
  /// 
  /// Node.js backend'den beklenen endpoint: GET /api/slider-images
  /// Beklenen JSON response:
  /// {
  ///   "images": [
  ///     "https://example.com/image1.jpg",
  ///     "https://example.com/image2.jpg",
  ///     "https://example.com/image3.jpg"
  ///   ]
  /// }
  Future<List<String>> getSliderImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/slider-images'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> images = jsonData['images'] ?? [];
        return images.cast<String>();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('API Request Error: $e');
      return [];
    }
  }
}



