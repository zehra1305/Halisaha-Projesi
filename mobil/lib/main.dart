import 'package:flutter/material.dart';
import 'pagesRandevu/randevu_page.dart';
void main() {
  // Uygulamanın çalışmasını başlatır.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki debug etiketi kalkar
      title: 'Randevu Uygulaması',
      theme: ThemeData(
        // Tema rengi, RandevuPage'deki _futsalGreen ile tutarlı olması için
        // primaryColor yerine colorScheme kullanılması önerilir.
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(
          primary: const Color(0xFF2FB335),
        ),
      ),
      // Uygulamanın ana sayfasını (başlangıç sayfasını) RandevuPage olarak ayarlar.
      home: const RandevuPage(),
    );
  }
}