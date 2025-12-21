import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class ChatPage extends StatefulWidget {
  final int? sohbetId;
  final String receiverName;
  final int? receiverId;
  final String? profileImageUrl;

  const ChatPage({
    super.key,
    this.sohbetId,
    required this.receiverName,
    this.receiverId,
    this.profileImageUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final Color _mainGreen = const Color(0xFF2FB335);

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    if (widget.sohbetId == null) return;
    try {
      final result = await ApiService.instance.fetchMessages(
        widget.sohbetId.toString(),
      );
      if (result['success']) {
        final storage = StorageService();
        final currentIdStr = await storage.getUserId();
        final currentId = currentIdStr != null ? int.parse(currentIdStr) : null;

        final List<dynamic> data = result['data'];
        setState(() {
          _messages.clear();
          _messages.addAll(
            data.map((m) {
              DateTime time;
              try {
                time = DateTime.parse(m['gonderme_zamani']);
              } catch (_) {
                time = DateTime.now();
              }
              final isSent = currentId != null
                  ? m['gonderen_id'] == currentId
                  : false;

              // Debug: Profil fotoğrafı kontrolü
              final profileUrl = !isSent ? m['profil_fotografi'] : null;
              if (!isSent) {
                print('Gelen mesaj profil fotoğrafı: $profileUrl');
              }

              return ChatMessage(
                text: m['icerik'] ?? '',
                isSent: isSent,
                time: time,
                profileImageUrl: profileUrl,
                senderName: !isSent ? m['gonderen_adi'] : null,
              );
            }).toList(),
          );
        });

        // Scroll to bottom after a small delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    } catch (e) {
      print('Mesaj yükleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    // Scroll to bottom (will be used after message is added)
    void _scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    // Eğer sohbetId varsa API'ye gönder
    if (widget.sohbetId != null) {
      final storage = StorageService();
      final currentIdStr = await storage.getUserId();
      if (currentIdStr != null) {
        final res = await ApiService.instance.sendMessage(
          sohbetId: widget.sohbetId.toString(),
          gonderenId: currentIdStr,
          icerik: message,
        );

        if (res['success']) {
          // Sunucudan dönen veriyi kullanabiliriz
          final m = res['data'];
          DateTime time;
          try {
            time = DateTime.parse(m['gonderme_zamani']);
          } catch (_) {
            time = DateTime.now();
          }

          setState(() {
            // Gelen mesajı göster
            _messages.add(
              ChatMessage(
                text: m['icerik'] ?? message,
                isSent: true,
                time: time,
                profileImageUrl:
                    null, // Kendi mesajımız için profil fotoğrafı yok
                senderName: null,
              ),
            );
          });

          _scrollToBottom();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mesajınız ${widget.receiverName} kişisine gönderildi',
              ),
              backgroundColor: _mainGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Hata göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Mesaj gönderilemedi')),
          );
        }
      }
    } else {
      // Sohbet yoksa mesaj sunucuya kaydolmaz — kullanıcıyı bilgilendir
      setState(() {
        _messages.add(
          ChatMessage(
            text: message,
            isSent: true,
            time: DateTime.now(),
            profileImageUrl: null,
            senderName: null,
          ),
        );
      });

      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not: Sohbet oluşturulmadığı için mesaj yerel olarak gösterildi; lütfen ilan üzerinden sohbet açın',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: message.isSent
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Profil fotoğrafı (sadece gelen mesajlar için)
            if (!message.isSent) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    message.profileImageUrl != null &&
                        message.profileImageUrl!.isNotEmpty
                    ? NetworkImage(message.profileImageUrl!)
                    : null,
                onBackgroundImageError: message.profileImageUrl != null
                    ? (exception, stackTrace) {
                        print(
                          'Profil fotoğrafı yükleme hatası: ${message.profileImageUrl}',
                        );
                        print('Hata: $exception');
                      }
                    : null,
                child:
                    message.profileImageUrl == null ||
                        message.profileImageUrl!.isEmpty
                    ? Text(
                        message.senderName?[0].toUpperCase() ?? 'K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],

            // Mesaj balonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isSent ? _mainGreen : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: message.isSent
                      ? const Radius.circular(18)
                      : const Radius.circular(0),
                  bottomRight: message.isSent
                      ? const Radius.circular(0)
                      : const Radius.circular(18),
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isSent ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: message.isSent ? Colors.white70 : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: _mainGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: widget.profileImageUrl != null
                  ? NetworkImage(widget.profileImageUrl!)
                  : null,
              child: widget.profileImageUrl == null
                  ? Text(
                      widget.receiverName[0].toUpperCase(),
                      style: TextStyle(
                        color: _mainGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'İlan Sahibi',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz mesaj yok',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk mesajı gönderin!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Mesaj yazın...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _mainGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isSent;
  final DateTime time;
  final String? profileImageUrl;
  final String? senderName;

  ChatMessage({
    required this.text,
    required this.isSent,
    required this.time,
    this.profileImageUrl,
    this.senderName,
  });
}
