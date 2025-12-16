import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/randevu_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class RandevuOlusturPage extends StatefulWidget {
  const RandevuOlusturPage({super.key});

  @override
  State<RandevuOlusturPage> createState() => _RandevuOlusturPageState();
}

class _RandevuOlusturPageState extends State<RandevuOlusturPage> {
  final Color _mainGreen = const Color(0xFF2FB335);
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDates = [];
  String? _selectedSaat;
  final TextEditingController _telefonController = TextEditingController(
    text: '05',
  );
  final TextEditingController _aciklamaController = TextEditingController();

  List<Map<String, String>> _musaitSaatler = [];
  List<Map<String, String>> _tumSaatler = [];
  bool _isLoadingSaatler = false;

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
    _initializeTumSaatler();
    _loadMusaitSaatler();
    // Telefon alanına odaklanıldığında cursor'u sona getir
    _telefonController.selection = TextSelection.fromPosition(
      TextPosition(offset: _telefonController.text.length),
    );
  }

  void _generateWeekDates() {
    _weekDates = [];
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _weekDates.add(now.add(Duration(days: i)));
    }
  }

  void _initializeTumSaatler() {
    _tumSaatler = [
      {'baslangic': '12:00', 'bitis': '13:00'},
      {'baslangic': '13:00', 'bitis': '14:00'},
      {'baslangic': '14:00', 'bitis': '15:00'},
      {'baslangic': '15:00', 'bitis': '16:00'},
      {'baslangic': '16:00', 'bitis': '17:00'},
      {'baslangic': '17:00', 'bitis': '18:00'},
      {'baslangic': '18:00', 'bitis': '19:00'},
      {'baslangic': '19:00', 'bitis': '20:00'},
      {'baslangic': '20:00', 'bitis': '21:00'},
      {'baslangic': '21:00', 'bitis': '22:00'},
      {'baslangic': '22:00', 'bitis': '23:00'},
      {'baslangic': '23:00', 'bitis': '00:00'},
    ];
  }

  String _getGunKisaltma(int weekday) {
    const gunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return gunler[weekday - 1];
  }

  @override
  void dispose() {
    _telefonController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _loadMusaitSaatler() async {
    setState(() {
      _isLoadingSaatler = true;
    });

    try {
      final tarih = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final saatler = await ApiService.instance.getMusaitSaatler(tarih);
      setState(() {
        _musaitSaatler = saatler;
        _isLoadingSaatler = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSaatler = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saatler yüklenemedi: $e')));
      }
    }
  }

  bool _isSaatMusait(String baslangic) {
    return _musaitSaatler.any((s) => s['baslangic'] == baslangic);
  }

  Future<void> _selectDateFromCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _mainGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSaat = null;
        // Seçilen tarihi week dates listesinde yoksa ekle
        if (!_weekDates.any(
          (d) =>
              DateFormat('yyyy-MM-dd').format(d) ==
              DateFormat('yyyy-MM-dd').format(picked),
        )) {
          _weekDates = [];
          final now = DateTime.now();
          for (int i = 0; i < 7; i++) {
            _weekDates.add(now.add(Duration(days: i)));
          }
        }
      });
      _loadMusaitSaatler();
    }
  }

  Future<void> _randevuOlustur() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSaat == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir saat seçin')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı bilgisi bulunamadı')),
      );
      return;
    }

    // Saat bilgisini parse et
    final saatParts = _selectedSaat!.split(' - ');
    final saatBaslangic = saatParts[0];
    final saatBitis = saatParts[1];

    final randevu = RandevuModel(
      kullaniciId: authProvider.user!.id,
      tarih: DateFormat('yyyy-MM-dd').format(_selectedDate),
      saatBaslangic: saatBaslangic,
      saatBitis: saatBitis,
      telefon: _telefonController.text,
      aciklama: _aciklamaController.text.isEmpty
          ? null
          : _aciklamaController.text,
    );

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ApiService.instance.createRandevu(randevu);

      if (mounted) {
        // Loading dialog kapat
        Navigator.of(context, rootNavigator: true).pop();

        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevu talebiniz oluşturuldu, onay bekleniyor'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Kısa bir bekleme sonrası sayfayı kapat
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        // Loading dialog kapat
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
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
          'RANDEVU OLUŞTUR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarih Seç (${DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate)})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _selectDateFromCalendar(context),
                      icon: Icon(Icons.calendar_today, color: _mainGreen),
                      tooltip: 'Takvimden seç',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Yatay scroll edilebilir tarih seçimi
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _weekDates.length,
                    itemBuilder: (context, index) {
                      final date = _weekDates[index];
                      final isSelected =
                          DateFormat('yyyy-MM-dd').format(date) ==
                          DateFormat('yyyy-MM-dd').format(_selectedDate);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                            _selectedSaat = null;
                          });
                          _loadMusaitSaatler();
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? _mainGreen : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? _mainGreen
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getGunKisaltma(date.weekday),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Saat Seç',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 15),
                if (_isLoadingSaatler)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: _tumSaatler.length,
                    itemBuilder: (context, index) {
                      final saat = _tumSaatler[index];
                      final saatStr = '${saat['baslangic']} - ${saat['bitis']}';
                      final saatBaslangic = saat['baslangic']!;
                      final isMusait = _isSaatMusait(saatBaslangic);
                      final isSelected = _selectedSaat == saatStr;

                      return GestureDetector(
                        onTap: isMusait
                            ? () {
                                setState(() {
                                  _selectedSaat = saatStr;
                                });
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _mainGreen
                                : isMusait
                                ? Colors.white
                                : Colors.grey[200],
                            border: Border.all(
                              color: isSelected
                                  ? _mainGreen
                                  : isMusait
                                  ? Colors.grey[300]!
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              saatBaslangic,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isMusait
                                    ? Colors.black
                                    : Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 25),
                const Text(
                  'Telefon',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _telefonController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (!value.startsWith('05')) {
                      _telefonController.value = TextEditingValue(
                        text: '05',
                        selection: const TextSelection.collapsed(offset: 2),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: '05XXXXXXXXX',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.phone, color: _mainGreen),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefon numarası zorunludur';
                    }
                    if (value.length != 11) {
                      return 'Telefon numarası 11 rakam olmalıdır';
                    }
                    if (!value.startsWith('05')) {
                      return 'Telefon numarası 05 ile başlamalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  'Açıklama (Opsiyonel)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _aciklamaController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ek bilgiler...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mainGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _randevuOlustur,
                    child: const Text(
                      'RANDEVU OLUŞTUR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
