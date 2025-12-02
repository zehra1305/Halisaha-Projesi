import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Tema rengimiz Figma tasarımındaki yeşil renk kodu: 2FB335
const Color _futsalGreen = Color(0xFF2FB335);
const Color _borderColor = Color(0xFFE0E0E0);
const Color _fullTimeColor = Color(0xFFE0E0E0); // Dolu saatler için gri renk

// Kullanıcı seçimlerini yönetmek için StatefulWidget kullanıyoruz
class RandevuPage extends StatefulWidget {
  const RandevuPage({super.key});

  @override
  _RandevuPageState createState() => _RandevuPageState();
}

class _RandevuPageState extends State<RandevuPage> {
  // --- Durum Yönetimi (State Management) ---

  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "";
  List<DateTime> _weekDates = [];

  final List<String> _timeOptions = [
    "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00",
  ];

  // API'den çekilen DOLU SAATLER buraya depolanacak.
  Set<String> _fullTimes = {};

  @override
  void initState() {
    super.initState();
    _generateWeekDates(_selectedDate);
    // SAYFA AÇILIRKEN İLK TARİHİN DOLU SAATLERİNİ ÇEK
    _fetchFullTimesForDate(_selectedDate);
  }

  // Seçilen tarihten başlayarak 7 günlük listeyi oluşturan yardımcı fonksiyon
  void _generateWeekDates(DateTime initialDate) {
    _weekDates.clear();
    DateTime startOfWeek = initialDate.subtract(Duration(days: initialDate.weekday - 1));

    for (int i = 0; i < 7; i++) {
      _weekDates.add(startOfWeek.add(Duration(days: i)));
    }
  }

