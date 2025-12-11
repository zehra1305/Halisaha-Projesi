class Duyuru {
  final int id;
  final String resimUrl;
  final String metin;
  final DateTime tarih;

  Duyuru({
    required this.id,
    required this.resimUrl,
    required this.metin,
    required this.tarih,
  });

  factory Duyuru.fromJson(Map<String, dynamic> json) {
    return Duyuru(
      id: json['id'],
      resimUrl: json['resim_url'],
      metin: json['metin'],
      tarih: DateTime.parse(json['tarih']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'resim_url': resimUrl,
        'metin': metin,
        'tarih': tarih.toIso8601String(),
      };
}
