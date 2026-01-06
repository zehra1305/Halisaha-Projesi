class Customer {
  final int id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  // JSON verisini Dart nesnesine çevirir
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      // Veritabanındaki 'kullanici_id' buraya eşleşiyor
      id: json['kullanici_id'] ?? 0, 
      
      // Tabloda 'name' yok, 'ad' ve 'soyad' var. Onları birleştiriyoruz:
      name: "${json['ad'] ?? ''} ${json['soyad'] ?? ''}".trim(),
      
      // Email sütunu aynı
      email: json['email'] ?? '',
    );
  }
}