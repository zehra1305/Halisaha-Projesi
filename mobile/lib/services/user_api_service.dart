import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/duyuru.dart';

class UserApiService {
  // Backend Adresi (Otomatik Ayarlanır)
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:3001';
    if (Platform.isAndroid) return 'http://10.0.2.2:3001';
    return 'http://localhost:3001';
  }

  // Duyuruları Getir
  Future<List<Duyuru>> getDuyurular() async {
    try {
      final url = '$baseUrl/api/duyurular';
      debugPrint("📡 Duyurular API çağrısı: $url");

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint("⏱️ API Timeout!");
              throw Exception('Zaman aşımı');
            },
          );

      debugPrint("📡 Response Status: ${response.statusCode}");
      debugPrint("📡 Response Headers: ${response.headers}");

      if (response.statusCode == 200) {
        debugPrint("📡 Response Body: ${response.body}");

        try {
          List<dynamic> body = jsonDecode(response.body);
          debugPrint("📡 Parse edilen duyuru sayısı: ${body.length}");

          if (body.isEmpty) {
            debugPrint("⚠️ Backend boş liste döndürdü");
            return [];
          }

          final duyurular = body.map((item) {
            debugPrint("   Duyuru parse ediliyor: ${item['baslik']}");
            return Duyuru.fromJson(item);
          }).toList();

          debugPrint("✅ ${duyurular.length} duyuru başarıyla yüklendi");
          return duyurular;
        } catch (parseError) {
          debugPrint("❌ JSON Parse hatası: $parseError");
          debugPrint("   Raw response: ${response.body}");
          return [];
        }
      } else {
        debugPrint(
          "⚠️ API başarısız: ${response.statusCode} - ${response.body}",
        );
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Duyurular API hatası: $e");
      debugPrint("   Stack trace: $stackTrace");
      return [];
    }
  }
}
