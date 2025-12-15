import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/profile/profile_screen.dart';
import 'sayfalar/ilanlar_page.dart'; // IlanlarPage import edildi

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const RuyaHalisahaApp(),
    ),
  );
}

class RuyaHalisahaApp extends StatelessWidget {
  const RuyaHalisahaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rüya Halısaha',
      theme: ThemeData(
        primaryColor: const Color(0xFF388E3C),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF388E3C);

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _buildHome(mainGreen);
        break;
      case 1: // İlanlar butonu için doğru sayfa yönlendirmesi
        body = const IlanlarPage();
        break;
      case 2:
        body = const Center(
          child: Text(
            "Randevu Sayfası (Yakında)",
            style: TextStyle(fontSize: 18),
          ),
        );
        break;
      case 3:
        body = const ProfileScreen(); // PROFİL SAYFASI
        break;
      default:
        body = _buildHome(mainGreen);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
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
            label: 'Randevu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ---------------- ANA SAYFA GÖVDESİ ----------------
  Widget _buildHome(Color mainGreen) {
    return Column(
      children: [
        _buildHeader(mainGreen),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 20),
              _buildSlider(mainGreen),
              const SizedBox(height: 20),
              _buildUpcomingMatch(mainGreen),
              const SizedBox(height: 20),
              _buildAnnouncements(mainGreen),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(Color mainGreen) {
    return Container(
      color: mainGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
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
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.message_outlined,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    // Mesajlar sayfasına yönlendirme eklenebilir.
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Rüya Halısaha",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const Text(
            "Rüya gibi futbol.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ---------------- SLIDER ----------------
  Widget _buildSlider(Color mainGreen) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage("assets/ruya.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- YAKLAŞAN MAÇ ----------------
  Widget _buildUpcomingMatch(Color mainGreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yaklaşan Maçın",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mainGreen, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("14 Kasım 16:00", style: TextStyle(fontSize: 16)),
                Icon(Icons.sports_soccer, size: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- DUYURULAR ----------------
  Widget _buildAnnouncements(Color mainGreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              "Duyurular",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.school_outlined,
                  text: "Spor okulu\nkayıtları başladı.",
                  borderColor: mainGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.emoji_events_outlined,
                  text: "Turnuva başladı.",
                  borderColor: mainGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- İNFO KART ----------------
  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color borderColor,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black87),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
