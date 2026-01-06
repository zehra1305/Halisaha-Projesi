import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

// --- DOSYA YOLLARI ---
import 'providers/auth_provider2.dart'; 
import 'screens/auth/admin_login.dart'; 
import 'services/api_service.dart';
import 'models/customer.dart';
import 'models/message.dart';
import 'models/appointment.dart';
import 'models/duyuru.dart';
import 'models/conversation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Takvim için tarih formatını yükle
  await initializeDateFormatting('tr_TR', null);

  // --- WEB REFRESH KONTROLÜ ---
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Paneli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const AdminDashboard() : const AdminLoginWeb(),
    );
  }
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
  DateTime _selectedDay = DateTime.now(); 

  // --- RANDEVU LİSTESİ ---
  List<Appointment> _selectedDayAppointments = [];
  bool _isLoadingAppointments = false;

  // --- DUYURU DEĞİŞKENLERİ ---
  final TextEditingController _duyuruBaslikController = TextEditingController();
  final TextEditingController _duyuruResimController = TextEditingController();
  final TextEditingController _duyuruMetinController = TextEditingController();
  bool _isSendingDuyuru = false;
  List<Duyuru> _duyurularList = [];
  bool _isLoadingDuyurular = false;

  // --- MÜŞTERİ DEĞİŞKENLERİ ---
  List<Customer> _customersList = [];
  bool _isLoadingCustomers = false;

  // --- MESAJLAŞMA DEĞİŞKENLERİ ---
  List<Conversation> _conversations = []; 
  List<Message> _chatMessages = [];       
  Conversation? _selectedConversation;    
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  final TextEditingController _messageInputController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsForDate(_selectedDay);
    _fetchDuyurular();
    _fetchCustomers();
    _fetchConversations(); 
  }

  // 1. RANDEVULARI ÇEKME
  void _fetchAppointmentsForDate(DateTime date) async {
    setState(() => _isLoadingAppointments = true);
    List<Appointment> apps = await _apiService.getAppointmentsForDate(date);
    if (mounted) {
      setState(() {
        _selectedDayAppointments = apps;
        _isLoadingAppointments = false;
      });
    }
  }

  // 2. MÜŞTERİLERİ ÇEKME
  void _fetchCustomers() async {
    setState(() => _isLoadingCustomers = true);
    List<Customer> customers = await _apiService.getCustomers();
    if (mounted) {
      setState(() {
        _customersList = customers;
        _isLoadingCustomers = false;
      });
    }
  }

  // 3. SOHBETLERİ ÇEKME
  void _fetchConversations() async {
    setState(() => _isLoadingConversations = true);
    List<Conversation> convs = await _apiService.getConversations();
    if (mounted) {
      setState(() {
        _conversations = convs;
        _isLoadingConversations = false;
      });
    }
  }

  // 4. SEÇİLEN SOHBETİN MESAJLARINI ÇEKME
  void _selectConversation(Conversation conversation) async {
    setState(() {
      _selectedConversation = conversation;
      _isLoadingMessages = true;
    });
    
    List<Message> msgs = await _apiService.getChatMessages(conversation.id);
    
    if (mounted) {
      setState(() {
        _chatMessages = msgs;
        _isLoadingMessages = false;
      });
    }
  }

  // 5. MESAJ GÖNDERME (DÜZELTİLDİ ✅)
  void _sendMessage() async {
    if (_messageInputController.text.trim().isEmpty || _selectedConversation == null) return;

    String content = _messageInputController.text;
    _messageInputController.clear(); 

    // Optimistik güncelleme
    setState(() {
      _chatMessages.add(Message(
        id: 0, 
        content: content,
        // DÜZELTME: 'senderName' yerine 'sender'
        sender: "Admin", 
        isAdmin: true,
        // DÜZELTME: 'date' yerine 'createdAt'
        createdAt: DateTime.now().toString(), 
        // Eski zorunlu alanlar
        subject: 'Sohbet', 
        isRead: true, 
      ));
    });

    bool success = await _apiService.sendMessage(_selectedConversation!.id, content);
    
    if (!mounted) return; // DÜZELTME: BuildContext hatasını önler

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mesaj gönderilemedi"), backgroundColor: Colors.red));
    }
  }

  // MÜŞTERİ SİLME
  void _deleteCustomer(int id, String name) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Müşteriyi Sil"),
        content: Text("$name adlı müşteriyi ve tüm randevularını silmek istiyor musun?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sil", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _apiService.deleteCustomer(id);
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Müşteri silindi 🗑️"), backgroundColor: Colors.red));
        _fetchCustomers(); 
      }
    }
  }

  // RANDEVU DURUM GÜNCELLEME
  Future<void> _updateStatus(int id, String status) async {
    bool success = await _apiService.updateAppointmentStatus(id, status);
    
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'onaylandi' ? 'Randevu Onaylandı ✅' : 'Randevu İptal Edildi ❌'),
          backgroundColor: status == 'onaylandi' ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
      _fetchAppointmentsForDate(_selectedDay); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İşlem başarısız!"), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _duyuruBaslikController.dispose();
    _duyuruResimController.dispose();
    _duyuruMetinController.dispose();
    _messageInputController.dispose();
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
      case 0: return _buildCalendarPage();
      case 1: return _buildCustomersPage();
      case 2: return _buildMessagesPage(); 
      case 3: return _buildDuyuruPage();
      default: return _buildCalendarPage();
    }
  }

  // --- MESAJLAR SAYFASI ---
  Widget _buildMessagesPage() {
    return Row(
      children: [
        // SOL TARA: SOHBET LİSTESİ
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Gelen Kutusu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _fetchConversations),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoadingConversations
                    ? const Center(child: CircularProgressIndicator(color: Colors.green))
                    : _conversations.isEmpty
                        ? const Center(child: Text("Sohbet bulunamadı.", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conv = _conversations[index];
                              bool isSelected = _selectedConversation?.id == conv.id;
                              return Container(
                                color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Text(conv.title.isNotEmpty ? conv.title[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text(conv.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    DateFormat('d MMM HH:mm', 'tr_TR').format(DateTime.parse(conv.date)),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  onTap: () => _selectConversation(conv),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 20),

        // SAĞ TARA: MESAJLAŞMA ALANI
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: _selectedConversation == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Görüntülemek için bir sohbet seçin", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Chat Başlığı
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(_selectedConversation!.title[0], style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            Text(_selectedConversation!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Mesaj Listesi
                      Expanded(
                        child: _isLoadingMessages
                            ? const Center(child: CircularProgressIndicator(color: Colors.green))
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _chatMessages.length,
                                itemBuilder: (context, index) {
                                  final msg = _chatMessages[index];
                                  final bool isAdmin = msg.isAdmin; 
                                  
                                  return Align(
                                    alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      constraints: const BoxConstraints(maxWidth: 400),
                                      decoration: BoxDecoration(
                                        color: isAdmin ? const Color(0xFFDCF8C6) : Colors.grey[100], 
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft: isAdmin ? const Radius.circular(12) : const Radius.circular(0),
                                          bottomRight: isAdmin ? const Radius.circular(0) : const Radius.circular(12),
                                        ),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(msg.content, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          // DÜZELTME: date -> createdAt
                                          Text(
                                            DateFormat('HH:mm').format(DateTime.parse(msg.createdAt).toLocal()),
                                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Mesaj Yazma Alanı
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey[50],
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageInputController,
                                decoration: InputDecoration(
                                  hintText: "Mesaj yazın...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 24,
                              child: IconButton(
                                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // --- DİĞER SAYFALAR (TAKVİM, MÜŞTERİ, DUYURU) ---
  // (Aşağıdaki kodlar değişmedi, sadece yapı bütünlüğü için burada)
  
  Widget _buildCalendarPage() {
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
              Expanded(
                flex: 3,
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
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _fetchAppointmentsForDate(selectedDay);
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) => setState(() => _calendarFormat = format),
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.green.withOpacity(0.3), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$formattedDateHeader Detayları",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _isLoadingAppointments
                            ? const Center(child: CircularProgressIndicator(color: Colors.green))
                            : _selectedDayAppointments.isEmpty
                            ? const Center(child: Text("Bu tarih için kayıt yok.", style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                          itemCount: _selectedDayAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildTimeSlotItem(_selectedDayAppointments[index]);
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

  Widget _buildTimeSlotItem(Appointment app) {
    Color statusColor;
    String statusCheck = app.status.toLowerCase().trim();
    bool isPending = statusCheck.contains('bekle');

    if (isPending) {
      statusColor = Colors.orange;
    } else if (statusCheck.contains("onay")) {
      statusColor = Colors.green;
    } else if (statusCheck.contains("iptal")) {
      statusColor = Colors.redAccent;
    } else {
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                app.startTime.length > 5 ? app.startTime.substring(0, 5) : app.startTime,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 10),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  app.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              
              const Spacer(),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, 
                  children: [
                    Text(
                      app.customerName,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    if (app.phone != null && app.phone!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            app.phone!, 
                            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
          
          if (isPending) ...[
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _updateStatus(app.id, 'iptal'),
                  child: const Text("Reddet", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateStatus(app.id, 'onaylandi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text("Onayla"),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCustomersPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Müşteriler", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.green),
              onPressed: _fetchCustomers,
              tooltip: "Listeyi Yenile",
            )
          ],
        ),
        const SizedBox(height: 20),
        
        Expanded(
          child: _isLoadingCustomers
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : _customersList.isEmpty
                  ? const Center(child: Text("Kayıtlı müşteri bulunamadı.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _customersList.length,
                      itemBuilder: (context, index) {
                        final customer = _customersList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.2),
                              child: Text(
                                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "?", 
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                              ),
                            ),
                            title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(customer.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteCustomer(customer.id, customer.name),
                            ),
                          ),
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
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15), 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Yeni Duyuru Ekle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 20),
              
              TextField(
                controller: _duyuruBaslikController,
                decoration: InputDecoration(
                  labelText: "Başlık",
                  prefixIcon: const Icon(Icons.title, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _duyuruResimController,
                decoration: InputDecoration(
                  labelText: "Resim URL",
                  prefixIcon: const Icon(Icons.image, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _duyuruMetinController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Duyuru Metni",
                  prefixIcon: const Icon(Icons.edit, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: 180, 
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: _isSendingDuyuru ? null : _sendDuyuru,
                  icon: _isSendingDuyuru 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, size: 18),
                  label: const Text("Duyuru Ekle", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), 
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        const Text("Mevcut Duyurular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 15),
        
        Expanded(
          child: _isLoadingDuyurular
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : _duyurularList.isEmpty
                  ? const Center(child: Text("Henüz duyuru eklenmemiş.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _duyurularList.length,
                      itemBuilder: (context, index) {
                        final duyuru = _duyurularList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  duyuru.resimUrl ?? "",
                                  width: 80, height: 80, fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 80, height: 80, 
                                    color: Colors.grey[100], 
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey)
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(duyuru.baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 5),
                                    Text(duyuru.metin, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.parse(duyuru.tarih)), 
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)
                                    ),
                                  ],
                                ),
                              ),
                              
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
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

  void _sendDuyuru() async {
    setState(() => _isSendingDuyuru = true); 
    bool success = await _apiService.addDuyuru(_duyuruBaslikController.text, _duyuruResimController.text, _duyuruMetinController.text);
    setState(() => _isSendingDuyuru = false); 

    if (mounted && success) {
      _duyuruBaslikController.clear();
      _duyuruResimController.clear();
      _duyuruMetinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Duyuru Eklendi"), backgroundColor: Colors.green));
      _fetchDuyurular(); 
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Duyuru eklenirken hata oluştu"), backgroundColor: Colors.red));
    }
  }

  void _fetchDuyurular() async {
    setState(() => _isLoadingDuyurular = true);
    List<Duyuru> duyurular = await _apiService.getDuyurular();
    if (mounted) {
      setState(() {
        _duyurularList = duyurular;
        _isLoadingDuyurular = false;
      });
    }
  }

  void _deleteDuyuru(int id) async {
    await _apiService.deleteDuyuru(id);
    _fetchDuyurular();
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.sports_soccer, size: 50, color: Colors.green),
          const SizedBox(height: 40),
          _menuItem(icon: Icons.calendar_month, text: "Takvim", index: 0),
          _menuItem(icon: Icons.people, text: "Müşteriler", index: 1),
          _menuItem(icon: Icons.chat, text: "Mesajlar", index: 2),
          _menuItem(icon: Icons.campaign, text: "Duyurular", index: 3),
          const Spacer(),
          _menuItem(icon: Icons.logout, text: "Güvenli Çıkış", index: -1, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String text, required int index, bool isLogout = false}) {
    bool isActive = _selectedIndex == index;
    return ListTile(
      selected: isActive,
      leading: Icon(icon, color: isActive ? Colors.green : Colors.black54),
      title: Text(text, style: TextStyle(color: isActive ? Colors.green : Colors.black87)),
      onTap: () async {
        if (isLogout) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isLoggedIn');
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminLoginWeb()));
          }
        } else {
          setState(() => _selectedIndex = index);
        }
      },
    );
  }
}