import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final Color _mainGreen = const Color(0xFF2FB335);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _mesajController = TextEditingController();

  String _selectedKategori = 'Genel';
  bool _isLoading = false;

  final List<String> _kategoriler = [
    'Genel',
    'Hata Bildirimi',
    'Özellik İsteği',
    'İyileştirme Önerisi',
    'Diğer',
  ];

  @override
  void dispose() {
    _baslikController.dispose();
    _mesajController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = StorageService();
      final userId = await storage.getUserId();

      if (userId == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      final result = await ApiService.instance.sendFeedback(
        kullaniciId: userId,
        baslik: _baslikController.text.trim(),
        mesaj: _mesajController.text.trim(),
        kategori: _selectedKategori,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Geri bildiriminiz başarıyla gönderildi. Teşekkür ederiz!',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception(result['message'] ?? 'Gönderim başarısız');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        title: const Text(
          'Geri Bildirim',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bilgi kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _mainGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _mainGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _mainGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Görüş, öneri ve sorunlarınızı bizimle paylaşın. Size daha iyi hizmet verebilmemiz için geri bildirimleriniz önemlidir.',
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kategori seçimi
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedKategori,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: _mainGreen),
                    items: _kategoriler.map((kategori) {
                      return DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKategori = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Başlık
              const Text(
                'Başlık (Opsiyonel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _baslikController,
                decoration: InputDecoration(
                  hintText: 'Kısa bir başlık yazın',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _mainGreen, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 12),

              // Mesaj
              const Text(
                'Mesaj',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mesajController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Detaylı açıklama yazın...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _mainGreen, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen mesajınızı yazın';
                  }
                  if (value.trim().length < 10) {
                    return 'Mesaj en az 10 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Gönder butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Gönder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
