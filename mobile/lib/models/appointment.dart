class Appointment {
  final String id;
  final String time;
  final String status; // "AVAILABLE", "PENDING", "APPROVED"

  Appointment({
    required this.id,
    required this.time,
    required this.status,
  });

  // Backend'den gelen JSON'ı Dart nesnesine çevirir
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
    );
  }

  // Dart nesnesini Backend'e yollarken JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'status': status,
    };
  }
}