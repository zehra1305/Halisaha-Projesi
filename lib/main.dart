import 'package:flutter/material.dart';


class UpcomingMatch {
  final String date;
  final String? details;

  UpcomingMatch({
    required this.date,
    this.details,
  });
}

void main() {
  runApp(const RuyaHalisahaApp());
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
  final UpcomingMatch _upcomingMatch = UpcomingMatch(
    date: "14 Kasım 16:00",
    details: "Detaylar",
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF388E3C);

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
                        Container(
                          color: mainGreen,
                          padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
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
                                          hintStyle: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                                          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 28),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Mesajlaşma butonu
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

                        // Slider
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              height: 50,
                              color: mainGreen,
                            ),
                            SizedBox(
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: PageView.builder(
                                  controller: PageController(viewportFraction: 1.0),
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                          image: AssetImage("lib/assets/ruya.jpg"),
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


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Yaklaşan Maçın",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: mainGreen, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Backend'den veri gelene kadar boş
                                const SizedBox(),
                                const Icon(
                                  Icons.sports_soccer,
                                  size: 50,
                                  color: Color(0xFF263238),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- 3. GRUP: DUYURULAR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text(
                              "Duyurular",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.school_outlined,
                                  text: "Spor okulu\nkayıtları başladı.\n-Detaylar için tıkla.",
                                  borderColor: mainGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.emoji_events_outlined,
                                  text: "Turnuva başladı.\n-Detaylar için tıkla.",
                                  borderColor: mainGreen,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: mainGreen,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black87,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
            label: 'Randevu Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text, required Color borderColor}) {
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