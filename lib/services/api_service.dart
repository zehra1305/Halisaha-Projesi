// GELECEKTE KULLANILACAK: HTTP İSTEKLERİ İÇİN KÜTÜPHANE
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // jsonDecode kullanmak için

import '../models/ilan_model.dart'; // Model yapısına erişim için

// API temel adresi (Backend bittiğinde burayı dolduracaksınız)
const String _baseUrl = "https://seninapiadresin.com/api/ilanlar";

class ApiService {

  // Singleton Pattern (Opsiyonel): Tek bir örnekle çalışmayı sağlar
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // 1. İLANLARI GETİRME İŞLEMİ (READ)
  // Backend hazır olunca buraya http.get kodu yazılacak.
  Future<List<IlanModel>> fetchIlanlar() async {
    /* try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => IlanModel.fromJson(json)).toList();
      } else {
        throw Exception('İlanlar yüklenemedi.');
      }
    } catch (e) {
      throw Exception('API bağlantı hatası: $e');
    } */

    // Test aşaması için boş liste döndürülür:
    return [];
  }

  // 2. YENİ İLAN EKLEME İŞLEMİ (CREATE)
  // Backend hazır olunca buraya http.post kodu yazılacak.
  Future<IlanModel> addIlan(IlanModel ilan) async {
    /* final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ilan.toJson()),
    );

    if (response.statusCode == 201) {
      return IlanModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('İlan eklenemedi.');
    } */

    // Şimdilik sadece gönderilen modeli geri döndürüyoruz:
    return ilan;
  }
}