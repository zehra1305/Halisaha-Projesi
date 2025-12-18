import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ilan_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_form_widgets.dart';

// --- 4. SAYFA: İLAN GİRİŞ FORMU ---
class IlanGirisFormPage extends StatefulWidget {
  const IlanGirisFormPage({super.key});

  @override
  State<IlanGirisFormPage> createState() => _IlanGirisFormPageState();
}

class _IlanGirisFormPageState extends State<IlanGirisFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _tarihController = TextEditingController();

  String? _secilenSaat;
  int? _secilenOyuncuSayisi;

  final TextEditingController _sayiController = TextEditingController();
  final TextEditingController _ucretController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _yasController = TextEditingController();

  String? secilenKonum = "Rüya Halı Saha - Kayseri";

  final List<String> saatSecenekleri = List.generate(12, (index) {
    int hour = 12 + index;
    return '${hour.toString().padLeft(2, '0')}:00';
  });

  bool isKaleci = false;
  bool isDefans = false;
  bool isOrtaSaha = false;
  bool isForvet = false;

  String? secilenSeviye;
  final List<String> seviyeler = ['Başlangıç', 'Orta', 'İyi', 'Profesyonel'];

  @override
  void initState() {
    super.initState();
    // Kullanıcının kayıtlı adını yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        _adController.text = authProvider.user!.name;
      }
    });
  }

  // TARİH SEÇİMİ (YYYY-MM-DD formatında kaydedilir - backend için)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        // Backend için YYYY-MM-DD formatı
        _tarihController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel("Ad Soyad"),
              buildInputBox(controller: _adController, readOnly: true),

              buildLabel("Yaş"),
              buildInputBox(
                controller: _yasController,
                isNumber: true,
                maxLength: 2, // İki basamaklı sayı limiti eklendi
              ),

              buildLabel("İlan Başlığı"),
              buildInputBox(controller: _baslikController),

              buildLabel("Konum"),
              Container(
                decoration: BoxDecoration(
                  color: inputGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: secilenKonum,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: const [
                      DropdownMenuItem(
                        value: "Rüya Halı Saha - Kayseri",
                        child: Text("Rüya Halı Saha - Kayseri"),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        secilenKonum = val;
                      });
                    },
                  ),
                ),
              ),

              buildLabel("Tarih ve Saat"),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: buildInputBox(
                      controller: _tarihController,
                      hint: "Tarih Seç",
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    // SAAT DROPDOWN'I
                    child: Container(
                      decoration: BoxDecoration(
                        color: inputGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _secilenSaat,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.access_time,
                              color: Colors.black54,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                            hintText: "Saat",
                          ),
                          isExpanded: true,
                          menuMaxHeight: 250,
                          items: saatSecenekleri.map((String saat) {
                            return DropdownMenuItem<String>(
                              value: saat,
                              child: Text(saat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _secilenSaat = val;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Seçiniz" : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              buildLabel("Aranan Oyuncu Sayısı"),
              Container(
                decoration: BoxDecoration(
                  color: inputGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<int>(
                    value: _secilenOyuncuSayisi,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      hintText: "Seçiniz",
                    ),
                    isExpanded: true,
                    menuMaxHeight: 250,
                    items: List.generate(16, (index) => index + 1)
                        .map(
                          (sayi) => DropdownMenuItem<int>(
                            value: sayi,
                            child: Text(sayi.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _secilenOyuncuSayisi = val;
                      });
                    },
                  ),
                ),
              ),

              buildLabel("Mevki"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildCheckbox(
                    "Kaleci",
                    isKaleci,
                    (v) => setState(() => isKaleci = v!),
                  ),
                  buildCheckbox(
                    "Defans",
                    isDefans,
                    (v) => setState(() => isDefans = v!),
                  ),
                  buildCheckbox(
                    "Orta Saha",
                    isOrtaSaha,
                    (v) => setState(() => isOrtaSaha = v!),
                  ),
                  buildCheckbox(
                    "Forvet",
                    isForvet,
                    (v) => setState(() => isForvet = v!),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel("Seviye"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: inputGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: secilenSeviye,
                              hint: const Text("Seçiniz"),
                              isExpanded: true,
                              items: seviyeler.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => secilenSeviye = val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel("Katılım Ücreti"),
                        buildInputBox(
                          controller: _ucretController,
                          isNumber: true,
                          maxLength: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              buildLabel("Açıklama"),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: inputGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _aciklamaController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Maç hakkında detay yazın",
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      List<String> mevkiler = [];
                      if (isKaleci) mevkiler.add("Kaleci");
                      if (isDefans) mevkiler.add("Defans");
                      if (isOrtaSaha) mevkiler.add("Orta Saha");
                      if (isForvet) mevkiler.add("Forvet");

                      // Tarih/Saat kontrolü
                      if (_tarihController.text.isEmpty ||
                          _secilenSaat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lütfen Tarih ve Saati seçin."),
                          ),
                        );
                        return;
                      }

                      // Mevki kontrolü
                      if (mevkiler.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lütfen en az bir mevki seçin."),
                          ),
                        );
                        return;
                      }

                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final userId = authProvider.user?.id;

                      final yeniIlan = IlanModel(
                        baslik: _baslikController.text,
                        aciklama: _aciklamaController.text,
                        tarih: _tarihController.text,
                        saat: _secilenSaat!,
                        konum: secilenKonum!,
                        kisiSayisi: _secilenOyuncuSayisi,
                        mevki: mevkiler.isNotEmpty ? mevkiler.join(", ") : null,
                        seviye: secilenSeviye,
                        ucret: _ucretController.text.isNotEmpty
                            ? "${_ucretController.text} TL"
                            : null,
                        kullaniciId: userId != null
                            ? int.tryParse(userId)
                            : null,
                      );

                      Navigator.pop(context, yeniIlan);
                    }
                  },
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
