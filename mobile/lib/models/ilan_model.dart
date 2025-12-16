import 'package:flutter/material.dart';

class IlanModel {
  final String id;
  final String adSoyad;
  final String baslik;
  final String konum;
  final String tarih;
  final String saat;
  final String kisiSayisi;
  final String mevki;
  final String seviye;
  final String ucret;
  final String aciklama;
  final String yas;
  final String? userId;

  IlanModel({
    required this.id,
    required this.adSoyad,
    required this.baslik,
    required this.konum,
    required this.tarih,
    required this.saat,
    required this.kisiSayisi,
    required this.mevki,
    required this.seviye,
    required this.ucret,
    required this.aciklama,
    required this.yas,
    this.userId,
  });

  // Backend'e veri gönderirken kullanılır
  // Backend'e veri gönderirken kullanılır
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'adSoyad': adSoyad,
      'baslik': baslik,
      'konum': konum,
      'tarih': tarih,
      'saat': saat,
      'kisiSayisi': kisiSayisi,
      'mevki': mevki,
      'seviye': seviye,
      'ucret': ucret,
      'aciklama': aciklama,
      'yas': yas,
      if (userId != null) 'userId': userId,
    };
  }

  // Backend'den veri gelirken kullanılır
  factory IlanModel.fromJson(Map<String, dynamic> json) {
    return IlanModel(
      id: json['id']?.toString() ?? '',
      adSoyad: json['adSoyad'] ?? '',
      baslik: json['baslik'] ?? '',
      konum: json['konum'] ?? '',
      tarih: json['tarih'] ?? '',
      saat: json['saat'] ?? '',
      kisiSayisi: json['kisiSayisi']?.toString() ?? '',
      mevki: json['mevki'] ?? '',
      seviye: json['seviye'] ?? '',
      ucret: json['ucret']?.toString() ?? '',
      aciklama: json['aciklama'] ?? '',
      yas: json['yas']?.toString() ?? '',
      userId: json['userId']?.toString(),
    );
  }

  // Tarih ve saat bilgisini DateTime objesine dönüştüren getter
  DateTime get fullDateTime {
    try {
      final dateParts = tarih.split('/');
      final timeParts = saat.split(':');

      if (dateParts.length == 3 && timeParts.length >= 2) {
        return DateTime(
          int.parse(dateParts[2]), // YYYY
          int.parse(dateParts[1]), // MM
          int.parse(dateParts[0]), // DD
          int.parse(timeParts[0]), // HH
          int.parse(timeParts[1]), // MM
        );
      }
    } catch (e) {
      return DateTime.now().subtract(const Duration(days: 1));
    }
    return DateTime.now().subtract(const Duration(days: 1));
  }

  // İlanın süresinin dolup dolmadığını kontrol eder
  bool get isExpired => fullDateTime.isBefore(DateTime.now());
}
