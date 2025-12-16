import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/randevu_model.dart';
import '../../services/api_service.dart';
import '../profile/profile_screen.dart';
import '../ilanlar/ilanlar_page.dart';
import '../randevular/randevularim_page.dart';
import '../randevular/randevu_olustur_page.dart';

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
    const Color mainGreen = Color(0xFF3BB54A);

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
  RandevuModel? _yaklasanRandevu;
  bool _isLoadingRandevu = true;

  @override
  void initState() {
    super.initState();
    _loadYaklasanRandevu();
  }

  Future<void> _loadYaklasanRandevu() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      setState(() {
        _isLoadingRandevu = false;
      });
      return;
    }

    try {
      final randevu = await ApiService.instance.getYaklasanRandevu(
        authProvider.user!.id,
      );
      setState(() {
        _yaklasanRandevu = randevu;
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
    ).then((_) => _loadYaklasanRandevu());
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF3BB54A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Header Bölümü
                        Container(
                          color: mainGreen,
                          padding: const EdgeInsets.only(
                            top: 50,
                            left: 16,
                            right: 16,
                            bottom: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const TextField(
                                        decoration: InputDecoration(
                                          hintText: "Ara",
                                          hintStyle: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                            size: 28,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.message_outlined,
                                        color: Colors.black87,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        // Mesajlar sayfası
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Rüya Halısaha",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Rüya gibi futbol.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Slider Bölümü
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(height: 50, color: mainGreen),
                            SizedBox(
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: PageView.builder(
                                  controller: PageController(
                                    viewportFraction: 1.0,
                                  ),
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.grey[300],
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/ruya.jpg',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Yaklaşan Maç Bölümü
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Yaklaşan Maçın",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _randevularimaGit,
                                child: const Text(
                                  'Tümünü Gör',
                                  style: TextStyle(
                                    color: mainGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _isLoadingRandevu
                              ? Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: mainGreen,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _yaklasanRandevu == null
                              ? GestureDetector(
                                  onTap: _randevularimaGit,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: mainGreen,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(
                                          Icons.event_available,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Yaklaşan randevunuz yok',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Yeni randevu oluşturmak için tıklayın',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: mainGreen,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(
                                            Icons.sports_soccer,
                                            size: 50,
                                            color: mainGreen,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(
                                                    _yaklasanRandevu!.tarih,
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${_yaklasanRandevu!.saatBaslangic} - ${_yaklasanRandevu!.saatBitis}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              const Icon(
                                                Icons.stadium,
                                                color: mainGreen,
                                              ),
                                              Text(
                                                _yaklasanRandevu!.saha,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'ONAYLANDI',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),

                    // Duyurular Bölümü
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text(
                              "Duyurular",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: Colors.black,
                              ),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.school_outlined,
                                  text:
                                      "Spor okulu\nkayıtları başladı.\n-Detaylar için tıkla.",
                                  borderColor: mainGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.emoji_events_outlined,
                                  text:
                                      "Turnuva başladı.\n-Detaylar için tıkla.",
                                  borderColor: mainGreen,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color borderColor,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black87),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
