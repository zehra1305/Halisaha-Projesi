class KadroModel {
  final int? id;
  final int kullaniciId;
  final String kadroAdi;
  final String format; // 'yediyeYedi' veya 'sekizeSekiz'
  final String takimAAdi;
  final String takimBAdi;
  final String takimARenk; // Hex color
  final String takimBRenk;
  final List<Map<String, dynamic>> takimAOyunculari;
  final List<Map<String, dynamic>> takimBOyunculari;
  final DateTime? olusturmaTarihi;
  final DateTime? guncellemeTarihi;

  KadroModel({
    this.id,
    required this.kullaniciId,
    required this.kadroAdi,
    required this.format,
    required this.takimAAdi,
    required this.takimBAdi,
    required this.takimARenk,
    required this.takimBRenk,
    required this.takimAOyunculari,
    required this.takimBOyunculari,
    this.olusturmaTarihi,
    this.guncellemeTarihi,
  });

  factory KadroModel.fromJson(Map<String, dynamic> json) {
    return KadroModel(
      id: json['id'],
      kullaniciId: json['kullanici_id'],
      kadroAdi: json['kadro_adi'],
      format: json['format'],
      takimAAdi: json['takim_a_adi'],
      takimBAdi: json['takim_b_adi'],
      takimARenk: json['takim_a_renk'],
      takimBRenk: json['takim_b_renk'],
      takimAOyunculari: List<Map<String, dynamic>>.from(
        json['takim_a_oyunculari'],
      ),
      takimBOyunculari: List<Map<String, dynamic>>.from(
        json['takim_b_oyunculari'],
      ),
      olusturmaTarihi: json['olusturulma_tarihi'] != null
          ? DateTime.parse(json['olusturulma_tarihi'])
          : null,
      guncellemeTarihi: json['guncelleme_tarihi'] != null
          ? DateTime.parse(json['guncelleme_tarihi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kullanici_id': kullaniciId,
      'kadro_adi': kadroAdi,
      'format': format,
      'takim_a_adi': takimAAdi,
      'takim_b_adi': takimBAdi,
      'takim_a_renk': takimARenk,
      'takim_b_renk': takimBRenk,
      'takim_a_oyunculari': takimAOyunculari,
      'takim_b_oyunculari': takimBOyunculari,
      'olusturulma_tarihi': olusturmaTarihi?.toIso8601String(),
      'guncelleme_tarihi': guncellemeTarihi?.toIso8601String(),
    };
  }
}
