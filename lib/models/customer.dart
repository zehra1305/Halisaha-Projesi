class Customer {
  final int id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  // JSON verisini Dart nesnesine çevirir
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'], // PostgreSQL'den ID genelde int gelir
      name: json['name'] ?? 'İsimsiz',
      email: json['email'] ?? '',
    );
  }
}