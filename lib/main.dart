import 'package:flutter/material.dart';
// Randevu sayfasını doğru yoldan import ediyoruz
import 'sayfalar/randevu_page.dart';

void main() {
  // Uygulama başlarken doğrudan MyApp widget'ını çağırır
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki şeridi kaldırır
      title: 'Halısaha Randevu Uygulaması',
      theme: ThemeData(
        // Uygulamanın ana rengini (yeşil) tanımlıyoruz
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF33CC33)),
        useMaterial3: true,
      ),
      // UYGULAMA AÇILDIĞINDA DOĞRUDAN RANDEVU SAYFASI AÇILACAK
      home: const RandevuPage(),
    );
  }
}