import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/api_service.dart';

class TakvimPage extends StatefulWidget {
  const TakvimPage({super.key});

  @override
  State<TakvimPage> createState() => _TakvimPageState();
}

class _TakvimPageState extends State<TakvimPage> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getAppointments();
      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    final success = await _apiService.updateAppointmentStatus(id, status);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem Başarılı ✅'), backgroundColor: Colors.green),
      );
      _loadAppointments(); // Listeyi güncelle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Randevu Yönetimi", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2FB335),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _loadAppointments,
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _appointments.length,
              itemBuilder: (context, index) => _randevuKarti(_appointments[index]),
            ),
          ),
    );
  }

  Widget _randevuKarti(Appointment app) {
    // Veritabanındaki 'beklemede' değerini yakalamak için trim ve lowercase yapıyoruz
    String durum = app.status.toString().toLowerCase().trim();
    bool bekliyorMu = durum.contains('bekle'); 

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.circle, color: bekliyorMu ? Colors.orange : Colors.green, size: 14),
            title: Text(app.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${app.startTime.length > 5 ? app.startTime.substring(0, 5) : app.startTime} - ${app.status.toUpperCase()}"),
          ),
          // BUTONLAR: Durum 'beklemede' ise kartın altında her zaman görünür olacak
          if (bekliyorMu) 
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(app.id, 'iptal'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Reddet", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(app.id, 'onaylandi'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Onayla", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}