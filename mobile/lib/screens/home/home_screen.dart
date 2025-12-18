import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Mevcut importların
import '../../providers/auth_provider.dart';
import '../../models/randevu_model.dart';
import '../../services/api_service.dart';
import '../profile/profile_screen.dart';
import '../ilanlar/ilanlar_page.dart';
import '../randevular/randevularim_page.dart';
import '../randevular/randevu_olustur_page.dart';

// YENİ EKLENEN IMPORTLAR (Dosya yollarının doğru olduğundan emin ol)
import '../../models/duyuru.dart'; 
import '../../services/user_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const IlanlarPage(),
    const RandevuOlusturPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF2FB335);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: mainGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 30),
            label: 'İlanlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: 30),
            label: 'Randevu Oluştur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Mevcut Değişkenler
  List<RandevuModel> _yaklasanRandevular = [];
  bool _isLoadingRandevu = true;
  int _currentImagePage = 0;
  late PageController _imagePageController;

  // YENİ EKLENEN DEĞİŞKENLER (DUYURULAR İÇİN)
  List<Duyuru> _duyurular = [];
  bool _isLoadingDuyuru = true;
  final UserApiService _userApiService = UserApiService();

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController(viewportFraction: 0.92);
    _imagePageController.addListener(() {
      int next = _imagePageController.page!.round();
      if (_currentImagePage != next) {
        setState(() {
          _currentImagePage = next;
        });
      }
    });
    
    // Verileri Yükle
    _loadYaklasanRandevular();
    _loadDuyurular(); // <--- Yeni Fonksiyon Çağrısı
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  // YENİ: Duyuruları Çeken Fonksiyon
  Future<void> _loadDuyurular() async {
    try {
      final duyurular = await _userApiService.getDuyurular();
      if (mounted) {
        setState(() {
          _duyurular = duyurular;
          _isLoadingDuyuru = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDuyuru = false;
        });
      }
      debugPrint("Duyuru çekme hatası: $e");
    }
  }

  Future<void> _loadYaklasanRandevular() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      setState(() {
        _isLoadingRandevu = false;
      });
      return;
    }

    try {
      final randevular = await ApiService.instance.getYaklasanRandevular(
        authProvider.user!.id,
      );
      setState(() {
        _yaklasanRandevular = randevular;
        _isLoadingRandevu = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRandevu = false;
      });
    }
  }

  void _randevularimaGit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RandevularimPage()),
    ).then((_) => _loadYaklasanRandevular());
  }

  Future<void> _konumaGit(String sahaAdi) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://maps.app.goo.gl/VWjyegEHEPM5UVNh7?g_st=ipc',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Harita uygulaması açılamadı'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum açılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRandevuDetay(BuildContext context, RandevuModel randevu) {
    const Color mainGreen = Color(0xFF2FB335);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Randevu Detayları',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildDetayRow(
              icon: Icons.calendar_today,
              label: 'Tarih',
              value: DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime.parse(randevu.tarih)),
              iconColor: mainGreen,
            ),
            const SizedBox(height: 15),
            _buildDetayRow(
              icon: Icons.access_time,
              label: 'Saat',
              value: '${randevu.saatBaslangic} - ${randevu.saatBitis}',
              iconColor: mainGreen,
            ),
            const SizedBox(height: 15),
            _buildDetayRow(
              icon: Icons.stadium,
              label: 'Saha',
              value: randevu.saha,
              iconColor: mainGreen,
            ),
            const SizedBox(height: 15),
            _buildDetayRow(
              icon: Icons.phone,
              label: 'Telefon',
              value: randevu.telefon,
              iconColor: mainGreen,
            ),
            const SizedBox(height: 15),
            if (randevu.aciklama != null && randevu.aciklama!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: mainGreen, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      randevu.aciklama!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'ONAYLANDI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => _konumaGit(randevu.saha),
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: const Text(
                'Konuma Git',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetayRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF2FB335);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dalgalı arka plan
          Positioned.fill(child: CustomPaint(painter: WavePainter())),
          // Ana içerik
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [mainGreen, mainGreen.withOpacity(0.8)],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.only(
                            top: 50,
                            left: 24,
                            right: 24,
                            bottom: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports_soccer,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Rüya Halısaha",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Rüya gibi futbol.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: PageView.builder(
                                    controller: _imagePageController,
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.asset(
                                            'assets/images/ruya.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        // Yaklaşan Maç
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: mainGreen,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Yaklaşan Maçların",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: _randevularimaGit,
                                    style: TextButton.styleFrom(
                                      foregroundColor: mainGreen,
                                    ),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Tümünü Gör',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: mainGreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _isLoadingRandevu
                                  ? Container(
                                      padding: const EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: mainGreen,
                                        ),
                                      ),
                                    )
                                  : _yaklasanRandevular.isEmpty
                                  ? GestureDetector(
                                      onTap: _randevularimaGit,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: mainGreen.withOpacity(
                                                  0.1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.event_available,
                                                size: 40,
                                                color: mainGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Yaklaşan randevunuz yok',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Yeni randevu oluşturmak için tıklayın',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 155,
                                      child: PageView.builder(
                                        controller: PageController(
                                          viewportFraction: 0.92,
                                        ),
                                        itemCount: _yaklasanRandevular.length,
                                        itemBuilder: (context, index) {
                                          final randevu =
                                              _yaklasanRandevular[index];
                                          return GestureDetector(
                                            onTap: () => _showRandevuDetay(
                                              context,
                                              randevu,
                                            ),
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: mainGreen
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: mainGreen
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.sports_soccer,
                                                          size: 28,
                                                          color: mainGreen,
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            DateFormat(
                                                              'dd/MM/yyyy',
                                                            ).format(
                                                              DateTime.parse(
                                                                randevu.tarih,
                                                              ),
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 3,
                                                          ),
                                                          Text(
                                                            '${randevu.saatBaslangic.substring(0, 5)} - ${randevu.saatBitis.substring(0, 5)}',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          LinearGradient(
                                                            colors: [
                                                              mainGreen,
                                                              mainGreen
                                                                  .withOpacity(
                                                                    0.8,
                                                                  ),
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.stadium,
                                                                color:
                                                                    Colors.white,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                  randevu.saha,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: const Text(
                                                            'ONAYLANDI',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===========================================
                        // DUYURULAR (BURASI GÜNCELLENDİ)
                        // ===========================================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: mainGreen,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Duyurular",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Backend'den gelen veri durumuna göre içerik
                              _isLoadingDuyuru
                                  ? const Center(child: CircularProgressIndicator())
                                  : _duyurular.isEmpty
                                      ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                              )
                                            ],
                                          ),
                                          child: const Text(
                                            "Henüz duyuru yok.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true, // İç içe scroll sorunu olmasın diye
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _duyurular.length,
                                          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                                          itemBuilder: (context, index) {
                                            final duyuru = _duyurular[index];
                                            return _buildDuyuruCard(duyuru, mainGreen);
                                          },
                                        ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Alt boşluk
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // YENİ: Dinamik Duyuru Kartı Tasarımı
  Widget _buildDuyuruCard(Duyuru duyuru, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 105, 105, 105).withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim varsa göster
          if (duyuru.resimUrl != null && duyuru.resimUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                duyuru.resimUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.campaign_outlined, size: 20, color: mainColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        duyuru.baslik,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  duyuru.metin,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormat('dd MMM yyyy').format(DateTime.parse(duyuru.tarih)),
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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

// Dalgalı arka plan için custom painter (AYNI KALDI)
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const Color mainGreen = Color(0xFF2FB335);

    final paint1 = Paint()
      ..color = mainGreen
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, 0);
    path1.lineTo(size.width, size.height * 0.5);
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.55,
      size.width * 0.5,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.45,
      0,
      size.height * 0.5,
    );
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = mainGreen.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height * 0.55);
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.55,
    );
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.6,
      0,
      size.height * 0.55,
    );
    path2.close();
    canvas.drawPath(path2, paint2);

    final paint3 = Paint()
      ..color = mainGreen.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, 0);
    path3.lineTo(size.width, 0);
    path3.lineTo(size.width, size.height * 0.6);
    path3.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width * 0.5,
      size.height * 0.6,
    );
    path3.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.55,
      0,
      size.height * 0.6,
    );
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}