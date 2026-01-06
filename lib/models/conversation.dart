class Conversation {
  final int id;
  final String title; // Konuştuğumuz kişinin adı
  final String date;

  Conversation({required this.id, required this.title, required this.date});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['sohbet_id'] ?? 0,
      // Backend'den gelen 'karsi_taraf_ad' bilgisini kullanıyoruz
      title: json['karsi_taraf_ad'] ?? 'İsimsiz Sohbet',
      date: json['olusturma_zamani'] ?? '',
    );
  }
}