import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/support_message.dart';
import 'dart:async';
import 'dart:convert';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final Color _mainGreen = const Color(0xFF2FB335);
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<SupportMessage> _messages = [];
  bool _isLoading = true;
  int? _currentUserId;
  int? _chatId;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeChat();

    // Her 5 saniyede bir yeni mesaj kontrolü
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_chatId != null) {
        _fetchMessages(scrollDown: false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userIdData = prefs.get('user_id') ?? prefs.get('id');

      if (userIdData is String) {
        _currentUserId = int.tryParse(userIdData);
      } else if (userIdData is int) {
        _currentUserId = userIdData;
      }

      print("DEBUG: Mevcut Kullanıcı ID: $_currentUserId");

      if (_currentUserId != null) {
        // Sohbeti başlatmayı dene
        int? chatId = await _apiService.startSupportChat(_currentUserId!);

        if (mounted) {
          if (chatId != null) {
            setState(() {
              _chatId = chatId;
            });
            // Sohbet başladı, mesajları çek
            _fetchMessages(scrollDown: true);
          } else {
            // HATA: Chat ID gelmedi
            print("HATA: Sohbet ID'si alınamadı (null döndü).");
            setState(() {
              _isLoading = false; // Dönmeyi durdur
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sunucu bağlantı hatası: Sohbet başlatılamadı."),
              ),
            );
          }
        }
      } else {
        // HATA: Kullanıcı ID yok
        print("HATA: Kullanıcı ID bulunamadı.");
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print("KRİTİK HATA: _initializeChat içinde hata: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchMessages({bool scrollDown = false}) async {
    if (_chatId == null) return;

    try {
      List<SupportMessage> msgs = await _apiService.getSupportMessages(
        _chatId!,
      );

      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false; // Mesajlar gelince dönmeyi durdur
        });

        if (scrollDown && msgs.isNotEmpty) {
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
      }
    } catch (e) {
      debugPrint("Mesaj çekme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _chatId == null ||
        _currentUserId == null)
      return;

    String text = _messageController.text;
    _messageController.clear();

    bool success = await _apiService.sendSupportMessage(
      _chatId!,
      _currentUserId!,
      text,
    );

    if (success) {
      _fetchMessages(scrollDown: true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Mesaj gönderilemedi!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _mainGreen,
        foregroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halı Saha Yönetimi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Canlı Destek",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchMessages(scrollDown: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // MESAJ LİSTESİ
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _mainGreen))
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Yönetim ile sohbete başla! 👋",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final bool isMe = msg.senderId == _currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? _mainGreen : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                msg.date.length > 16
                                    ? msg.date.substring(11, 16)
                                    : "Şimdi",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // MESAJ YAZMA ALANI (Alt Kısım)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Mesaj yazın...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: _mainGreen,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
