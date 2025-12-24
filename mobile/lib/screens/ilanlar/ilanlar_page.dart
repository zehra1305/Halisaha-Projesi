import 'package:flutter/material.dart';

import '../../models/ilan_model.dart';
import '../../services/api_service.dart';
import 'ilan_detay_page.dart';
import 'ilan_ver.dart';

class IlanlarPage extends StatefulWidget {
  const IlanlarPage({super.key});

  @override
  State<IlanlarPage> createState() => _IlanlarPageState();
}

class _IlanlarPageState extends State<IlanlarPage> {
  final Color _mainGreen = const Color(0xFF2FB335);

  // Backend'den gelecek ilan listesi
  List<IlanModel> ilanListesi = [];

  // Yükleniyor mu?
  bool _isLoading = false;

  // Hata mesajı (varsa)
  String? _errorMessage;

  // ...existing code...

  @override
  void initState() {
    super.initState();
    _fetchIlanlar(); // Sayfa açılınca backend'den ilanları çek
  }

  // BACKEND'DEN LİSTE ÇEKEN FUNKSİYA
  Future<void> _fetchIlanlar() async {
    print('📢 İlanlar yükleniyor...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final liste = await ApiService.instance.fetchIlanlar();
      print('✅ ${liste.length} ilan geldi backend\'den');

      // İlanların tarihlerini kontrol et
      for (var ilan in liste) {
        print('📅 İlan: ${ilan.baslik}');
        print('   Tarih: ${ilan.tarih}, Saat: ${ilan.saat}');
        print('   fullDateTime: ${ilan.fullDateTime}');
        print('   isExpired: ${ilan.isExpired}');
        print('   Şu an: ${DateTime.now()}');
      }

      setState(() {
        // Şimdilik tüm ilanları göster (tarih kontrolü geçici olarak devre dışı)
        ilanListesi = liste; // .where((ilan) => !ilan.isExpired).toList();
        print(
          '✅ ${ilanListesi.length} ilan gösteriliyor (tarih filtresi devre dışı)',
        );
        _isLoading = false;
      });
    } catch (e) {
      print('❌ İlan yükleme hatası: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // İLAN EKLE SAYFASINA GİDİP GELEN MODELİ BACKEND'E POST EDƏN FUNKSİYA
  void _ilanEkleSayfasinaGit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IlanGirisFormPage()),
    );

    if (result != null && result is IlanModel) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Backend'e POST isteği
        final kaydedilenIlan = await ApiService.instance.addIlan(result);

        setState(() {
          ilanListesi.add(kaydedilenIlan);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan başarıyla kaydedildi')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('İlan kaydedilemedi: $e')));
      }
    }
  }

  void _detaySayfasinaGit(IlanModel ilan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IlanDetayPage(ilan: ilan)),
    );

    // Eğer ilan güncellendiyse veya silindiyse listeyi yenile
    if (result == true && mounted) {
      _fetchIlanlar();
    }
  }

  String _formatDateTime(IlanModel ilan) {
    try {
      final dateTime = ilan.fullDateTime;
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return '${ilan.tarih} ${ilan.saat}';
    }
  }

  // ...existing code...

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    if (_isLoading && ilanListesi.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "İLANLAR",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF2FB335),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "İLANLAR",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF2FB335),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _ilanEkleSayfasinaGit,
          backgroundColor: _mainGreen,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'İlan Ver',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Tüm ilanları göster (tarih filtresi kaldırıldı)
    final aktifIlanlar =
        ilanListesi; // .where((ilan) => !ilan.isExpired).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "İLANLAR",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2FB335),
        elevation: 0,
      ),
      body: aktifIlanlar.isEmpty
          ? _buildBosDurum()
          : _buildListeDurumu(aktifIlanlar),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ilanEkleSayfasinaGit,
        backgroundColor: _mainGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'İlan Ver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "İlan bulunmamaktadır",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeDurumu(List<IlanModel> ilanlar) {
    return RefreshIndicator(
      onRefresh: _fetchIlanlar,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: ilanlar.length,
        itemBuilder: (context, index) {
          final ilan = ilanlar[index];
          return GestureDetector(
            onTap: () => _detaySayfasinaGit(ilan),
            child: _buildIlanCard(ilan),
          );
        },
      ),
    );
  }

  Widget _buildIlanCard(IlanModel ilan) {
    final kullaniciAdi = ilan.kullaniciAdi ?? 'U';
    final initial = kullaniciAdi.isNotEmpty
        ? kullaniciAdi[0].toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipOval(
              child:
                  ilan.profilFotografi != null &&
                      ilan.profilFotografi!.isNotEmpty
                  ? Image.network(
                      'https://halisaha-mobil-backend-c4dtaqfnfpdfepg5.germanywestcentral-01.azurewebsites.net${ilan.profilFotografi}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _mainGreen,
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: _mainGreen,
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ilan.baslik.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ilan.konum.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(ilan),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            fontFamily: 'Roboto',
          ),
          children: [
            TextSpan(
              text: value.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
