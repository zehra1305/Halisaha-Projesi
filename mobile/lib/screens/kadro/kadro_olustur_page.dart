import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../models/takim_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class KadroOlusturPage extends StatefulWidget {
  const KadroOlusturPage({super.key});

  @override
  State<KadroOlusturPage> createState() => _KadroOlusturPageState();
}

class _KadroOlusturPageState extends State<KadroOlusturPage> {
  static const Color mainGreen = Color(0xFF2FB335);

  SahaFormati _secilenFormat = SahaFormati.yediyeYedi;
  String _takimAAdi = 'Takım A';
  String _takimBAdi = 'Takım B';
  Color _takimARenk = Colors.red;
  Color _takimBRenk = Colors.blue;

  List<Oyuncu> _takimAOyunculari = [];
  List<Oyuncu> _takimBOyunculari = [];
  List<Oyuncu> _bekleyenOyuncular = [];

  @override
  void initState() {
    super.initState();
    _yukleTakimBilgileri();
  }

  int get _takimBasinaOyuncu =>
      _secilenFormat == SahaFormati.yediyeYedi ? 7 : 8;

  Future<void> _yukleTakimBilgileri() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _takimAAdi = prefs.getString('takimAAdi') ?? 'Takım A';
      _takimBAdi = prefs.getString('takimBAdi') ?? 'Takım B';
      _takimARenk = Color(prefs.getInt('takimARenk') ?? Colors.red.value);
      _takimBRenk = Color(prefs.getInt('takimBRenk') ?? Colors.blue.value);
      final formatIndex = prefs.getInt('secilenFormat') ?? 0;
      _secilenFormat = SahaFormati.values[formatIndex];
      _oyunculariOlustur();
    });
  }

  Future<void> _kaydetTakimBilgileri() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('takimAAdi', _takimAAdi);
    await prefs.setString('takimBAdi', _takimBAdi);
    await prefs.setInt('takimARenk', _takimARenk.value);
    await prefs.setInt('takimBRenk', _takimBRenk.value);
    await prefs.setInt('secilenFormat', _secilenFormat.index);
  }

  Future<void> _kadroKaydet() async {
    final controller = TextEditingController();

    final kadroAdi = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kadro Kaydet'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Kadro Adı',
            hintText: 'Örn: Pazar Maçı, Dostluk Maçı',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final ad = controller.text.trim();
              if (ad.isNotEmpty) {
                Navigator.pop(context, ad);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: mainGreen),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (kadroAdi == null || kadroAdi.isEmpty) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final kullaniciId = authProvider.user?.id;

      if (kullaniciId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lütfen giriş yapın')));
        return;
      }

      // String ID'yi integer'a çevir
      final kullaniciIdInt = int.tryParse(kullaniciId);
      if (kullaniciIdInt == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Geçersiz kullanıcı ID')));
        return;
      }

      final takimAOyunculariJson = _takimAOyunculari
          .map(
            (o) => {
              'id': o.id,
              'isim': o.isim,
              'numarasi': o.numarasi,
              'formaRengi':
                  '#${o.formaRengi?.value.toRadixString(16).padLeft(8, '0').substring(2) ?? 'FF0000'}',
            },
          )
          .toList();

      final takimBOyunculariJson = _takimBOyunculari
          .map(
            (o) => {
              'id': o.id,
              'isim': o.isim,
              'numarasi': o.numarasi,
              'formaRengi':
                  '#${o.formaRengi?.value.toRadixString(16).padLeft(8, '0').substring(2) ?? '0000FF'}',
            },
          )
          .toList();

      final response = await ApiService.post('/kadrolar', {
        'kullanici_id': kullaniciIdInt,
        'kadro_adi': kadroAdi,
        'format': _secilenFormat == SahaFormati.yediyeYedi
            ? 'yediyeYedi'
            : 'sekizeSekiz',
        'takim_a_adi': _takimAAdi,
        'takim_b_adi': _takimBAdi,
        'takim_a_renk':
            '#${_takimARenk.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        'takim_b_renk':
            '#${_takimBRenk.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        'takim_a_oyunculari': takimAOyunculariJson,
        'takim_b_oyunculari': takimBOyunculariJson,
      });

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kadro başarıyla kaydedildi!'),
            backgroundColor: mainGreen,
          ),
        );
        Navigator.pop(context, true); // Listeyi yenilemek için true döndür
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  void _oyunculariOlustur() {
    _takimAOyunculari.clear();
    _takimBOyunculari.clear();
    _bekleyenOyuncular.clear();

    final toplamOyuncu = _takimBasinaOyuncu * 2;
    for (int i = 1; i <= toplamOyuncu; i++) {
      if (i <= _takimBasinaOyuncu) {
        _takimAOyunculari.add(
          Oyuncu(
            id: '$i',
            isim: 'Oyuncu $i',
            numarasi: i,
            formaRengi: _takimARenk,
          ),
        );
      } else {
        _takimBOyunculari.add(
          Oyuncu(
            id: '$i',
            isim: 'Oyuncu $i',
            numarasi: i,
            formaRengi: _takimBRenk,
          ),
        );
      }
    }
    setState(() {});
  }

  void _oyunculariKaristir() {
    setState(() {
      final tumOyuncular = [
        ..._takimAOyunculari,
        ..._takimBOyunculari,
        ..._bekleyenOyuncular,
      ];
      tumOyuncular.shuffle(Random());

      _takimAOyunculari.clear();
      _takimBOyunculari.clear();
      _bekleyenOyuncular.clear();

      for (int i = 0; i < tumOyuncular.length; i++) {
        final oyuncu = tumOyuncular[i];
        if (i < _takimBasinaOyuncu) {
          _takimAOyunculari.add(oyuncu.copyWith(formaRengi: _takimARenk));
        } else if (i < _takimBasinaOyuncu * 2) {
          _takimBOyunculari.add(oyuncu.copyWith(formaRengi: _takimBRenk));
        } else {
          _bekleyenOyuncular.add(oyuncu);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Oyuncular karıştırıldı!'),
        backgroundColor: mainGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _takimlariDegistir() {
    setState(() {
      final temp = _takimAOyunculari;
      _takimAOyunculari = _takimBOyunculari
          .map((o) => o.copyWith(formaRengi: _takimARenk))
          .toList();
      _takimBOyunculari = temp
          .map((o) => o.copyWith(formaRengi: _takimBRenk))
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Takımlar değiştirildi!'),
        backgroundColor: mainGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _oyuncuIsmiDuzenle(Oyuncu oyuncu) {
    final controller = TextEditingController(text: oyuncu.isim);
    Color secilenRenk = oyuncu.formaRengi ?? Colors.grey;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Oyuncu Bilgileri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Renk Seçin:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.yellow,
                      Colors.pink,
                      Colors.teal,
                    ].map((renk) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            secilenRenk = renk;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: renk,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: secilenRenk == renk
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: secilenRenk == renk
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final yeniIsim = controller.text.trim();
                  if (yeniIsim.isNotEmpty) {
                    _guncelleOyuncu(oyuncu.id, yeniIsim, secilenRenk);
                  }
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainGreen),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _guncelleOyuncu(String oyuncuId, String yeniIsim, Color yeniRenk) {
    for (var i = 0; i < _takimAOyunculari.length; i++) {
      if (_takimAOyunculari[i].id == oyuncuId) {
        _takimAOyunculari[i] = _takimAOyunculari[i].copyWith(
          isim: yeniIsim,
          formaRengi: yeniRenk,
        );
        return;
      }
    }
    for (var i = 0; i < _takimBOyunculari.length; i++) {
      if (_takimBOyunculari[i].id == oyuncuId) {
        _takimBOyunculari[i] = _takimBOyunculari[i].copyWith(
          isim: yeniIsim,
          formaRengi: yeniRenk,
        );
        return;
      }
    }
    for (var i = 0; i < _bekleyenOyuncular.length; i++) {
      if (_bekleyenOyuncular[i].id == oyuncuId) {
        _bekleyenOyuncular[i] = _bekleyenOyuncular[i].copyWith(
          isim: yeniIsim,
          formaRengi: yeniRenk,
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kadro Oluştur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _kadroKaydet,
            tooltip: 'Kadroyu Kaydet',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildSahaVeOyuncular()),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFormatButton('7v7', SahaFormati.yediyeYedi),
          const SizedBox(width: 12),
          _buildFormatButton('8v8', SahaFormati.sekizeSekiz),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setDialogState) => AlertDialog(
                      title: const Text('Forma Renkleri'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await _showTakimDuzenleDialog(
                                _takimAAdi,
                                _takimARenk,
                              );
                              if (result != null) {
                                setState(() {
                                  _takimAAdi = result['ad'];
                                  _takimARenk = result['renk'];
                                  for (
                                    var i = 0;
                                    i < _takimAOyunculari.length;
                                    i++
                                  ) {
                                    _takimAOyunculari[i] = _takimAOyunculari[i]
                                        .copyWith(formaRengi: result['renk']);
                                  }
                                  _kaydetTakimBilgileri();
                                });
                                setDialogState(() {});
                              }
                            },
                            child: _buildTakimRenkItemDisplay(
                              _takimAAdi,
                              _takimARenk,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              final result = await _showTakimDuzenleDialog(
                                _takimBAdi,
                                _takimBRenk,
                              );
                              if (result != null) {
                                setState(() {
                                  _takimBAdi = result['ad'];
                                  _takimBRenk = result['renk'];
                                  for (
                                    var i = 0;
                                    i < _takimBOyunculari.length;
                                    i++
                                  ) {
                                    _takimBOyunculari[i] = _takimBOyunculari[i]
                                        .copyWith(formaRengi: result['renk']);
                                  }
                                  _kaydetTakimBilgileri();
                                });
                                setDialogState(() {});
                              }
                            },
                            child: _buildTakimRenkItemDisplay(
                              _takimBAdi,
                              _takimBRenk,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Formalar:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFormaExample(_takimARenk, 'Ev'),
                      const SizedBox(width: 16),
                      _buildFormaExample(_takimBRenk, 'Dep'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(Icons.shuffle, 'Random', _oyunculariKaristir),
          const SizedBox(width: 12),
          _buildActionButton(Icons.swap_horiz, 'Değiştir', _takimlariDegistir),
          const SizedBox(width: 12),
          _buildActionButton(Icons.refresh, 'Sıfırla', _oyunculariOlustur),
        ],
      ),
    );
  }

  Widget _buildFormaExample(Color renk, String label) {
    return SizedBox(
      width: 45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: renk,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildFormatButton(String text, SahaFormati format) {
    final isSelected = _secilenFormat == format;
    return GestureDetector(
      onTap: () {
        setState(() {
          _secilenFormat = format;
          _oyunculariOlustur();
        });
        _kaydetTakimBilgileri();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? mainGreen : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? mainGreen : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTakimRenkSecimi() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTakimRenkItem(
              _takimAAdi,
              _takimARenk,
              (renk) => setState(() => _takimARenk = renk),
              (ad) => setState(() => _takimAAdi = ad),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTakimRenkItem(
              _takimBAdi,
              _takimBRenk,
              (renk) => setState(() => _takimBRenk = renk),
              (ad) => setState(() => _takimBAdi = ad),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakimRenkItem(
    String takimAdi,
    Color renk,
    Function(Color) onRenkSecildi,
    Function(String) onAdDegisti,
  ) {
    return GestureDetector(
      onTap: () =>
          _showTakimDuzenle(takimAdi, renk, onRenkSecildi, onAdDegisti),
      child: _buildTakimRenkItemDisplay(takimAdi, renk),
    );
  }

  Widget _buildTakimRenkItemDisplay(String takimAdi, Color renk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: renk, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              takimAdi,
              style: TextStyle(
                color: renk,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showTakimDuzenleDialog(
    String mevcutAd,
    Color mevcutRenk,
  ) async {
    final controller = TextEditingController(text: mevcutAd);
    Color secilenRenk = mevcutRenk;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Takım Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Takım Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Forma Rengi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.purple,
                      Colors.pink,
                      Colors.teal,
                      Colors.indigo,
                      Colors.brown,
                      Colors.cyan,
                      Colors.lime,
                    ].map((renk) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            secilenRenk = renk;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: renk,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: renk == secilenRenk
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: renk == secilenRenk
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final yeniAd = controller.text.trim();
                if (yeniAd.isNotEmpty) {
                  Navigator.pop(context, {'ad': yeniAd, 'renk': secilenRenk});
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainGreen),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTakimDuzenle(
    String mevcutAd,
    Color mevcutRenk,
    Function(Color) onRenkSecildi,
    Function(String) onAdDegisti,
  ) {
    final controller = TextEditingController(text: mevcutAd);
    Color secilenRenk = mevcutRenk;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Takım Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Takım Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Forma Rengi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.purple,
                      Colors.pink,
                      Colors.teal,
                      Colors.indigo,
                      Colors.brown,
                      Colors.cyan,
                      Colors.lime,
                    ].map((renk) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            secilenRenk = renk;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: renk,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: renk == secilenRenk
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: renk == secilenRenk
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final yeniAd = controller.text.trim();
                if (yeniAd.isNotEmpty) {
                  onAdDegisti(yeniAd);
                  onRenkSecildi(secilenRenk);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainGreen),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSahaVeOyuncular() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Dikey Saha
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 2, 12, 20),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Saha çizgileri
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: DikeySahaPainter(),
                    ),
                    // Takım A oyuncuları (Üst)
                    ..._buildTakimOyunculari(
                      _takimAOyunculari,
                      _takimAAdi,
                      _takimARenk,
                      true,
                      constraints,
                    ),
                    // Takım B oyuncuları (Alt)
                    ..._buildTakimOyunculari(
                      _takimBOyunculari,
                      _takimBAdi,
                      _takimBRenk,
                      false,
                      constraints,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTakimOyunculari(
    List<Oyuncu> oyuncular,
    String takimAdi,
    Color renk,
    bool ustTaraf,
    BoxConstraints constraints,
  ) {
    final positions = _getPozisyonlar(ustTaraf, constraints);
    final widgets = <Widget>[];

    // Oyuncuları pozisyonlara yerleştir
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      if (i < oyuncular.length) {
        widgets.add(
          Positioned(
            left: pos.dx - 16,
            top: pos.dy - 22,
            child: _buildDraggableOyuncu(oyuncular[i], renk),
          ),
        );
      } else {
        widgets.add(
          Positioned(
            left: pos.dx - 16,
            top: pos.dy - 16,
            child: _buildBosKonum(renk),
          ),
        );
      }
    }

    return widgets;
  }

  List<Offset> _getPozisyonlar(bool ustTaraf, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final positions = <Offset>[];

    if (_secilenFormat == SahaFormati.yediyeYedi) {
      // 7v7: 1 kaleci, 2 defans, 3 orta saha, 1 forvet
      if (ustTaraf) {
        positions.add(Offset(width / 2, height * 0.06)); // Kaleci
        positions.add(Offset(width * 0.25, height * 0.17)); // Sol defans
        positions.add(Offset(width * 0.75, height * 0.17)); // Sağ defans
        positions.add(Offset(width * 0.2, height * 0.29)); // Sol orta
        positions.add(Offset(width * 0.5, height * 0.29)); // Orta
        positions.add(Offset(width * 0.8, height * 0.29)); // Sağ orta
        positions.add(Offset(width / 2, height * 0.41)); // Forvet
      } else {
        positions.add(Offset(width / 2, height * 0.94)); // Kaleci
        positions.add(Offset(width * 0.25, height * 0.83)); // Sol defans
        positions.add(Offset(width * 0.75, height * 0.83)); // Sağ defans
        positions.add(Offset(width * 0.2, height * 0.71)); // Sol orta
        positions.add(Offset(width * 0.5, height * 0.71)); // Orta
        positions.add(Offset(width * 0.8, height * 0.71)); // Sağ orta
        positions.add(Offset(width / 2, height * 0.59)); // Forvet
      }
    } else {
      // 8v8: 1 kaleci, 3 defans, 3 orta saha, 1 forvet
      if (ustTaraf) {
        positions.add(Offset(width / 2, height * 0.06)); // Kaleci
        positions.add(Offset(width * 0.2, height * 0.16)); // Sol defans
        positions.add(Offset(width * 0.5, height * 0.16)); // Stoper
        positions.add(Offset(width * 0.8, height * 0.16)); // Sağ defans
        positions.add(Offset(width * 0.2, height * 0.29)); // Sol orta
        positions.add(Offset(width * 0.5, height * 0.29)); // Merkez orta
        positions.add(Offset(width * 0.8, height * 0.29)); // Sağ orta
        positions.add(Offset(width / 2, height * 0.42)); // Forvet
      } else {
        positions.add(Offset(width / 2, height * 0.94)); // Kaleci
        positions.add(Offset(width * 0.2, height * 0.84)); // Sol defans
        positions.add(Offset(width * 0.5, height * 0.84)); // Stoper
        positions.add(Offset(width * 0.8, height * 0.84)); // Sağ defans
        positions.add(Offset(width * 0.2, height * 0.71)); // Sol orta
        positions.add(Offset(width * 0.5, height * 0.71)); // Merkez orta
        positions.add(Offset(width * 0.8, height * 0.71)); // Sağ orta
        positions.add(Offset(width / 2, height * 0.58)); // Forvet
      }
    }

    return positions;
  }

  Widget _buildDraggableOyuncu(Oyuncu oyuncu, Color renk) {
    return Draggable<Oyuncu>(
      data: oyuncu,
      feedback: Material(
        color: Colors.transparent,
        child: _buildOyuncuAvatar(oyuncu, renk, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildOyuncuAvatar(oyuncu, renk),
      ),
      onDragStarted: () {
        setState(() {
          // Oyuncuyu listeden çıkar
          _takimAOyunculari.remove(oyuncu);
          _takimBOyunculari.remove(oyuncu);
          _bekleyenOyuncular.remove(oyuncu);
        });
      },
      child: _buildOyuncuAvatar(oyuncu, renk),
    );
  }

  Widget _buildBosKonum(Color renk) {
    return DragTarget<Oyuncu>(
      onAccept: (oyuncu) {
        setState(() {
          final renkliOyuncu = oyuncu.copyWith(formaRengi: renk);
          if (renk == _takimARenk) {
            if (_takimAOyunculari.length < _takimBasinaOyuncu) {
              _takimAOyunculari.add(renkliOyuncu);
            } else {
              _bekleyenOyuncular.add(oyuncu);
            }
          } else if (renk == _takimBRenk) {
            if (_takimBOyunculari.length < _takimBasinaOyuncu) {
              _takimBOyunculari.add(renkliOyuncu);
            } else {
              _bekleyenOyuncular.add(oyuncu);
            }
          } else {
            _bekleyenOyuncular.add(oyuncu);
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isOver
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOyuncuAvatar(
    Oyuncu oyuncu,
    Color renk, {
    bool isDragging = false,
  }) {
    return GestureDetector(
      onTap: () => _oyuncuIsmiDuzenle(oyuncu),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDragging)
            Container(
              constraints: const BoxConstraints(maxWidth: 65),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                oyuncu.isim,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 3),
          CustomPaint(
            size: Size(isDragging ? 36 : 32, isDragging ? 36 : 32),
            painter: TShirtPainter(color: oyuncu.formaRengi ?? renk),
          ),
        ],
      ),
    );
  }
}

// Forma (Tişört) Çizen Painter
class TShirtPainter extends CustomPainter {
  final Color color;

  TShirtPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Tişört şekli
    final w = size.width;
    final h = size.height;

    // Sol omuz
    path.moveTo(w * 0.15, h * 0.15);
    path.lineTo(w * 0.05, h * 0.25);
    path.lineTo(w * 0.15, h * 0.35);

    // Sol yan
    path.lineTo(w * 0.15, h * 0.85);
    path.lineTo(w * 0.85, h * 0.85);

    // Sağ yan
    path.lineTo(w * 0.85, h * 0.35);

    // Sağ omuz
    path.lineTo(w * 0.95, h * 0.25);
    path.lineTo(w * 0.85, h * 0.15);

    // Boyun
    path.lineTo(w * 0.65, h * 0.15);
    path.quadraticBezierTo(w * 0.5, h * 0.05, w * 0.35, h * 0.15);

    path.close();

    // Tişörtü çiz
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Yaka detayı
    final collarPath = Path();
    collarPath.moveTo(w * 0.35, h * 0.15);
    collarPath.quadraticBezierTo(w * 0.5, h * 0.1, w * 0.65, h * 0.15);
    collarPath.quadraticBezierTo(w * 0.5, h * 0.22, w * 0.35, h * 0.15);

    final collarPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(collarPath, collarPaint);
  }

  @override
  bool shouldRepaint(TShirtPainter oldDelegate) => oldDelegate.color != color;
}

// Dikey Saha Çizgilerini Çizen Painter
class DikeySahaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Orta çizgi (Yatay)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Orta daire
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, paint);

    // Üst ceza sahası
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, 0, size.width * 0.5, 80),
      paint,
    );

    // Alt ceza sahası
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, size.height - 80, size.width * 0.5, 80),
      paint,
    );

    // Köşe bayrakları
    final cornerRadius = 10.0;
    // Sol üst
    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
      0,
      1.57,
      false,
      paint,
    );
    // Sağ üst
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerRadius * 2,
        0,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      0,
      1.57,
      false,
      paint,
    );
    // Sol alt
    canvas.drawArc(
      Rect.fromLTWH(
        0,
        size.height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      0,
      1.57,
      false,
      paint,
    );
    // Sağ alt
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerRadius * 2,
        size.height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      0,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
