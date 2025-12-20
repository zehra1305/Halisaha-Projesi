import 'package:flutter/material.dart';
import '../ilanlar/chat_page.dart';

class MesajlarPage extends StatefulWidget {
  const MesajlarPage({super.key});

  @override
  State<MesajlarPage> createState() => _MesajlarPageState();
}

class _MesajlarPageState extends State<MesajlarPage> {
  final Color _mainGreen = const Color(0xFF2FB335);

  // Örnek mesaj listesi - Backend'den gelecek
  final List<ConversationItem> _conversations = [];

  @override
  void initState() {
    super.initState();
    // Örnek veriler - gerçek uygulamada backend'den gelecek
    _loadConversations();
  }

  void _loadConversations() {
    // Backend'den konuşmalar yüklenecek
    // Şimdilik örnek veri
  }

  void _openAdminChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatPage(
          receiverName: 'Halısaha Yönetimi',
          receiverId: 0, // Admin ID
          profileImageUrl: null,
        ),
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
              onTap: _openAdminChat,
            ),
          ),
          const Divider(height: 1),

          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ara...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
            child: _conversations.isEmpty
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
                          'Henüz mesajınız yok',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlan sahipleriyle mesajlaşmaya başlayın',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return _buildConversationItem(conversation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(ConversationItem conversation) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: _mainGreen.withOpacity(0.2),
            backgroundImage: conversation.profileImageUrl != null
                ? NetworkImage(conversation.profileImageUrl!)
                : null,
            child: conversation.profileImageUrl == null
                ? Text(
                    conversation.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: _mainGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
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
                  receiverName: conversation.userName,
                  receiverId: conversation.userId,
                  profileImageUrl: conversation.profileImageUrl,
                ),
              ),
            );
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
  final int userId;
  final String userName;
  final String? profileImageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationItem({
    required this.userId,
    required this.userName,
    this.profileImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}
