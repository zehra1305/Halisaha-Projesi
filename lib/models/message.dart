class Message {
  final int id;
  final String sender;    // Gonderen Adı
  final String content;   // Mesaj İçeriği
  final String createdAt; // Tarih
  
  // --- YENİ EKLENEN ---
  final bool isAdmin;     // Mesajı Admin mi attı? (Baloncuk yönü için lazım)

  // --- ESKİ DEĞİŞKENLER (Kodların bozulmaması için tutuyoruz) ---
  final String subject;   
  final bool isRead;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.createdAt,
    required this.isAdmin,
    required this.subject,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      // ID: Veritabanında 'mesaj_id' var, eğer yoksa eski 'id'yi dene
      id: json['mesaj_id'] ?? json['id'] ?? 0,

      // SENDER: Veritabanında 'gonderen_ad' (JOIN ile geliyor), yoksa eski 'sender'
      sender: json['gonderen_ad'] ?? json['sender'] ?? 'Bilinmiyor',

      // CONTENT: Veritabanında 'icerik' var, yoksa eski 'content'
      content: json['icerik'] ?? json['content'] ?? '',

      // DATE: Veritabanında 'gonderme_zamani' var
      createdAt: json['gonderme_zamani'] ?? json['created_at'] ?? DateTime.now().toString(),

      // IS_ADMIN: Eğer gonderen_id 1 ise, bu mesajı biz (Admin) attık demektir.
      isAdmin: (json['gonderen_id'] == 1),

      // --- ESKİ ALANLARI DOLDURMA (Hata Çıkmasın Diye) ---
      // Veritabanında konu yok, o yüzden varsayılan 'Sohbet Mesajı' diyoruz.
      subject: json['subject'] ?? 'Sohbet Mesajı', 
      
      // Veritabanında okundu bilgisi yoksa varsayılan true yapıyoruz.
      isRead: json['is_read'] ?? true, 
    );
  }
}