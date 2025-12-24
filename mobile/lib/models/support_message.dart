class SupportMessage {
  final int id;

  final int senderId; // Mesajı kim attı? (Admin mi, Kullanıcı mı)

  final String content;

  final String date;

  SupportMessage({
    required this.id,

    required this.senderId,

    required this.content,

    required this.date,
  });

  // Veritabanından gelen JSON verisini Dart nesnesine çevirir

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['mesaj_id'] ?? 0,

      senderId: json['gonderen_id'] ?? 0,

      content: json['icerik'] ?? '',

      date: json['gonderme_zamani'] ?? '',
    );
  }
}
