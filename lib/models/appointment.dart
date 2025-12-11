class Appointment {
  final String time;      // Örn: "15:00"
  final String status;    // Örn: "REZERVE", "MÜSAİT", "İPTAL"
  final String customerName; // Örn: "Ahmet Yılmaz" (Opsiyonel)

  Appointment({
    required this.time,
    required this.status,
    this.customerName = ""
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      time: json['time'] ?? '',
      status: json['status'] ?? 'MÜSAİT',
      customerName: json['customer_name'] ?? '',
    );
  }
}