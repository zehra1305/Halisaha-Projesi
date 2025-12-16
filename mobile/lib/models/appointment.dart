class Appointment {
  final String time;
  final String status; // "MÜSAİT", "REZERVE", "DOLU"
  final String customerName;

  Appointment({required this.time, required this.status, required this.customerName});
}