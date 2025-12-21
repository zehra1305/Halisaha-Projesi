import 'package:flutter/material.dart';

// Oyuncu Pozisyonları
enum Pozisyon { kaleci, defans, ortasaha, forvet }

// Oyuncu Modeli
class Oyuncu {
  final String id;
  String isim;
  Pozisyon? pozisyon;
  Color? formaRengi;
  int? numarasi;

  Oyuncu({
    required this.id,
    required this.isim,
    this.pozisyon,
    this.formaRengi,
    this.numarasi,
  });

  Oyuncu copyWith({
    String? isim,
    Pozisyon? pozisyon,
    Color? formaRengi,
    int? numarasi,
  }) {
    return Oyuncu(
      id: id,
      isim: isim ?? this.isim,
      pozisyon: pozisyon ?? this.pozisyon,
      formaRengi: formaRengi ?? this.formaRengi,
      numarasi: numarasi ?? this.numarasi,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'isim': isim,
    'pozisyon': pozisyon?.index,
    'formaRengi': formaRengi?.value,
    'numarasi': numarasi,
  };

  factory Oyuncu.fromJson(Map<String, dynamic> json) => Oyuncu(
    id: json['id'] as String,
    isim: json['isim'] as String,
    pozisyon: json['pozisyon'] != null
        ? Pozisyon.values[json['pozisyon'] as int]
        : null,
    formaRengi: json['formaRengi'] != null
        ? Color(json['formaRengi'] as int)
        : null,
    numarasi: json['numarasi'] as int?,
  );
}

// Takım Modeli
class Takim {
  final String id;
  String takimAdi;
  Color formaRengi;
  List<Oyuncu> oyuncular;

  Takim({
    required this.id,
    required this.takimAdi,
    required this.formaRengi,
    List<Oyuncu>? oyuncular,
  }) : oyuncular = oyuncular ?? [];

  void oyuncuEkle(Oyuncu oyuncu) {
    oyuncular.add(oyuncu);
  }

  void oyuncuCikar(String oyuncuId) {
    oyuncular.removeWhere((o) => o.id == oyuncuId);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'takimAdi': takimAdi,
    'formaRengi': formaRengi.value,
    'oyuncular': oyuncular.map((o) => o.toJson()).toList(),
  };

  factory Takim.fromJson(Map<String, dynamic> json) => Takim(
    id: json['id'] as String,
    takimAdi: json['takimAdi'] as String,
    formaRengi: Color(json['formaRengi'] as int),
    oyuncular: (json['oyuncular'] as List?)
        ?.map((o) => Oyuncu.fromJson(o as Map<String, dynamic>))
        .toList(),
  );
}

// Saha Formatı
enum SahaFormati {
  yediyeYedi, // 7v7
  sekizeSekiz, // 8v8
}

// Kadro Modeli
class KadroModel {
  final String id;
  String kadroAdi;
  SahaFormati format;
  Takim? takimA;
  Takim? takimB;
  List<Oyuncu> bekleyenOyuncular; // Henüz yerleştirilmemiş oyuncular

  KadroModel({
    required this.id,
    required this.kadroAdi,
    required this.format,
    this.takimA,
    this.takimB,
    List<Oyuncu>? bekleyenOyuncular,
  }) : bekleyenOyuncular = bekleyenOyuncular ?? [];

  int get toplamOyuncuSayisi {
    switch (format) {
      case SahaFormati.yediyeYedi:
        return 14;
      case SahaFormati.sekizeSekiz:
        return 16;
    }
  }

  int get takimBasinaOyuncu {
    switch (format) {
      case SahaFormati.yediyeYedi:
        return 7;
      case SahaFormati.sekizeSekiz:
        return 8;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kadroAdi': kadroAdi,
    'format': format.index,
    'takimA': takimA?.toJson(),
    'takimB': takimB?.toJson(),
    'bekleyenOyuncular': bekleyenOyuncular.map((o) => o.toJson()).toList(),
  };

  factory KadroModel.fromJson(Map<String, dynamic> json) => KadroModel(
    id: json['id'] as String,
    kadroAdi: json['kadroAdi'] as String,
    format: SahaFormati.values[json['format'] as int],
    takimA: json['takimA'] != null
        ? Takim.fromJson(json['takimA'] as Map<String, dynamic>)
        : null,
    takimB: json['takimB'] != null
        ? Takim.fromJson(json['takimB'] as Map<String, dynamic>)
        : null,
    bekleyenOyuncular: (json['bekleyenOyuncular'] as List?)
        ?.map((o) => Oyuncu.fromJson(o as Map<String, dynamic>))
        .toList(),
  );
}
