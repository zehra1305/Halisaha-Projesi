import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/randevu_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'randevu_olustur_page.dart';

class RandevularimPage extends StatefulWidget {
  const RandevularimPage({super.key});

  @override
  State<RandevularimPage> createState() => _RandevularimPageState();
}

class _RandevularimPageState extends State<RandevularimPage> {
  final Color _mainGreen = const Color(0xFF2FB335);
  List<RandevuModel> _randevular = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRandevular();
  }

  Future<void> _loadRandevular() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final randevular = await ApiService.instance.getRandevularByUser(
        authProvider.user!.id,
      );
      setState(() {
        _randevular = randevular;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Randevular yüklenemedi: $e')));
      }
    }
  }

  Future<void> _iptalEt(RandevuModel randevu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevu İptali'),
        content: const Text(
          'Bu randevuyu iptal etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HAYIR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('EVET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await ApiService.instance.cancelRandevu(
        randevu.randevuId!,
        authProvider.user!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevu iptal edildi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRandevular();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _yeniRandevuOlustur() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RandevuOlusturPage()),
    );

    if (result == true) {
      _loadRandevular();
    }
  }

  Color _getDurumColor(String durum) {
    switch (durum) {
      case 'onaylandi':
        return Colors.green;
      case 'beklemede':
        return Colors.orange;
      case 'reddedildi':
        return Colors.red;
      case 'iptal':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'RANDEVULARIM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _randevular.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRandevular,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _randevular.length,
                itemBuilder: (context, index) {
                  return _buildRandevuCard(_randevular[index]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _mainGreen,
        onPressed: _yeniRandevuOlustur,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'YENİ RANDEVU',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'Henüz randevunuz yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Yeni randevu oluşturmak için\naşağıdaki butona tıklayın',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildRandevuCard(RandevuModel randevu) {
    final durumColor = _getDurumColor(randevu.durum);
    final canCancel =
        randevu.durum == 'beklemede' || randevu.durum == 'onaylandi';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: durumColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: durumColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          randevu.durumMetni.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCancel)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _iptalEt(randevu),
                  ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              Icons.calendar_today,
              'Tarih',
              DateFormat('dd/MM/yyyy').format(DateTime.parse(randevu.tarih)),
            ),
            _buildInfoRow(
              Icons.access_time,
              'Saat',
              '${randevu.saatBaslangic.substring(0, 5)} - ${randevu.saatBitis.substring(0, 5)}',
            ),
            _buildInfoRow(Icons.sports_soccer, 'Saha', randevu.saha),
            _buildInfoRow(Icons.phone, 'Telefon', randevu.telefon),
            if (randevu.aciklama != null && randevu.aciklama!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  randevu.aciklama!,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _mainGreen),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
