import 'package:flutter/material.dart';
import 'sayfalar/ilanlar.dart';

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