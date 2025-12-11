import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/ilan_model.dart';

// API temel adresi (BACKEND ADRESİ)

// ANDROID EMULATOR :
//const String _baseUrl = "http://10.0.2.2:5000/api/ilanlar";

//  Windows/Web-də test ediliyorsa, üstdeki satri comment et,
// altdakını aç:
 const String _baseUrl = "http://localhost:5000/api/ilanlar";

class ApiService {
  // Uygulama boyunca tek bir instance kullanmak için
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // 1. TÜM İLANLARI ÇEKME – GET /api/ilanlar
  Future<List<IlanModel>> fetchIlanlar() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => IlanModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'İlanlar yüklenemedi. Kod: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      throw Exception('API bağlantı hatası (fetchIlanlar): $e');
    }
  }

  // 2. YENİ İLAN EKLEME – POST /api/ilanlar
  Future<IlanModel> addIlan(IlanModel ilan) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ilan.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return IlanModel.fromJson(json);
      } else {
        throw Exception(
            'İlan eklenemedi. Kod: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      throw Exception('API bağlantı hatası (addIlan): $e');
    }
  }
}