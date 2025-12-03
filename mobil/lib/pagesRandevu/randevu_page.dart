import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <<< YENİ: dotenv eklendi!

// Tema rengimiz Figma tasarımındaki yeşil renk kodu: 2FB335
const Color _futsalGreen = Color(0xFF2FB335);
const Color _borderColor = Color(0xFFE0E0E0);
// Yeni Renkler
const Color _confirmedColor = Color(0xFF9E9E9E); // Onaylanmış/Dolu Saatler için Koyu Gri
const Color _pendingColor = Color(0xFFFFC107); // Onay Bekleyen Saatler için Sarı

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

  // API'den çekilen SAATLER buraya depolanacak.
  Set<String> _confirmedTimes = {}; // Admin Onayladı (Dolu - Gri)
  Set<String> _pendingTimes = {};   // Admin Onay Bekliyor (Sarı)

  // API Base URL'i .env dosyasından çekiyoruz
  final String? _apiBaseUrl = dotenv.env['API_BASE_URL'];

  @override
  void initState() {
    super.initState();
    // API adresi yüklenemezse kullanıcıyı bilgilendir.
    if (_apiBaseUrl == null) {
      // Hata mesajını terminalde göster.
      print("HATA: API_BASE_URL .env dosyasından yüklenemedi!");
      // Bu durumda API çağrısı yapılmamalıdır.
    }

    _generateWeekDates(_selectedDate);
    // SAYFA AÇILIRKEN İLK TARİHİN DOLU SAATLERİNİ ÇEK
    _fetchReservationStatusesForDate(_selectedDate);
  }

  // Seçilen tarihten başlayarak 7 günlük listeyi oluşturan yardımcı fonksiyon
  void _generateWeekDates(DateTime initialDate) {
    _weekDates.clear();
    // Haftanın başlangıcı (Pazartesi)
    DateTime startOfWeek = initialDate.subtract(Duration(days: initialDate.weekday - 1));

    for (int i = 0; i < 7; i++) {
      _weekDates.add(startOfWeek.add(Duration(days: i)));
    }
  }

  // --- GÜNCELLENEN FONKSİYON: RANDVU DURUMLARINI ÇEKME (GET İSTEĞİ) ---
  Future<void> _fetchReservationStatusesForDate(DateTime date) async {
    if (_apiBaseUrl == null) return; // API adresi yoksa işlemi durdur

    // Tarihi YYYY-MM-DD formatına çevir
    String tarihFormat = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // <<< KRİTİK DÜZELTME 1: Dinamik URL Kullanımı >>>
    final String url = "$_apiBaseUrl/api/reservations/statuses?tarih=$tarihFormat";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final Set<String> fetchedConfirmed = (responseData['confirmed'] as List<dynamic>?)
            ?.map((e) => e.toString()).toSet() ?? {};
        final Set<String> fetchedPending = (responseData['pending'] as List<dynamic>?)
            ?.map((e) => e.toString()).toSet() ?? {};

        setState(() {
          _confirmedTimes = fetchedConfirmed; // Admin Onayladı (Gri)
          _pendingTimes = fetchedPending;     // Admin Onay Bekliyor (Sarı)
          _selectedTime = ""; // Yeni saat çekildiği için seçimi sıfırla
        });
      } else {
        // Hata durumunda setleri temizle
        setState(() {
          _confirmedTimes = {};
          _pendingTimes = {};
        });
        print("Randevu durumlarını çekerken hata: ${response.statusCode}");
      }
    } catch (e) {
      print("Bağlantı Hatası (Randevu Durum): $e");
      // Bağlantı hatasında setleri temizle
      setState(() {
        _confirmedTimes = {};
        _pendingTimes = {};
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
      // TARİH DEĞİŞTİĞİNDE: Randevu durumlarını yeniden çek
      _fetchReservationStatusesForDate(picked);
    }
  }

  // --- API Çağrısı YAPAN GÜNCEL FONKSİYON (POST İSTEĞİ) ---
  Future<void> _confirmAppointment() async {
    if (_apiBaseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Hata: API yapılandırması yüklenemedi.')),
      );
      return;
    }

    // <<< KRİTİK DÜZELTME 2: Dinamik URL Kullanımı >>>
    final String postUrl = "$_apiBaseUrl/api/reservations";

    // 2. Gönderilecek Veri Hazırlığı
    String tarihFormat = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    Map<String, dynamic> randevuVerisi = {
      "tarih": tarihFormat,
      "saat": _selectedTime,
      "kullanici_id": "test_kullanici_123",
      // Yeni randevular ilk başta "pending" (onay bekleyen) olarak sunucuda kaydedilmeli
    };

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Randevu oluşturuluyor ve onay bekleniyor...')),
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
          const SnackBar(backgroundColor: Color(0xFF2FB335), content: Text('Randevu Başarıyla İletildi! ✅ Admin onayı bekleniyor.')),
        );

        // Randevu oluşturulduktan sonra, yeni durumu yansıtmak için listeleri yeniden çek.
        _fetchReservationStatusesForDate(_selectedDate);

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
  // ... (Geri kalan Widget'lar aynı kalıyor)

  // Tarih Seçimi Butonu (Haftalık görünüm için) - DEĞİŞİKLİK YOK
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
        // TARİH SEÇİLDİĞİNDE: Randevu durumlarını yeniden çek
        _fetchReservationStatusesForDate(date);
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

  // --- GÜNCELLENEN WIDGET: Saat Seçimi Butonu ---
  Widget _buildTimeButton(String time, double screenWidth) {
    bool isSelected = time == _selectedTime;

    // Durum Kontrolleri
    bool isConfirmed = _confirmedTimes.contains(time); // Admin Onayladı (Dolu - Gri)
    bool isPending = _pendingTimes.contains(time);     // Admin Onay Bekliyor (Sarı)

    // Geçmiş Saat Kontrolü
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

    // Butonun pasif olması (tıklanamaması): Onaylanmış, Onay Bekleyen veya Geçmiş saat ise pasif.
    bool isDisabled = isConfirmed || isPending || isPastTime;

    // Arka Plan Rengi Belirleme
    Color backgroundColor;
    Color textColor;
    TextDecoration? textDecoration;
    Color? decorationColor;

    if (isDisabled) {
      if (isConfirmed) {
        backgroundColor = _confirmedColor; // Gri (Dolu)
        textColor = Colors.white; // Yazı rengi beyaz yapıldı
        textDecoration = TextDecoration.lineThrough; // Üstü çizili
        decorationColor = Colors.white;
      } else if (isPending) {
        backgroundColor = _pendingColor; // Sarı (Onay Bekleyen)
        textColor = Colors.black87; // Yazı rengi siyah
      } else { // isPastTime (Geçmiş saat)
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
      }
    } else if (isSelected) {
      backgroundColor = _futsalGreen;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }


    // Duyarlılık: Saat butonu genişliğini ekranın genişliğine göre hesaplıyoruz.
    double buttonWidth = (screenWidth > 600)
        ? (screenWidth - 40 - 24) / 5.5
        : (screenWidth - 40 - 24) / 3.5;

    return GestureDetector(
      onTap: isDisabled ? null : () { // isDisabled ise null (tıklanamaz)
        setState(() {
          _selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        width: buttonWidth,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected && !isDisabled
                ? _futsalGreen
                : isDisabled
                ? backgroundColor // Pasifse kenarlık rengini arka plan rengi yap
                : _borderColor,
            width: isSelected && !isDisabled ? 2.0 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
            decoration: textDecoration,
            decorationColor: decorationColor,
          ),
        ),
      ),
    );
  }

  // Başlık Metni - DEĞİŞİKLİK YOK
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
          onPressed: _selectedTime.isNotEmpty && !_confirmedTimes.contains(_selectedTime) && !_pendingTimes.contains(_selectedTime) ? _confirmAppointment : null,
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