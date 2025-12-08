import 'package:flutter/material.dart';
// ESKİ SATIR: import 'sayfalar/ilanlar.dart';  <-- Artık bu dosya yok
import 'sayfalar/ilanlar_page.dart'; // YENİ YOL: IlanlarPage artık burada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki 'Debug' bandını kaldırır
      title: 'Halı Saha İlanları',
      theme: ThemeData(
        // Tema rengini yeşil yapıyoruz
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2FB335)),
        useMaterial3: true,
      ),
      // Uygulama açıldığında IlanlarPage'i gösteriyoruz
      home: const IlanlarPage(),
    );
  }
}