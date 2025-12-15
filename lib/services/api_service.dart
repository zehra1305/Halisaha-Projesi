import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/ilan_model.dart';
import '../models/appointment.dart';

//  BACKEND HOST SEÇİMİ 
// Web/Windows: localhost
// Android Emulator: 10.0.2.2
// Gerçek telefon: PC'nin IPv4 adresi (ör: 192.168.1.35)

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;

  static const String _realDeviceHost = "192.168.1.35"; // gerekirse değiştir
  static const bool _useRealDevice = false;
  static const int _port = 5000;

  String get _host {
    if (kIsWeb) return "localhost";
    return _useRealDevice ? _realDeviceHost : "10.0.2.2";
  }

  String get _backend => "http://$_host:$_port";

  String get _ilanBaseUrl => "$_backend/api/ilanlar";
  String get _appointmentsBaseUrl => "$_backend/appointments";

  // İLANLAR 
  Future<List<IlanModel>> fetchIlanlar() async {
    final response = await http.get(Uri.parse(_ilanBaseUrl));
    if (response.statusCode != 200) {
      throw Exception('İlanlar yüklenemedi: ${response.statusCode} ${response.body}');
    }
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => IlanModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<IlanModel> addIlan(IlanModel ilan) async {
    final response = await http.post(
      Uri.parse(_ilanBaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ilan.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('İlan eklenemedi: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return IlanModel.fromJson(json);
  }

  //  RANDEVU 
  Future<List<Appointment>> getAppointments(String date) async {
    final uri = Uri.parse("$_appointmentsBaseUrl?date=$date");
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Randevular alınamadı: ${response.statusCode} ${response.body}");
    }

    final List<dynamic> list = jsonDecode(response.body);
    return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> bookAppointment({
    required String date,
    required String time,
    String userId = "1",
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse(_appointmentsBaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "date": date,
        "time": time,
        "userId": userId,
        if (note != null && note.trim().isNotEmpty) "note": note.trim(),
      }),
    );

    if (response.statusCode == 201) return true;
    if (response.statusCode == 409) return false;

    throw Exception("POST randevu hata: ${response.statusCode} ${response.body}");
  }
}