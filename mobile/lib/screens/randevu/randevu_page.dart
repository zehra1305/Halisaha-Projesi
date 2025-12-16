import 'package:flutter/material.dart';
// Model ve Servis dosyalarını import ediyoruz
import 'package:mobile/models/appointment.dart';
// // Servis dosyasını oluşturduğunuzdan emin olun
import 'package:mobile/services/randevu_api_services.dart';
// Renkler
const Color _futsalGreen = Color(0xFF2FB335);
const Color _borderColor = Color(0xFFE0E0E0);
const Color _fullTimeColor = Color(0xFFE0E0E0); // Dolu/geçmiş (Gri)
const Color _pendingColor = Color(0xFFFFC107); // Onay bekleyen (Sarı)

class RandevuPage extends StatefulWidget {
  const RandevuPage({super.key});

  @override
  _RandevuPageState createState() => _RandevuPageState();
}

class _RandevuPageState extends State<RandevuPage> {
  // --- Servis ve Veri Yönetimi ---
  final ApiService _apiService = ApiService(); // Servisi başlat

  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "";
  List<DateTime> _weekDates = [];

  // ARTIK VERİLERİ BURADA TUTUYORUZ (Appointment modelini kullanıyoruz)
  List<Appointment> _appointments = [];
  bool _isLoading = false; // Yükleniyor mu?

  // Sabit Saat Seçenekleri
  final List<String> _timeOptions = [
    "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00",
  ];

  @override
  void initState() {
    super.initState();
    _generateWeekDates(_selectedDate);
    _loadData(); // Sayfa açılınca verileri çek
  }

  // --- Backend'den Veri Çekme ---
  void _loadData() async {
    setState(() => _isLoading = true);

    // Seçili tarihi string formatına çevir (Backend genelde YYYY-MM-DD ister)
    String dateStr = "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}";

    // Servisten veriyi al
    final data = await _apiService.getAppointments(dateStr);

    // Servisten gelen veriyi, bizim sabit saat listemizle birleştiriyoruz
    List<Appointment> processedList = [];
    for (var time in _timeOptions) {
      // Gelen veride bu saat var mı?
      var existing = data.where((element) => element.time == time).firstOrNull;

      if (existing != null) {
        // Varsa onu kullan (Status: PENDING veya APPROVED olabilir)
        processedList.add(existing);
      } else {
        // Yoksa, bu saat boştur (AVAILABLE)
        processedList.add(Appointment(id: "temp_$time", time: time, status: "AVAILABLE"));
      }
    }

    setState(() {
      _appointments = processedList; // Listeyi güncelle
      _isLoading = false;
    });
  }

  // --- Randevu Gönderme ---
  void _submitAppointment() async {
    if (_selectedTime.isEmpty) return;

    setState(() => _isLoading = true);

    // Servise talep gönder
    bool success = await _apiService.bookAppointment(_selectedTime);

    if (success) {
      // Başarılıysa verileri tekrar çek (Böylece PENDING olan sarı yanacak)
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Talep alındı: $_selectedTime. Onay bekleniyor.")),
      );
      setState(() {
        _selectedTime = ""; // Seçimi sıfırla
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hata: Bu saat şu an alınamıyor.")),
      );
    }
  }

  void _generateWeekDates(DateTime initialDate) {
    _weekDates.clear();
    DateTime startOfWeek = initialDate.subtract(Duration(days: initialDate.weekday - 1));
    for (int i = 0; i < 7; i++) {
      _weekDates.add(startOfWeek.add(Duration(days: i)));
    }
  }

