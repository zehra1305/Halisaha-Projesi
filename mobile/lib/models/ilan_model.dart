import 'package:flutter/material.dart';

class IlanModel {
  final int? ilanId;
  final String baslik;
  final String aciklama;
  final String tarih;
  final String saat;
  final String konum;
  final int? kisiSayisi;
  final String? mevki;
  final String? seviye;
  final String? ucret;
  final int? kullaniciId;
  final String? kullaniciAdi;
  final String? profilFotografi;
  final String? telefon;
  final String? olusturmaTarihi;

  IlanModel({
    this.ilanId,
    required this.baslik,
    required this.aciklama,
    required this.tarih,
    required this.saat,
    required this.konum,
    this.kisiSayisi,
    this.mevki,
    this.seviye,
    this.ucret,
    this.kullaniciId,
    this.kullaniciAdi,
    this.profilFotografi,
    this.telefon,
    this.olusturmaTarihi,
  });

  // Backend'e veri gönderirken kullanılır
  Map<String, dynamic> toJson() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'tarih': tarih,
      'saat': saat,
      'konum': konum,
      if (kisiSayisi != null) 'kisiSayisi': kisiSayisi,
      if (mevki != null) 'mevki': mevki,
      if (seviye != null) 'seviye': seviye,
      if (ucret != null) 'ucret': ucret,
      if (kullaniciId != null) 'kullaniciId': kullaniciId,
    };
  }

  // Backend'den veri gelirken kullanılır
  factory IlanModel.fromJson(Map<String, dynamic> json) {
    return IlanModel(
      ilanId: json['ilan_id'] ?? json['ilanId'],
      baslik: json['baslik'] ?? '',
      aciklama: json['aciklama'] ?? '',
      tarih: json['tarih'] ?? '',
      saat: json['saat'] ?? '',
      konum: json['konum'] ?? '',
      kisiSayisi: json['kisi_sayisi'] ?? json['kisiSayisi'],
      mevki: json['mevki'],
      seviye: json['seviye'],
      ucret: json['ucret'],
      kullaniciId: json['kullanici_id'] ?? json['kullaniciId'],
      kullaniciAdi: json['kullanici_adi'] ?? json['kullaniciAdi'],
      profilFotografi: json['profil_fotografi'] ?? json['profilFotografi'],
      telefon: json['telefon'],
      olusturmaTarihi: json['olusturma_tarihi'] ?? json['olusturmaTarihi'],
    );
  }

  // Tarih ve saat bilgisini DateTime objesine dönüştüren getter
  DateTime get fullDateTime {
    try {
      // Eğer tarih ISO 8601 timestamp formatındaysa (2025-12-17T21:00:00.000Z)
      if (tarih.contains('T')) {
        return DateTime.parse(tarih);
      }

      // tarih format: YYYY-MM-DD (form'dan geliyor)
      final dateParts = tarih.split('-');
      final timeParts = saat.split(':');

      if (dateParts.length == 3 && timeParts.length >= 2) {
        return DateTime(
          int.parse(dateParts[0]), // YYYY
          int.parse(dateParts[1]), // MM
          int.parse(dateParts[2]), // DD
          int.parse(timeParts[0]), // HH
          int.parse(timeParts[1]), // MM
        );
      }
    } catch (e) {
      print('Tarih parse hatası: $e, tarih: $tarih, saat: $saat');
      return DateTime.now().subtract(const Duration(days: 1));
    }
    return DateTime.now().subtract(const Duration(days: 1));
  }

  // İlanın süresinin dolup dolmadığını kontrol eder
  bool get isExpired => fullDateTime.isBefore(DateTime.now());
}
