import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- MODELLER ---
class UpcomingMatch {
  final String date;
  final String? details;

  UpcomingMatch({
    required this.date,
    this.details,
  });
}

class Duyuru {
  final String baslik;
  final String metin;
  final String resimUrl;

  Duyuru({required this.baslik, required this.metin, required this.resimUrl});

  factory Duyuru.fromJson(Map<String, dynamic> json) {
    return Duyuru(
      baslik: json['baslik'] ?? "Duyuru",
      metin: json['metin'] ?? '',
      resimUrl: json['resim_url'] ?? '',
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

  // Verileri çeken fonksiyon
  Future<List<Duyuru>> fetchDuyurular() async {
    // NOT: Android Emülatör kullanıyorsan 'localhost' yerine '10.0.2.2' yazman gerekebilir.
    final url = Uri.parse('http://localhost:3001/api/duyurular'); 

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Duyuru.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }

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
                        // --- ÜST KISIM ---
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
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.message_outlined, color: Colors.black87, size: 24),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text("Rüya Halısaha", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              const Text("Rüya gibi futbol.", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),

                        // --- SLIDER ---
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(height: 50, color: mainGreen),
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
                                        color: Colors.grey[300],
                                      ),
                                      child: Center(child: Text("Slider Resim $index")),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // --- YAKLAŞAN MAÇ ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Yaklaşan Maçın", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: mainGreen, width: 2),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("14 Kasım 16:00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Icon(Icons.sports_soccer, size: 50, color: Color(0xFF263238)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- DUYURULAR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text("Duyurular", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          
                          SizedBox(
                            height: 220, 
                            child: FutureBuilder<List<Duyuru>>(
                              future: fetchDuyurular(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Text("Bağlantı Hatası"));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text("Henüz duyuru yok."));
                                }

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    var duyuru = snapshot.data![index];
                                    return Container(
                                      width: 200,
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: mainGreen, width: 2),
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
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                                              child: duyuru.resimUrl.isNotEmpty
                                                  ? Image.network(
                                                      duyuru.resimUrl,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.grey[200],
                                                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(Icons.campaign, size: 40, color: Colors.green),
                                                    ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    duyuru.baslik,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    duyuru.metin,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 12),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 30), label: 'Anasayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 30), label: 'İlanlar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined, size: 30), label: 'Randevu Ekle'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 30), label: 'Profil'),
        ],
      ),
    );
  }
}