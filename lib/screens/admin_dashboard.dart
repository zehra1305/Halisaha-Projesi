import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider2.dart';
import 'auth/admin_login.dart';

// SAYFA IMPORTLARI
import 'home/takvim_page.dart'; // <--- OLUŞTURDUĞUN TAKVİM SAYFASI BURADA

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Hangi menünün seçili olduğunu tutar (0: Anasayfa, 1: Takvim...)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const Color darkGreen = Color(0xFF2E7D32);

    // MENÜDE GÖSTERİLECEK SAYFALAR LİSTESİ
    final List<Widget> _pages = [
      // 0. İndex: ANASAYFA (Senin eski hoşgeldin ekranın)
      _buildWelcomeScreen(authProvider),
      
      // 1. İndex: TAKVİM SAYFASI (Yeni yaptığımız)
      const TakvimPage(),

      // 2. İndex: MÜŞTERİLER (Henüz yoksa boş sayfa)
      const Center(child: Text("Müşteriler Sayfası (Yapım Aşamasında)")),

      // 3. İndex: MESAJLAR
      const Center(child: Text("Mesajlar Sayfası (Yapım Aşamasında)")),

      // 4. İndex: DUYURULAR (Eğer duyuru kodun varsa buraya o widget'ı koyabilirsin)
      const Center(child: Text("Duyurular Sayfası (Duyuru kodlarını buraya bağlayabilirsin)")),
    ];

    return Scaffold(
      body: Row(
        children: [
          // =================================================
          // SOL MENÜ (SIDEBAR)
          // =================================================
          Expanded(
            flex: 1, // Ekranın 6'da 1'ini kaplasın
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Logo Alanı
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.sports_soccer, color: darkGreen, size: 30),
                        SizedBox(width: 10),
                        Text(
                          "Admin Paneli",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  
                  // Menü Butonları
                  _menuItem(0, "Anasayfa", Icons.dashboard, darkGreen),
                  _menuItem(1, "Takvim", Icons.calendar_today, darkGreen),
                  _menuItem(2, "Müşteriler", Icons.people, darkGreen),
                  _menuItem(3, "Mesajlar", Icons.message, darkGreen),
                  _menuItem(4, "Duyurular", Icons.campaign, darkGreen),

                  const Spacer(),
                  
                  // Çıkış Yap Butonu
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Güvenli Çıkış", style: TextStyle(color: Colors.red)),
                    onTap: () {
                      authProvider.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginWeb()),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // =================================================
          // SAĞ TARAF (İÇERİK ALANI)
          // =================================================
          Expanded(
            flex: 5, // Ekranın 6'da 5'ini kaplasın
            child: Container(
              color: Colors.grey[100], // Hafif gri arka plan
              child: _pages[_selectedIndex], // Seçili sayfayı göster
            ),
          ),
        ],
      ),
    );
  }

  // Menü Elemanı Tasarımı
  Widget _menuItem(int index, String title, IconData icon, Color color) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? color : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? color : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: color.withOpacity(0.1), // Seçili olunca hafif yeşil
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  // Eski Hoşgeldin Ekranın (Widget Haline Getirildi)
  Widget _buildWelcomeScreen(AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard, size: 100, color: Color(0xFF2E7D32)),
          const SizedBox(height: 20),
          Text(
            'Hoşgeldiniz, ${authProvider.user?.name ?? "Admin"}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Yönetim Paneli Başlangıç Ekranı',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Text("👈 Sol menüden 'Takvim' sekmesine tıklayarak randevuları yönetebilirsiniz."),
        ],
      ),
    );
  }
}