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
      final response = await http.get(Uri.parse('$baseUrl/api/duyurular'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Duyuru.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Hata: $e");
      return [];
    }
  }
}
