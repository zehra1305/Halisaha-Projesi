import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Dosya yolların
import 'services/api_service.dart';
import 'models/customer.dart';
import 'models/message.dart';
import 'models/appointment.dart'; // Yeni eklediğimiz model
import 'models/duyuru.dart'; // Duyurular modeli

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminDashboard(),
  ));
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;

  // --- TAKVİM DEĞİŞKENLERİ ---
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // Başlangıçta bugün seçili olsun

  // --- RANDEVU LİSTESİ ---
  List<Appointment> _selectedDayAppointments = [];
  bool _isLoadingAppointments = false;

  // --- DUYURU DEĞİŞKENLERİ ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // --- DUYURULAR LİSTESİ DEĞİŞKENLERİ ---
  final TextEditingController _duyuruBaslikController = TextEditingController();
  final TextEditingController _duyuruResimController = TextEditingController();
  final TextEditingController _duyuruMetinController = TextEditingController();
  bool _isSendingDuyuru = false;
  List<Duyuru> _duyurularList = [];
  bool _isLoadingDuyurular = false;

  @override
  void initState() {
    super.initState();
    // Uygulama açılınca bugünün randevularını çek
    _fetchAppointmentsForDate(_selectedDay);
    // Duyuruları yükle
    _fetchDuyurular();
  }

  // Randevuları API'den çeken fonksiyon
  void _fetchAppointmentsForDate(DateTime date) async {
    setState(() => _isLoadingAppointments = true);

    // Servise git ve veriyi al
    List<Appointment> apps = await _apiService.getAppointmentsForDate(date);

    setState(() {
      _selectedDayAppointments = apps;
      _isLoadingAppointments = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _duyuruBaslikController.dispose();
    _duyuruResimController.dispose();
    _duyuruMetinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0: return _buildCalendarPage(); // GÜNCELLENEN KISIM
      case 1: return _buildCustomersPage();
      case 2: return _buildMessagesPage();
      case 3: return _buildDuyuruPage();
      default: return _buildCalendarPage();
    }
  }

  // --- 1. SAYFA: TAKVİM VE DETAY (RESİMDEKİ GİBİ İKİYE BÖLÜNMÜŞ) ---
  Widget _buildCalendarPage() {
    // Tarihi Türkçe formatında yazdırmak için (Örn: 14 Kasım Cuma)
    String formattedDateHeader = DateFormat('d MMMM EEEE', 'tr_TR').format(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Takvim Detay", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SOL TARAF: TAKVİM ---
              Expanded(
                flex: 3, // Ekranın %60'ı
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    locale: 'tr_TR',
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    // GÜN SEÇİLİNCE ÇALIŞAN KOD
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      // Seçilen günün verilerini çek
                      _fetchAppointmentsForDate(selectedDay);
                    },

                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) => setState(() => _calendarFormat = format),
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,

                    // Görsel Ayarlar
                    headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.green.withOpacity(0.5), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // --- SAĞ TARAF: DETAY LİSTESİ (RESİMDEKİ GİBİ) ---
              Expanded(
                flex: 2, // Ekranın %40'ı
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık (14 Kasım Cuma Detayları)
                      Text(
                        "$formattedDateHeader Detayları",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Liste veya Yükleniyor İkonu
                      Expanded(
                        child: _isLoadingAppointments
                            ? const Center(child: CircularProgressIndicator(color: Colors.green))
                            : _selectedDayAppointments.isEmpty
                            ? const Center(child: Text("Bu tarih için kayıt yok.", style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                          itemCount: _selectedDayAppointments.length,
                          itemBuilder: (context, index) {
                            final app = _selectedDayAppointments[index];
                            return _buildTimeSlotItem(app);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- ZAMAN ÇİZELGESİ SATIR TASARIMI (Timeline Item) ---
  Widget _buildTimeSlotItem(Appointment app) {
    // Duruma göre renk belirleme
    Color statusColor;
    switch (app.status) {
      case "REZERVE": statusColor = Colors.lightBlueAccent; break;
      case "MÜSAİT": statusColor = Colors.green; break;
      case "TAMAMLANDI": statusColor = Colors.grey; break;
      case "İPTAL": statusColor = Colors.redAccent; break;
      case "ONAY BEKLİYOR": statusColor = Colors.amber; break;
      default: statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Saat
          SizedBox(
            width: 50,
            child: Text(
              app.time,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),

          // 2. Çizgi ve Nokta (Timeline Efekti)
          Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: statusColor, // Nokta rengi durum rengiyle aynı olsun
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 40, color: Colors.grey[300]), // Dikey çizgi
            ],
          ),
          const SizedBox(width: 15),

          // 3. Durum Kutusu (Card)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2), // Arkaplan hafif şeffaf
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.5)), // Kenarlık
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Durum Yazısı
                  Text(
                    app.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  // Müşteri İsmi (Varsa)
                  if (app.customerName.isNotEmpty)
                    Text(
                      app.customerName,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DİĞER SAYFALAR (AYNI KALDI) ---
  Widget _buildCustomersPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Müşteriler", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<Customer>>(
            future: _apiService.getCustomers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Müşteri bulunamadı.", style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final customer = snapshot.data![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                customer.email,
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.person, color: Colors.green.withOpacity(0.6)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mesajlar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<Message>>(
            future: _apiService.getMessages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Mesaj bulunamadı.", style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final message = snapshot.data![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: message.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      border: Border.all(color: message.isRead ? Colors.grey[200]! : Colors.blue[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.sender,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: message.isRead ? Colors.black87 : Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    message.subject,
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: message.isRead ? Colors.grey[200] : Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message.isRead ? "Okundu" : "Okunmadı",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: message.isRead ? Colors.grey[700] : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // İçerik
                        Text(
                          message.content,
                          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Tarih
                        Text(
                          message.createdAt,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDuyuruPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Duyuru Yönetimi", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20),

        // --- DUYURU EKLEME FORMU ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Yeni Duyuru Ekle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Başlık
              TextField(
                controller: _duyuruBaslikController,
                decoration: InputDecoration(
                  labelText: "Başlık",
                  hintText: "Duyuru başlığını yazın...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 15),

              // Resim URL
              TextField(
                controller: _duyuruResimController,
                decoration: InputDecoration(
                  labelText: "Resim URL",
                  hintText: "https://example.com/image.jpg",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 15),

              // Duyuru Metni
              TextField(
                controller: _duyuruMetinController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Duyuru Metni",
                  hintText: "Duyuru metnini buraya yazın...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 15),

              // Gönder Butonu
              ElevatedButton.icon(
                onPressed: _isSendingDuyuru ? null : _sendDuyuru,
                icon: _isSendingDuyuru ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : const Icon(Icons.send),
                label: Text(_isSendingDuyuru ? "Gönderiliyor..." : "Duyuru Ekle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- DUYURULAR LİSTESİ ---
        const Text("Mevcut Duyurular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 15),

        Expanded(
          child: _isLoadingDuyurular
              ? const Center(child: CircularProgressIndicator())
              : _duyurularList.isEmpty
                  ? const Center(child: Text("Henüz duyuru eklenmemiş.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _duyurularList.length,
                      itemBuilder: (context, index) {
                        final duyuru = _duyurularList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Resim
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  duyuru.resimUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Metin ve Tarih
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      duyuru.metin,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('d MMM yyyy HH:mm', 'tr_TR').format(duyuru.tarih),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              // Sil Butonu
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDuyuru(duyuru.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // --- DUYURU GÖNDERİMİ ---
  void _sendDuyuru() async {
    if (_duyuruBaslikController.text.isEmpty || _duyuruResimController.text.isEmpty || _duyuruMetinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSendingDuyuru = true);

    bool success = await _apiService.addDuyuru(
      _duyuruBaslikController.text,
      _duyuruResimController.text,
      _duyuruMetinController.text,
    );

    setState(() => _isSendingDuyuru = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duyuru başarıyla eklendi!"), backgroundColor: Colors.green),
      );
      _duyuruBaslikController.clear();
      _duyuruResimController.clear();
      _duyuruMetinController.clear();
      _fetchDuyurular(); // Listeyi güncelle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duyuru eklenirken hata oluştu!"), backgroundColor: Colors.red),
      );
    }
  }

  // --- DUYURULARI YÜKLEME ---
  void _fetchDuyurular() async {
    setState(() => _isLoadingDuyurular = true);

    List<Duyuru> duyurular = await _apiService.getDuyurular();

    setState(() {
      _duyurularList = duyurular;
      _isLoadingDuyurular = false;
    });
  }

  // --- DUYURU SİLME ---
  void _deleteDuyuru(int id) async {
    bool success = await _apiService.deleteDuyuru(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duyuru silindi!"), backgroundColor: Colors.green),
      );
      _fetchDuyurular(); // Listeyi güncelle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duyuru silinirken hata oluştu!"), backgroundColor: Colors.red),
      );
    }
  }

  // --- SIDEBAR (RESİM 1'DEKİ TASARIM) ---
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.menu, size: 30),
          const SizedBox(height: 40),
          _menuItem(icon: Icons.calendar_month, text: "Takvim", index: 0),
          _menuItem(icon: Icons.people_outline, text: "Müşteriler", index: 1),
          _menuItem(icon: Icons.chat_bubble_outline, text: "Mesajlar", index: 2),
          _menuItem(icon: Icons.campaign_outlined, text: "Duyurular", index: 3),
          const Spacer(),
          _menuItem(icon: Icons.logout, text: "Güvenli Çıkış", index: -1, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String text, required int index, bool isLogout = false}) {
    bool isActive = _selectedIndex == index;
    return Container(
      // Sol kenardaki yeşil çizgi efekti
      decoration: isActive ? const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.green, width: 4))
      ) : null,
      child: ListTile(
        tileColor: isActive ? Colors.green.withOpacity(0.1) : null,
        leading: Icon(icon, color: isActive ? Colors.green : (isLogout ? Colors.black : Colors.black54)),
        title: Text(text, style: TextStyle(
            color: isActive ? Colors.green : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
        )),
        onTap: () { if (!isLogout) setState(() => _selectedIndex = index); },
      ),
    );
  }
}