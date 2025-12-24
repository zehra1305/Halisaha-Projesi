import 'package:flutter/material.dart';
import '../ilanlar/chat_page.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

// 👇 1. DEĞİŞİKLİK: Bizim Support ekranını buraya dahil ettik
import '../support_chat_screen.dart';

class MesajlarPage extends StatefulWidget {
  const MesajlarPage({super.key});

  @override
  State<MesajlarPage> createState() => _MesajlarPageState();
}

class _MesajlarPageState extends State<MesajlarPage> {
  final Color _mainGreen = const Color(0xFF2FB335);
  final TextEditingController _searchController = TextEditingController();

  // Backend'den gelecek sohbetler
  final List<ConversationItem> _conversations = [];
  List<ConversationItem> _filteredConversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_filterConversations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = List.from(_conversations);
      } else {
        _filteredConversations = _conversations.where((conversation) {
          return conversation.userName.toLowerCase().contains(query) ||
              conversation.lastMessage.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _loadConversations() async {
    try {
      final storage = StorageService();
      final userId = await storage.getUserId();
      if (userId == null) return;

      final result = await ApiService.instance.fetchConversations(userId);
      if (result['success']) {
        final List<dynamic> data = result['data'];
        setState(() {
          _conversations.clear();
          _conversations.addAll(
            data.map((c) {
              final lastTimeStr =
                  c['son_mesaj_zamani'] ?? c['olusturma_zamani'];
              DateTime lastTime;
              try {
                lastTime = DateTime.parse(
                  lastTimeStr ?? DateTime.now().toIso8601String(),
                );
              } catch (_) {
                lastTime = DateTime.now();
              }

              return ConversationItem(
                sohbetId: c['sohbet_id'],
                userId: c['diger_kullanici_id'] ?? 0,
                userName: c['diger_kullanici_ad'] ?? 'Kullanıcı',
                profileImageUrl: c['diger_kullanici_fotografi'],
                lastMessage: c['son_mesaj'] ?? '',
                lastMessageTime: lastTime,
                unreadCount: 0,
              );
            }).toList(),
          );
          _filteredConversations = List.from(_conversations);
        });
      } else {
        // hata mesajı gösterilebilir
      }
    } catch (e) {
      // Hata yönetimi
      print('Sohbet yükleme hatası: $e');
    }
  }

  // 👇 2. DEĞİŞİKLİK: Eski ChatPage yerine YENİ EKRANI açıyoruz
  void _openAdminChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Burası ChatPage idi, SupportChatScreen yaptık ✅
        builder: (context) => const SupportChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        title: const Text(
          'Sohbetler',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Admin chat - sabit üstte
          Container(
            color: _mainGreen.withOpacity(0.05),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _mainGreen,
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                ),
              ),
              title: const Text(
                'Halısaha Yönetimi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text(
                'Yönetimle iletişime geç',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: Icon(Icons.chevron_right, color: _mainGreen),
              onTap:
                  _openAdminChat, // Buraya tıklayınca yukarıdaki fonksiyon çalışacak
            ),
          ),
          const Divider(height: 1),

          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ara...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),

          // Konuşma listesi
          Expanded(
            child: _filteredConversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Henüz mesajınız yok'
                              : 'Sonuç bulunamadı',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'İlan sahipleriyle mesajlaşmaya başlayın'
                              : 'Farklı bir arama yapın',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _filteredConversations[index];
                      return _buildConversationItem(conversation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(ConversationItem conversation) {
    // Profil resmi URL'ini düzenle
    String? imageUrl;
    if (conversation.profileImageUrl != null &&
        conversation.profileImageUrl!.isNotEmpty) {
      imageUrl = conversation.profileImageUrl!.startsWith('http')
          ? conversation.profileImageUrl
          : 'http://10.0.2.2:3001${conversation.profileImageUrl!.startsWith('/') ? conversation.profileImageUrl : '/${conversation.profileImageUrl}'}';
    }

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: _mainGreen.withOpacity(0.2),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          conversation.userName.isNotEmpty
                              ? conversation.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: _mainGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    conversation.userName.isNotEmpty
                        ? conversation.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: _mainGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.userName,
                  style: TextStyle(
                    fontWeight: conversation.unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                _formatTime(conversation.lastMessageTime),
                style: TextStyle(
                  color: conversation.unreadCount > 0
                      ? _mainGreen
                      : Colors.grey,
                  fontSize: 12,
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: conversation.unreadCount > 0
                        ? Colors.black87
                        : Colors.grey,
                    fontWeight: conversation.unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (conversation.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _mainGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  sohbetId: conversation.sohbetId,
                  receiverName: conversation.userName,
                  receiverId: conversation.userId,
                  profileImageUrl: conversation.profileImageUrl,
                ),
              ),
            ).then((_) {
              _loadConversations();
            });
          },
        ),
        const Divider(height: 1, indent: 80),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Bugün
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Dün
      return 'Dün';
    } else if (difference.inDays < 7) {
      // Bu hafta
      final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
      return weekdays[time.weekday - 1];
    } else {
      // Daha eski
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class ConversationItem {
  final int sohbetId;
  final int userId;
  final String userName;
  final String? profileImageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationItem({
    required this.sohbetId,
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}
