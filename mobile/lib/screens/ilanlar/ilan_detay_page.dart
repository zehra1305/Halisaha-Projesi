import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ilan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'chat_page.dart';

// --- 3. SAYFA: İLAN DETAY (PROFİL GÖRÜNÜMÜ) ---
class IlanDetayPage extends StatefulWidget {
  final IlanModel ilan;
  const IlanDetayPage({super.key, required this.ilan});

  @override
  State<IlanDetayPage> createState() => _IlanDetayPageState();
}

class _IlanDetayPageState extends State<IlanDetayPage> {
  final Color _mainGreen = const Color(0xFF2FB335);
  String? _profileImageUrl;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget.ilan.kullaniciId != null) {
      try {
        final response = await ApiService.instance.getProfile(
          widget.ilan.kullaniciId.toString(),
        );
        if (response['success'] == true && response['data'] != null) {
          final data = response['data']['data'] ?? response['data'];
          setState(() {
            _profileImageUrl = data['profileImage'];
            _isLoadingProfile = false;
          });
        } else {
          setState(() {
            _isLoadingProfile = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } else {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  String _formatDateTime() {
    try {
      final dateTime = widget.ilan.fullDateTime;
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return '${widget.ilan.tarih} ${widget.ilan.saat}';
    }
  }

  Future<void> _launchMapsUrl() async {
    final Uri url = Uri.parse(
      'https://maps.app.goo.gl/VWjyegEHEPM5UVNh7?g_st=ipc',
    );
    if (!await launchUrl(url)) {
      // ignore: avoid_print
      print('Hata: Link açılamadı: $url');
    }
  }

  void _showMessageDialog() async {
    // Sohbet oluştur (veya var olanı döndür) ve sohbetId'yi ChatPage'e geçir
    final storage = StorageService();
    final currentId = await storage.getUserId();
    int? sohbetId;

    if (currentId != null && widget.ilan.ilanId != null && widget.ilan.kullaniciId != null) {
      final res = await ApiService.instance.createSohbet(
        ilanId: widget.ilan.ilanId.toString(),
        baslatanId: currentId,
        ilanSahibiId: widget.ilan.kullaniciId.toString(),
      );

      if (res['success'] && res['data'] != null) {
        final data = res['data'];
        sohbetId = data['sohbet_id'] ?? data['sohbetId'];
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          sohbetId: sohbetId,
          receiverName: widget.ilan.kullaniciAdi ?? 'Kullanıcı',
          receiverId: widget.ilan.kullaniciId,
          profileImageUrl: _profileImageUrl,
        ),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    try {
      // Mesaj gönderme işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mesajınız ${widget.ilan.kullaniciAdi} kişisine gönderildi',
          ),
          backgroundColor: _mainGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      // Burada backend'e mesaj gönderme API'si eklenebilir
      // await ApiService.instance.sendMessage(
      //   receiverId: widget.ilan.kullaniciId,
      //   message: message,
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mesaj gönderilemedi. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profil Resmi
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: ClipOval(
                child: _isLoadingProfile
                    ? const Center(child: CircularProgressIndicator())
                    : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? Image.network(
                        'http://10.0.2.2:3001$_profileImageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitialAvatar();
                        },
                      )
                    : _buildInitialAvatar(),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ilan.baslik,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    Icons.location_on,
                    widget.ilan.konum,
                    const Color(0xFFE53935), // Kırmızı
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    _formatDateTime(),
                    const Color(0xFF1E88E5), // Mavi
                  ),
                  if (widget.ilan.kisiSayisi != null)
                    _buildDetailRow(
                      Icons.people,
                      '${widget.ilan.kisiSayisi} Oyuncu Aranıyor',
                      const Color(0xFFFB8C00), // Turuncu
                    ),
                  if (widget.ilan.mevki != null &&
                      widget.ilan.mevki!.isNotEmpty)
                    _buildDetailRow(
                      Icons.person,
                      widget.ilan.mevki!,
                      const Color(0xFF8E24AA), // Mor
                    ),
                  if (widget.ilan.seviye != null &&
                      widget.ilan.seviye!.isNotEmpty)
                    _buildDetailRow(
                      Icons.star,
                      widget.ilan.seviye!,
                      const Color(0xFFFDD835), // Sarı
                    ),
                  if (widget.ilan.ucret != null &&
                      widget.ilan.ucret!.isNotEmpty)
                    _buildDetailRow(
                      Icons.monetization_on,
                      widget.ilan.ucret!,
                      const Color(0xFF43A047), // Yeşil
                    ),

                  const SizedBox(height: 15),
                  if (widget.ilan.aciklama.isNotEmpty)
                    Text(
                      widget.ilan.aciklama,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  if (widget.ilan.aciklama.isNotEmpty)
                    const SizedBox(height: 20),

                  // Harita / Yol Tarifi Kısmı
                  GestureDetector(
                    onTap: _launchMapsUrl,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/ruya.jpg'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "YOL TARİFİ AL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(),
                        ),
                        child: ClipOval(
                          child:
                              _profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty
                              ? Image.network(
                                  'http://10.0.2.2:3001$_profileImageUrl',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildSmallInitialAvatar();
                                  },
                                )
                              : _buildSmallInitialAvatar(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.ilan.kullaniciAdi ?? 'Bilinmeyen Kullanıcı')
                                .toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "MAÇ DÜZENLEYEN",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mainGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _showMessageDialog,
                      child: const Text(
                        "MESAJ GÖNDER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Büyük profil resmi için baş harf avatarı
  Widget _buildInitialAvatar() {
    final kullaniciAdi = widget.ilan.kullaniciAdi ?? 'U';
    final initial = kullaniciAdi.isNotEmpty
        ? kullaniciAdi[0].toUpperCase()
        : 'U';

    return Container(
      color: _mainGreen,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Küçük profil resmi için baş harf avatarı
  Widget _buildSmallInitialAvatar() {
    final kullaniciAdi = widget.ilan.kullaniciAdi ?? 'U';
    final initial = kullaniciAdi.isNotEmpty
        ? kullaniciAdi[0].toUpperCase()
        : 'U';

    return Container(
      color: _mainGreen,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // IlanDetayPage'e ait yardımcı fonksiyon
  Widget _buildDetailRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
