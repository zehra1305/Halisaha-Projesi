import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/kadro_model.dart';
import '../../services/api_service.dart';
import '../kadro/kadro_olustur_page.dart';
import 'package:intl/intl.dart';

class KadroListPage extends StatefulWidget {
  const KadroListPage({super.key});

  @override
  State<KadroListPage> createState() => _KadroListPageState();
}

class _KadroListPageState extends State<KadroListPage> {
  static const Color mainGreen = Color(0xFF2FB335);
  List<KadroModel> _kadrolar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _yukleKadrolar();
  }

  Future<void> _yukleKadrolar() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final kullaniciId = authProvider.user?.id;

      if (kullaniciId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // String ID'yi integer'a çevir
      final kullaniciIdInt = int.tryParse(kullaniciId);
      if (kullaniciIdInt == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await ApiService.get(
        '/kadrolar?kullanici_id=$kullaniciIdInt',
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _kadrolar = (response['data'] as List)
              .map((json) => KadroModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Kadro yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _silKadro(int kadroId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kadro Sil'),
        content: const Text('Bu kadroyu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await ApiService.delete('/kadrolar/$kadroId');

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kadro silindi'),
            backgroundColor: mainGreen,
          ),
        );
        _yukleKadrolar();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  void _showKadroDetay(KadroModel kadro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          kadro.kadroAdi,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Takım A
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(kadro.takimARenk.substring(1), radix: 16) +
                        0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kadro.takimAAdi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...kadro.takimAOyunculari.map(
                      (oyuncu) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${oyuncu['isim']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Takım B
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(kadro.takimBRenk.substring(1), radix: 16) +
                        0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kadro.takimBAdi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...kadro.takimBOyunculari.map(
                      (oyuncu) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${oyuncu['isim']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kadrolarım'),
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kadrolar.isEmpty
          ? _buildBosListe()
          : RefreshIndicator(
              onRefresh: _yukleKadrolar,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _kadrolar.length,
                itemBuilder: (context, index) {
                  final kadro = _kadrolar[index];
                  return _buildKadroCard(kadro);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KadroOlusturPage()),
          );
          _yukleKadrolar();
        },
        backgroundColor: mainGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Yeni Kadro Oluştur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBosListe() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Henüz kadro oluşturmadınız',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KadroOlusturPage(),
                ),
              );
              _yukleKadrolar();
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Kadro Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKadroCard(KadroModel kadro) {
    final format = kadro.format == 'yediyeYedi' ? '7v7' : '8v8';
    final tarih = kadro.olusturmaTarihi != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(kadro.olusturmaTarihi!)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showKadroDetay(kadro),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: mainGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: mainGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kadro.kadroAdi,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$format • ${kadro.takimAAdi} vs ${kadro.takimBAdi}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (tarih.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tarih,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _silKadro(kadro.id!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
