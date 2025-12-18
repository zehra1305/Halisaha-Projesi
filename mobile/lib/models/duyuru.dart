class Duyuru {
  final int id;
  final String baslik;
  final String metin;
  final String? resimUrl;
  final String tarih;

  Duyuru({
    required this.id,
    required this.baslik,
    required this.metin,
    this.resimUrl,
    required this.tarih,
  });

  factory Duyuru.fromJson(Map<String, dynamic> json) {
    return Duyuru(
      id: json['id'],
      baslik: json['baslik'], // Backend'den 'baslik' olarak geliyor
      metin: json['metin'],
      resimUrl: json['resim_url'], // Backend'den 'resim_url' olarak geliyor
      tarih: json['tarih'] ?? '',
    );
  }
}