class RandevuModel {
  final String? randevuId;
  final String kullaniciId;
  final String tarih; // DD/MM/YYYY formatında
  final String saatBaslangic; // HH:MM formatında
  final String saatBitis; // HH:MM formatında
  final String durum; // beklemede, onaylandi, reddedildi, iptal
  final String saha;
  final String telefon;
  final String? aciklama;
  final DateTime? olusturmaTarihi;

  RandevuModel({
    this.randevuId,
    required this.kullaniciId,
    required this.tarih,
    required this.saatBaslangic,
    required this.saatBitis,
    this.durum = 'beklemede',
    this.saha = 'Ana Saha',
    required this.telefon,
    this.aciklama,
    this.olusturmaTarihi,
  });

  // Backend'e gönderilecek JSON
  Map<String, dynamic> toJson() {
    return {
      if (randevuId != null && randevuId!.isNotEmpty) 'randevuId': randevuId,
      'kullaniciId': kullaniciId,
      'tarih': tarih,
      'saatBaslangic': saatBaslangic,
      'saatBitis': saatBitis,
      'durum': durum,
      'saha': saha,
      'telefon': telefon,
      if (aciklama != null) 'aciklama': aciklama,
    };
  }

  // Backend'den gelen JSON'ı parse et
  factory RandevuModel.fromJson(Map<String, dynamic> json) {
    return RandevuModel(
      randevuId: json['randevuId']?.toString(),
      kullaniciId: json['kullaniciId']?.toString() ?? '',
      tarih: json['tarih'] ?? '',
      saatBaslangic: json['saatBaslangic'] ?? '',
      saatBitis: json['saatBitis'] ?? '',
      durum: json['durum'] ?? 'beklemede',
      saha: json['saha'] ?? 'Ana Saha',
      telefon: json['telefon'] ?? '',
      aciklama: json['aciklama'],
      olusturmaTarihi: json['olusturmaTarihi'] != null
          ? DateTime.parse(json['olusturmaTarihi'])
          : null,
    );
  }

  // Durum rengi
  String get durumRenk {
    switch (durum) {
      case 'onaylandi':
        return '#4CAF50'; // Yeşil
      case 'beklemede':
        return '#FF9800'; // Turuncu
      case 'reddedildi':
        return '#F44336'; // Kırmızı
      case 'iptal':
        return '#9E9E9E'; // Gri
      default:
        return '#9E9E9E';
    }
  }

  // Durum metni
  String get durumMetni {
    switch (durum) {
      case 'onaylandi':
        return 'Onaylandı';
      case 'beklemede':
        return 'Onay Bekliyor';
      case 'reddedildi':
        return 'Reddedildi';
      case 'iptal':
        return 'İptal Edildi';
      default:
        return durum;
    }
  }

  // Tam tarih saat
  String get fullDateTime => '$tarih $saatBaslangic-$saatBitis';

  // Geçmiş randevu mu?
  bool get isGecmis {
    try {
      final parts = tarih.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final timeParts = saatBitis.split(':');
      if (timeParts.length != 2) return false;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final randevuDateTime = DateTime(year, month, day, hour, minute);
      return randevuDateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}
