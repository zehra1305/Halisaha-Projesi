import 'package:flutter/material.dart';
import '../models/ilan_model.dart';
// WIDGETS KLASÖRÜNDEN YARDIMCI FONKSİYONLAR VE RENKLER İÇİN İMPORT EDİLDİ
import '../widgets/custom_form_widgets.dart';

// --- 4. SAYFA: İLAN GİRİŞ FORMU ---
class IlanGirisFormPage extends StatefulWidget {
  const IlanGirisFormPage({super.key});

  @override
  State<IlanGirisFormPage> createState() => _IlanGirisFormPageState();
}

class _IlanGirisFormPageState extends State<IlanGirisFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Renk tanımları custom_form_widgets.dart'a taşındığı için buradan kaldırıldı.

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _tarihController = TextEditingController();

  String? _secilenSaat;

  final TextEditingController _sayiController = TextEditingController();
  final TextEditingController _ucretController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _yasController = TextEditingController();

  String? secilenKonum = "Rüya Halı Saha - Kayseri";

  final List<String> saatSecenekleri = List.generate(7, (index) {
    int hour = 17 + index;
    return '${hour.toString().padLeft(2, '0')}:00';
  });

  bool isKaleci = false;
  bool isDefans = false;
  bool isOrtaSaha = false;
  bool isForvet = false;

  String? secilenSeviye;
  final List<String> seviyeler = ['Başlangıç', 'Orta', 'İyi', 'Profesyonel'];

  // TARİH SEÇİMİ (DD/MM/YYYY formatında kaydedilir)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tarihController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainGreen, // Renk sabiti widgets dosyasından alındı
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
              buildLabel("Ad Soyad"), // Yardımcı widget çağrısı
              buildInputBox(controller: _adController), // Yardımcı widget çağrısı

              buildLabel("Yaş"),
              buildInputBox(controller: _yasController, isNumber: true),

              buildLabel("İlan Başlığı"),
              buildInputBox(controller: _baslikController),

              buildLabel("Konum"),
              Container(
                decoration: BoxDecoration(
                  color: inputGrey, // Renk sabiti widgets dosyasından alındı
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
                    child: buildInputBox( // Yardımcı widget çağrısı
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
                            suffixIcon: Icon(Icons.access_time, color: Colors.black54),
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                            hintText: "Saat",
                          ),
                          isExpanded: true,
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
                          validator: (value) => value == null ? "Seçiniz" : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              buildLabel("Aranan Oyuncu Sayısı"),
              buildInputBox(controller: _sayiController, isNumber: true),

              buildLabel("Mevki"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildCheckbox("Kaleci", isKaleci, (v) => setState(() => isKaleci = v!)), // Yardımcı widget çağrısı
                  buildCheckbox("Defans", isDefans, (v) => setState(() => isDefans = v!)),
                  buildCheckbox("Orta Saha", isOrtaSaha, (v) => setState(() => isOrtaSaha = v!)),
                  buildCheckbox("Forvet", isForvet, (v) => setState(() => isForvet = v!)),
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
                              onChanged: (val) => setState(() => secilenSeviye = val),
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
                        buildInputBox(controller: _ucretController, isNumber: true),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      List<String> mevkiler = [];
                      if(isKaleci) mevkiler.add("Kaleci");
                      if(isDefans) mevkiler.add("Defans");
                      if(isOrtaSaha) mevkiler.add("Orta Saha");
                      if(isForvet) mevkiler.add("Forvet");

                      // Tarih/Saat kontrolü
                      if (_tarihController.text.isEmpty || _secilenSaat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lütfen Tarih ve Saati seçin.")),
                        );
                        return;
                      }

                      final yeniIlan = IlanModel(
                        adSoyad: _adController.text,
                        yas: _yasController.text,
                        baslik: _baslikController.text,
                        konum: secilenKonum!,
                        tarih: _tarihController.text,
                        saat: _secilenSaat!,
                        kisiSayisi: _sayiController.text,
                        mevki: mevkiler.join(", "),
                        seviye: secilenSeviye ?? "Belirtilmedi",
                        ucret: _ucretController.text.isEmpty ? "Ücretsiz" : "${_ucretController.text} TL",
                        aciklama: _aciklamaController.text,
                      );

                      Navigator.pop(context, yeniIlan);
                    }
                  },
                  child: const Text("Kaydet", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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