  // Geçmiş zaman kontrolü
  bool _isTimeSlotTrulyPast(String time) {
    final now = DateTime.now();

    // Tarih geçmişse hepsi geçmiş
    DateTime selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime todayOnly = DateTime(now.year, now.month, now.day);

    if (selectedDateOnly.isBefore(todayOnly)) return true;
    if (selectedDateOnly.isAfter(todayOnly)) return false;

    // Tarih bugünse saate bak
    final parts = time.split(":");
    final slotHour = int.parse(parts[0]);

    // Basit mantık: Şu an saat 22 ise, 22:00 ve öncesi geçmiştir.
    return slotHour <= now.hour;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _futsalGreen,
            colorScheme: ColorScheme.light(primary: _futsalGreen),
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
      _loadData(); // Tarih değişince verileri yenile
    }
  }

  // Tarih Kartı (Değişmedi)
  Widget _buildDateButton(DateTime date) {
    bool isSelected = date.day == _selectedDate.day &&
        date.month == _selectedDate.month &&
        date.year == _selectedDate.year;

    bool isPastDay = DateTime(date.year, date.month, date.day)
        .isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

    String dayName = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"][date.weekday - 1];

    return GestureDetector(
      onTap: isPastDay
          ? null
          : () {
        setState(() {
          _selectedDate = date;
          _selectedTime = "";
        });
        _loadData(); // Gün değişince veriyi yenile
      },
      child: Container(
        width: 60,
        height: 65,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isPastDay
              ? Colors.grey.shade100
              : isSelected
              ? _futsalGreen
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _futsalGreen : _borderColor,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isPastDay ? Colors.grey.shade400 : (isSelected ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPastDay ? Colors.grey.shade600 : (isSelected ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Saat Butonu (ARTIK APPOINTMENT NESNESİ ALIYOR)
  Widget _buildTimeButton(Appointment appointment, double screenWidth) {
    String time = appointment.time;
    String status = appointment.status; // AVAILABLE, PENDING, APPROVED

    bool isSelected = time == _selectedTime;
    bool isPastTime = _isTimeSlotTrulyPast(time);

    // Durumlara göre mantık
    bool isPending = (status == 'PENDING');
    bool isApproved = (status == 'APPROVED');

    // Tıklanabilir mi?
    bool isDisabled = isPastTime || isPending || isApproved;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isPastTime || isApproved) {
      // Geçmiş veya Onaylanmış (Dolu) -> GRİ
      backgroundColor = _fullTimeColor;
      textColor = Colors.grey.shade700;
      borderColor = _fullTimeColor;
    } else if (isPending) {
      // Onay Bekliyor -> SARI
      backgroundColor = _pendingColor;
      textColor = Colors.black87;
      borderColor = _pendingColor;
    } else if (isSelected) {
      // Seçili -> YEŞİL
      backgroundColor = _futsalGreen;
      textColor = Colors.white;
      borderColor = _futsalGreen;
    } else {
      // Boş -> BEYAZ
      backgroundColor = Colors.white;
      textColor = Colors.black87;
      borderColor = _borderColor;
    }

    double buttonWidth = (screenWidth > 600)
        ? (screenWidth - 40 - 24) / 5.5
        : (screenWidth - 40 - 24) / 3.5;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
        setState(() {
          _selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: buttonWidth,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
            decoration: (isPastTime || isApproved) ? TextDecoration.lineThrough : null,
          ),
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Text("Tarih Seç ($monthYear)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: _futsalGreen),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _weekDates.map((date) => _buildDateButton(date)).toList(),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 12),
              child: Text("Saat Seç", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // SAAT LİSTESİ (Wrap)
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: _futsalGreen))
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              // Artık _timeOptions string listesini değil, _appointments model listesini dönüyoruz
              children: _appointments.map((apt) => _buildTimeButton(apt, screenWidth)).toList(),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 12),
              child: Text("Notunuz (Opsiyonel)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Eklemek istediklerinizi buraya yazabilirsiniz...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
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
            BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: ElevatedButton(
          // Seçim yoksa veya yükleniyorsa basılamaz
          onPressed: (_selectedTime.isEmpty || _isLoading)
              ? null
              : _submitAppointment, // Backend'e gönderme fonksiyonu
          style: ElevatedButton.styleFrom(
            backgroundColor: _futsalGreen,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Randevuyu Onayla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}