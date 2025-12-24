import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ilan_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'chat_page.dart';
import 'ilan_ver.dart';

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
  String? _currentUserId;
  late IlanModel currentIlan; // Güncel ilan verisi

  @override
  void initState() {
    super.initState();
    currentIlan = widget.ilan; // Başlangıç verisi
    _loadCurrentUser();
    _loadUserProfile();
  }

  Future<void> _loadCurrentUser() async {
    final storage = StorageService();
    final userId = await storage.getUserId();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadUserProfile() async {
    if (currentIlan.kullaniciId != null) {
      try {
        final response = await ApiService.instance.getProfile(
          currentIlan.kullaniciId.toString(),
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
      final dateTime = currentIlan.fullDateTime;
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return '${currentIlan.tarih} ${currentIlan.saat}';
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

    if (currentId != null &&
        currentIlan.ilanId != null &&
        currentIlan.kullaniciId != null) {
      final res = await ApiService.instance.createSohbet(
        ilanId: currentIlan.ilanId.toString(),
        baslatanId: currentId,
        ilanSahibiId: currentIlan.kullaniciId.toString(),
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
          receiverName: currentIlan.kullaniciAdi ?? 'Kullanıcı',
          receiverId: currentIlan.kullaniciId,
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
            'Mesajınız ${currentIlan.kullaniciAdi} kişisine gönderildi',
          ),
          backgroundColor: _mainGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      // Burada backend'e mesaj gönderme API'si eklenebilir
      // await ApiService.instance.sendMessage(
      //   receiverId: currentIlan.kullaniciId,
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İlanı Sil'),
          content: const Text('Bu ilanı silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteIlan();
              },
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteIlan() async {
    try {
      final response = await ApiService.instance.deleteIlan(
        currentIlan.ilanId.toString(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('İlan başarıyla silindi'),
            backgroundColor: _mainGreen,
          ),
        );
        Navigator.pop(context, true); // Geri dön ve listeyi yenile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'İlan silinemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IlanGirisFormPage(ilan: currentIlan),
      ),
    );

    // Eğer güncelleme başarılı olduysa (true döndü)
    if (result == true && mounted) {
      // Güncel veriyi API'den çek
      final updatedIlan = await ApiService.instance.fetchIlanById(
        currentIlan.ilanId.toString(),
      );

      if (updatedIlan != null) {
        setState(() {
          currentIlan = updatedIlan;
        });
      }

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlan başarıyla güncellendi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      // Listeyi yenilemek için geri dön
      Navigator.pop(context, true);
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
                    // Eski hali: 'http://10.0.2.2:3001$_profileImageUrl'
                    // Yeni hali:
                    ? Image.network(
                        'https://halisaha-mobil-backend-c4dtaqfnfpdfepg5.germanywestcentral-01.azurewebsites.net$_profileImageUrl',
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
                    currentIlan.baslik,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    Icons.location_on,
                    currentIlan.konum,
                    const Color(0xFFE53935), // Kırmızı
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    _formatDateTime(),
                    const Color(0xFF1E88E5), // Mavi
                  ),
                  if (currentIlan.kisiSayisi != null)
                    _buildDetailRow(
                      Icons.people,
                      '${currentIlan.kisiSayisi} Oyuncu Aranıyor',
                      const Color(0xFFFB8C00), // Turuncu
                    ),
                  if (currentIlan.mevki != null &&
                      currentIlan.mevki!.isNotEmpty)
                    _buildDetailRow(
                      Icons.person,
                      currentIlan.mevki!,
                      const Color(0xFF8E24AA), // Mor
                    ),
                  if (currentIlan.seviye != null &&
                      currentIlan.seviye!.isNotEmpty)
                    _buildDetailRow(
                      Icons.star,
                      currentIlan.seviye!,
                      const Color(0xFFFDD835), // Sarı
                    ),
                  if (currentIlan.ucret != null &&
                      currentIlan.ucret!.isNotEmpty)
                    _buildDetailRow(
                      Icons.monetization_on,
                      currentIlan.ucret!,
                      const Color(0xFF43A047), // Yeşil
                    ),

                  const SizedBox(height: 15),
                  if (currentIlan.aciklama.isNotEmpty)
                    Text(
                      currentIlan.aciklama,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  if (currentIlan.aciklama.isNotEmpty)
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
                                  'https://halisaha-mobil-backend-c4dtaqfnfpdfepg5.germanywestcentral-01.azurewebsites.net$_profileImageUrl',
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
                            (currentIlan.kullaniciAdi ?? 'Bilinmeyen Kullanıcı')
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

                  // Mesaj gönder butonu - sadece başkalarının ilanları için
                  if (_currentUserId != null &&
                      currentIlan.kullaniciId != null &&
                      _currentUserId != currentIlan.kullaniciId.toString())
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

                  // Kendi ilanı için bilgi mesajı ve düzenle/sil butonları
                  if (_currentUserId != null &&
                      currentIlan.kullaniciId != null &&
                      _currentUserId == currentIlan.kullaniciId.toString()) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Bu sizin ilanınız",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _showEditDialog,
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              "DÜZENLE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _showDeleteConfirmation,
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              "SİL",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

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
    final kullaniciAdi = currentIlan.kullaniciAdi ?? 'U';
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
    final kullaniciAdi = currentIlan.kullaniciAdi ?? 'U';
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
