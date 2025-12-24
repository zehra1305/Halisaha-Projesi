import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/duyuru.dart';

class UserApiService {
  // Backend Adresi - Canlı Azure Sunucusu
  // Artık localhost yerine bu linki kullanıyoruz
  static const String baseUrl =
      'https://halisaha-mobil-backend-c4dtaqfnfpdfepg5.germanywestcentral-01.azurewebsites.net';

  // Duyuruları Getir
  Future<List<Duyuru>> getDuyurular() async {
    try {
      // url değişkeni otomatik olarak Azure linkini alacak
      final url = '$baseUrl/api/duyurular';
      debugPrint("📡 Duyurular API çağrısı: $url");

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(
              seconds: 15,
            ), // Azure'un uyanması için süreyi biraz artırdık
            onTimeout: () {
              debugPrint("⏱️ API Timeout!");
              throw Exception('Zaman aşımı');
            },
          );

      // ... Kodun geri kalan kısmı aynı kalabilir
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
