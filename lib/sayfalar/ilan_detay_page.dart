import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Harita linki için
import '../models/ilan_model.dart'; // Ilan verisine erişim için
import 'ilan_detay_page.dart';

// NOT: IlanModel sınıfı, models/ilan_model.dart dosyasından import edilmiştir.

// --- 3. SAYFA: İLAN DETAY (PROFİL GÖRÜNÜMÜ) ---
class IlanDetayPage extends StatelessWidget {
  final IlanModel ilan;
  const IlanDetayPage({super.key, required this.ilan});

  final Color _mainGreen = const Color(0xFF2FB335);

  Future<void> _launchMapsUrl() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/VWjyegEHEPM5UVNh7?g_st=ipc');
    if (!await launchUrl(url)) {
      // ignore: avoid_print
      print('Hata: Link açılamadı: $url');
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
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3)),
                  child: const Icon(Icons.person, size: 70, color: Colors.black),
                ),
                Positioned(
                    right: 0, top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 24, color: Colors.black),
                    ))
              ],
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ilan.baslik,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(Icons.location_on, ilan.konum),
                  _buildDetailRow(Icons.calendar_today, "${ilan.tarih} ${ilan.saat}"),
                  _buildDetailRow(Icons.people, "${ilan.kisiSayisi} OYUNCU ARANIYOR"),
                  _buildDetailRow(Icons.person, ilan.mevki.toUpperCase()),
                  _buildDetailRow(Icons.star, ilan.seviye.toUpperCase()),
                  _buildDetailRow(Icons.monetization_on, ilan.ucret),

                  const SizedBox(height: 15),
                  Text(
                    ilan.aciklama,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),

                  // Harita / Yol Tarifi Kısmı
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(Icons.map, size: 40, color: Colors.grey),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed: _launchMapsUrl,
                          child: const Text("YOL TARİFİ AL", style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all()),
                        child: const Icon(Icons.person, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ilan.adSoyad.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text("MAÇ DÜZENLEYEN", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _mainGreen),
                          onPressed: () {},
                          child: const Text("MESAJ GÖNDER", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _mainGreen),
                          onPressed: () {},
                          child: const Text("KATILMA TALEBİ", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // IlanDetayPage'e ait yardımcı fonksiyon
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}