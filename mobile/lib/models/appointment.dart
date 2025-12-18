class Appointment {
  final String id;
  final String time;
  final String status; // AVAILABLE, PENDING, APPROVED
  final String? userId;
  final String? note;
  final String? date;

  Appointment({
    required this.id,
    required this.time,
    required this.status,
    this.userId,
    this.note,
    this.date,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      userId: json['user_id']?.toString(),
      note: json['note'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'status': status,
      'user_id': userId,
      'note': note,
      'date': date,
    };
  }
}
