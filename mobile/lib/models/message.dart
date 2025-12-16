class Message {
  final String sender;
  final String subject;
  final String content;
  final String createdAt;
  final bool isRead;

  Message({
    required this.sender,
    required this.subject,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });
}