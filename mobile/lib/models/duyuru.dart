class Duyuru {
  final int id;
  final String baslik;
  final String resimUrl;
  final String metin;
  final DateTime tarih;

  Duyuru({
    required this.id,
    required this.baslik,
    required this.resimUrl,
    required this.metin,
    required this.tarih,
  });

  factory Duyuru.fromJson(Map<String, dynamic> json) {
    return Duyuru(
      id: json['id'],
      baslik: json['baslik'] ?? '',
      resimUrl: json['resim_url'],
      metin: json['metin'],
      tarih: DateTime.parse(json['tarih']),
    );
  }
}