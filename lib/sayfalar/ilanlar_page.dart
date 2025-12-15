import 'package:flutter/material.dart';

import '../models/ilan_model.dart';
import '../services/api_service.dart'; // <-- BURANI ƏLAVƏ ETDİK
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

  @override
  void initState() {
    super.initState();
    _fetchIlanlar(); // Sayfa açılınca backend'den ilanları çek
  }

  // BACKEND'DEN LİSTE ÇEKEN FUNKSİYA
  Future<void> _fetchIlanlar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final liste = await ApiService.instance.fetchIlanlar();
      setState(() {
        ilanListesi = liste.where((ilan) => !ilan.isExpired).toList();
        _isLoading = false;
      });
    } catch (e) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İlan kaydedilemedi: $e')),
        );
      }
    }
  }

  void _detaySayfasinaGit(IlanModel ilan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IlanDetayPage(ilan: ilan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && ilanListesi.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Center(
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFab(),
        bottomNavigationBar: _buildBottomBar(),
      );
    }

    final aktifIlanlar =
    ilanListesi.where((ilan) => !ilan.isExpired).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: aktifIlanlar.isEmpty
          ? _buildBosDurum()
          : _buildListeDurumu(aktifIlanlar),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _mainGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {},
      ),
      title: const Text(
        "İLANLAR",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildFab() {
    return Container(
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 80,
      color: _mainGreen,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 40.0),
      child: const Text(
        "İLAN VER",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                fontWeight: FontWeight.bold),
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
                  border: Border.all(color: Colors.black, width: 2),
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            ilan.konum.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "SAAT: ${ilan.saat}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black,
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