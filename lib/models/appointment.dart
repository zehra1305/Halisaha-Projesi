class Appointment {
  final int id;             // Veritabanındaki randevu_id
  final String customerName; // musteri_ad
  final String? phone;       // telefon
  final String field;        // saha
  final String date;         // tarih
  final String startTime;    // saat_baslangic
  final String endTime;      // saat_bitis
  final String status;       // durum (beklemede, onaylandi, iptal)
  final String? note;        // aciklama

  Appointment({
    required this.id,
    required this.customerName,
    this.phone,
    required this.field,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.note,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      // DÜZELTME: Veritabanındaki kolon adı 'randevu_id'
      id: json['randevu_id'] ?? 0, 
      customerName: json['musteri_ad'] ?? 'İsimsiz Müşteri',
      phone: json['telefon'],
      field: json['saha'] ?? 'Belirtilmemiş',
      
      // --- TARİH DÜZELTMESİ (TIMEZONE FIX) ---
      // Gelen veriyi önce DateTime objesine çeviriyoruz, sonra .toLocal() 
      // diyerek Türkiye saatine (UTC+3) denk getiriyoruz.
      date: json['tarih'] != null 
          ? DateTime.parse(json['tarih'].toString()).toLocal().toString().split(' ')[0] 
          : '',
      // ---------------------------------------

      startTime: json['saat_baslangic'] ?? '',
      endTime: json['saat_bitis'] ?? '',
      // DÜZELTME: Varsayılan durumu 'beklemede' yaptık çünkü DB öyle
      status: json['durum'] ?? 'beklemede',
      note: json['aciklama'],
    );
  }

  String get time => "$startTime - $endTime";
}