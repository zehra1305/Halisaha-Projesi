class Message {
  final int id;
  final String sender;
  final String subject;
  final String content;
  final String createdAt; // Tarih string olarak gelir
  final bool isRead;

  Message({
    required this.id,
    required this.sender,
    required this.subject,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: json['sender'] ?? 'Bilinmiyor',
      subject: json['subject'] ?? 'Konu Yok',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toString(),
      isRead: json['is_read'] ?? false,
    );
  }
}