  // --- YENİ EKLENEN FONKSİYON: DOLU SAATLERİ ÇEKME ---
  Future<void> _fetchFullTimesForDate(DateTime date) async {
    // Tarihi YYYY-MM-DD formatına çevir
    String tarihFormat = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // Örnek bir API adresi, tarihi Query Parametresi olarak gönderiyoruz
    final String url = "http://10.0.2.2:5000/api/reservations/full_times?tarih=$tarihFormat";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // API'den gelen JSON'ı çözümle (Beklenen Format: List<String>)
        final List<dynamic> responseData = jsonDecode(response.body);
        final Set<String> fetchedTimes = responseData.map((e) => e.toString()).toSet();

        setState(() {
          _fullTimes = fetchedTimes; // Dolu saatler setini günceller
          _selectedTime = ""; // Yeni saat çekildiği için seçimi sıfırla
        });
      } else {
        // Hata durumunda boş döndür, UI'ı etkileme
        setState(() {
          _fullTimes = {};
        });
        print("Dolu saatleri çekerken hata: ${response.statusCode}");
      }
    } catch (e) {
      print("Bağlantı Hatası (Dolu Saat): $e");
      // Bağlantı hatasında dolu saatleri temizle
      setState(() {
        _fullTimes = {};
      });
    }
  }

  // Takvim açma ve yeni tarih seçme fonksiyonu
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _futsalGreen,
            colorScheme: ColorScheme.light(primary: _futsalGreen),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _generateWeekDates(picked);
        _selectedTime = "";
      });
      // TARİH DEĞİŞTİĞİNDE: Dolu saatleri yeniden çek
      _fetchFullTimesForDate(picked);
    }
  }

  // --- API Çağrısı YAPAN GÜNCEL FONKSİYON ---
  Future<void> _confirmAppointment() async {
    // 1. BACKEND ADRESİ (POST isteği)
    const String postUrl = "http://10.0.2.2:5000/api/reservations";

    // 2. Gönderilecek Veri Hazırlığı
    String tarihFormat = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    Map<String, dynamic> randevuVerisi = {
      "tarih": tarihFormat,
      "saat": _selectedTime,
      "kullanici_id": "test_kullanici_123"
    };

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Randevu oluşturuluyor...')),
      );

      // 3. İstek Gönderme
      final response = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(randevuVerisi),
      );

      // 4. Sonucu Kontrol Etme
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Color(0xFF2FB335), content: Text('Randevu Başarıyla İletildi! ✅')),
        );

        // 🚨 YENİ EKLENEN KISIM: Randevu onaylandıktan sonra dolu saatleri yeniden çek
        _fetchFullTimesForDate(_selectedDate);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Hata: ${response.body}')),
        );
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Sunucuya bağlanılamadı!')),
      );
    }
  }

  // --- Widget Oluşturucular (Reusable Components) ---

  // Tarih Seçimi Butonu (Haftalık görünüm için)
  Widget _buildDateButton(DateTime date) {
    bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
    String dayName = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'][date.weekday - 1];

    bool isPastDay = date.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));

    return GestureDetector(
      onTap: isPastDay ? null : () {
        setState(() {
          _selectedDate = date;
          _selectedTime = "";
        });
        // TARİH SEÇİLDİĞİNDE: Dolu saatleri yeniden çek
        _fetchFullTimesForDate(date);
      },
      child: Container(
        width: 60,
        height: 65,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isPastDay ? Colors.grey.shade100 : isSelected ? _futsalGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _futsalGreen : _borderColor,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected && !isPastDay ? [
            BoxShadow(
              color: _futsalGreen.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isPastDay ? FontWeight.normal : FontWeight.w500,
                color: isPastDay ? Colors.grey.shade400 : isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPastDay ? Colors.grey.shade600 : isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Saat Seçimi Butonu
  Widget _buildTimeButton(String time, double screenWidth) {
    bool isSelected = time == _selectedTime;

    // 🚨 KRİTİK KONTROL: Bu saat, API'den gelen dolu saatler setinde var mı?
    bool isFull = _fullTimes.contains(time);

    bool isPastTime = false;
    if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day) {
      final selectedHour = int.parse(time.substring(0, 2));
      final selectedDateTime = _selectedDate.copyWith(
        hour: selectedHour, minute: 0, second: 0, millisecond: 0, microsecond: 0,
      );
      if (selectedDateTime.isBefore(DateTime.now())) {
        isPastTime = true;
      }
    }

    // Butonun pasif olması (tıklanamaması)
    bool isDisabled = isFull || isPastTime;


    // Duyarlılık: Saat butonu genişliğini ekranın genişliğine göre hesaplıyoruz.
    double buttonWidth = (screenWidth > 600)
        ? (screenWidth - 40 - 24) / 5.5
        : (screenWidth - 40 - 24) / 3.5;

    return GestureDetector(
      onTap: isDisabled ? null : () { // isFull veya isPastTime ise null (tıklanamaz)
        setState(() {
          _selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        width: buttonWidth,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDisabled // Dolu veya geçmiş ise gri renk
              ? _fullTimeColor
              : isSelected
              ? _futsalGreen
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? _fullTimeColor
                : isSelected
                ? _futsalGreen
                : _borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDisabled
                ? Colors.grey.shade700 // Pasif ve doluysa koyu gri
                : isSelected
                ? Colors.white
                : Colors.black87,
            decoration: isFull ? TextDecoration.lineThrough : null, // Doluysa üstü çizili
            decorationColor: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // Başlık Metni
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String monthYear = "${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          "Randevu Oluştur",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Tarih Seç ($monthYear)"),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: _futsalGreen, size: 24),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _weekDates.map((date) {
                  return _buildDateButton(date);
                }).toList(),
              ),
            ),
            _buildSectionTitle("Saat Seç"),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _timeOptions.map((time) => _buildTimeButton(time, screenWidth)).toList(),
            ),
            _buildSectionTitle("Notunuz (Opsiyonel)"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Eklemek istediklerinizi buraya yazabilirsiniz...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedTime.isNotEmpty ? _confirmAppointment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _futsalGreen,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: _futsalGreen.withOpacity(0.5),
          ),
          child: const Text(
            "Randevuyu Onayla",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}