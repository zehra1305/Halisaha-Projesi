import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env paketi eklendi
import 'pagesRandevu/randevu_page.dart';

// main() fonksiyonu artık asenkron (async) olmalı
Future<void> main() async {
  // Widget'ların bağlanmasını sağlar ve .env yüklemesinden önce gereklidir.
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle (Dosya adının ".env" olduğundan emin olun)
  await dotenv.load(fileName: ".env");

  // Uygulamanın çalışmasını başlatır.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Burası hala aynı kalıyor
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki debug etiketi kalkar
      title: 'Randevu Uygulaması',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(
          primary: const Color(0xFF2FB335),
        ),
      ),
      // Uygulamanın ana sayfasını (başlangıç sayfasını) RandevuPage olarak ayarlar.
      home: const RandevuPage(),
    );
  }
}