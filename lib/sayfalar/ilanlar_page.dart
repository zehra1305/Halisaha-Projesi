import 'package:flutter/material.dart';
// MODEL ARTIK SADECE BU YOLLA GELİYOR
import '../models/ilan_model.dart';
import 'ilan_detay_page.dart';
import 'ilan_ver.dart'; // IlanGirisFormPage sınıfının bulunduğu yer

// --- 2. SAYFA: İLANLAR LİSTESİ (LİSTE GÖRÜNÜMÜ) ---
class IlanlarPage extends StatefulWidget {
  const IlanlarPage({super.key});

  @override
  State<IlanlarPage> createState() => _IlanlarPageState();
}

class _IlanlarPageState extends State<IlanlarPage> {
  final Color _mainGreen = const Color(0xFF2FB335);

  // Örnek başlangıç verisi (Test amaçlı, tarihi geleceğe ayarladım)
  List<IlanModel> ilanListesi = [
    // UYGULAMA BOŞ BAŞLASIN İSTİYORSANIZ BU BLOĞU TAMAMEN SİLİN.
    IlanModel(
      adSoyad: "Ahmet Yılmaz",
      baslik: "Bu akşam halısaha 21.00",
      konum: "Rüya Halı Saha - Kayseri",
      tarih: "01/10/${DateTime.now().year + 1}", // Örnek tarihi geleceğe ayarladık
      saat: "21:00",
      kisiSayisi: "2",
      mevki: "Kaleci, Forvet",
      seviye: "Orta",
      ucret: "150 TL",
      aciklama: "Bu akşam için 2 oyuncumuz eksik. Samimi bir ortam.",
      yas: "25",
    )
  ];

  void _ilanEkleSayfasinaGit() async {
    final result = await Navigator.push(
      context,
      // const kaldırıldı.
      MaterialPageRoute(builder: (context) => IlanGirisFormPage()),
    );

    if (result != null && result is IlanModel) {
      setState(() {
        ilanListesi.add(result);
      });
    }
  }

  void _detaySayfasinaGit(IlanModel ilan) {
    Navigator.push(
      context,
      // const kaldırıldı.
      MaterialPageRoute(builder: (context) => IlanDetayPage(ilan: ilan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SÜRESİ DOLAN İLANLARI FİLTRELEME
    final aktifIlanlar = ilanListesi.where((ilan) => !ilan.isExpired).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text("İLANLAR",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22)),
        centerTitle: true,
        elevation: 0,
      ),

      // Filtrelenmiş listeyi kullanıyoruz
      body: aktifIlanlar.isEmpty ? _buildBosDurum() : _buildListeDurumu(aktifIlanlar),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: _mainGreen,
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 40, color: Colors.white),
          onPressed: _ilanEkleSayfasinaGit,
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: _mainGreen,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 40.0),
        child: const Text("İLAN VER",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
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
          Text("İlan bulunmamaktadır",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListeDurumu(List<IlanModel> ilanlar) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: ilanlar.length,
      itemBuilder: (context, index) {
        final ilan = ilanlar[index];
        return GestureDetector(
          onTap: () => _detaySayfasinaGit(ilan),
          child: _buildIlanCard(ilan),
        );
      },
    );
  }

  Widget _buildIlanCard(IlanModel ilan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2)),
                child: const Icon(Icons.person, size: 50, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoRow("AD SOYAD:", ilan.adSoyad),
                _buildInfoRow("YAŞ:", ilan.yas),
                _buildInfoRow("ARANAN KİŞİ SAYISI:", ilan.kisiSayisi),
                _buildInfoRow("MEVKİ:", ilan.mevki),
                const SizedBox(height: 5),
                // Konum ve Saat Satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            ilan.konum.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Saat Bilgisi (Sağ Alt)
                    Text(
                      "SAAT: ${ilan.saat}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.black
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NOT: Bu yardımcı fonksiyonları da widgets klasörüne taşıyınca buradan silmelisiniz.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10, fontFamily: 'Roboto'),
          children: [
            TextSpan(
                text: value.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}