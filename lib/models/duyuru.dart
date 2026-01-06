class Duyuru {
  final int id;
  final String baslik; // <-- Bu eksikti, ekledik
  final String metin;
  final String resimUrl; // main.dart'ta null hatası vermemesi için String yaptık
  final String tarih;

  Duyuru({
    required this.id,
    required this.baslik,
    required this.metin,
    required this.resimUrl,
    required this.tarih,
  });

  factory Duyuru.fromJson(Map<String, dynamic> json) {
    return Duyuru(
      id: json['id'] ?? 0,
      baslik: json['baslik'] ?? 'Başlıksız',
      metin: json['metin'] ?? '',
      resimUrl: json['resim_url'] ?? '',
      // Tarih null gelirse şimdiki zamanı atayalım
      tarih: json['tarih'] ?? DateTime.now().toIso8601String(),
    );
  }
}