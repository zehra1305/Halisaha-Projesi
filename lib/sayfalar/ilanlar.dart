/*import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IlanlarPage(),
    // NOT: Türkçe yerelleştirme (localization) ayarları burada veya ana MaterialApp'te yapılmalıdır.
  ));
}

class IlanModel {
  final String adSoyad;
  final String baslik;
  final String konum;
  final String tarih;
  final String saat;
  final String kisiSayisi;
  final String mevki;
  final String seviye;
  final String ucret;
  final String aciklama;
  final String yas;

  IlanModel({
    required this.adSoyad,
    required this.baslik,
    required this.konum,
    required this.tarih,
    required this.saat,
    required this.kisiSayisi,
    required this.mevki,
    required this.seviye,
    required this.ucret,
    required this.aciklama,
    required this.yas,
  });

  // 1. Arkadaşına (Node.js) veri gönderirken kullanacağın fonksiyon
  Map<String, dynamic> toJson() {
    return {
      'ad_soyad': adSoyad,
      'baslik': baslik,
      'konum': konum,
      'tarih': tarih,
      'saat': saat,
      'kisi_sayisi': kisiSayisi,
      'mevki': mevki,
      'seviye': seviye,
      'ucret': ucret,
      'aciklama': aciklama,
      'yas': yas,
    };
  }

  // 2. Arkadaşından (Node.js) veri gelirken kullanacağın fonksiyon
  factory IlanModel.fromJson(Map<String, dynamic> json) {
    return IlanModel(
      adSoyad: json['ad_soyad'] ?? '',
      baslik: json['baslik'] ?? '',
      konum: json['konum'] ?? '',
      tarih: json['tarih'] ?? '',
      saat: json['saat'] ?? '',
      kisiSayisi: json['kisi_sayisi']?.toString() ?? '',
      mevki: json['mevki'] ?? '',
      seviye: json['seviye'] ?? '',
      ucret: json['ucret']?.toString() ?? '',
      aciklama: json['aciklama'] ?? '',
      yas: json['yas']?.toString() ?? '',
    );
  }

  // Tarih ve saat bilgisini DateTime objesine dönüştüren getter
  DateTime get fullDateTime {
    try {
      final dateParts = tarih.split('/');
      final timeParts = saat.split(':');

      if (dateParts.length == 3 && timeParts.length >= 2) {
        return DateTime(
          int.parse(dateParts[2]), // YYYY
          int.parse(dateParts[1]), // MM
          int.parse(dateParts[0]), // DD
          int.parse(timeParts[0]), // HH
          int.parse(timeParts[1]), // MM
        );
      }
    } catch (e) {
      return DateTime.now().subtract(const Duration(days: 1));
    }
    return DateTime.now().subtract(const Duration(days: 1));
  }

  // İlanın süresinin dolup dolmadığını kontrol eder
  bool get isExpired => fullDateTime.isBefore(DateTime.now());
}

// --- 2. SAYFA: İLANLAR LİSTESİ (LİSTE GÖRÜNÜMÜ) ---
class IlanlarPage extends StatefulWidget {
  const IlanlarPage({super.key});

  @override
  State<IlanlarPage> createState() => _IlanlarPageState();
}

class _IlanlarPageState extends State<IlanlarPage> {
  final Color _mainGreen = const Color(0xFF2FB335);

  // Örnek başlangıç verisi (Test amaçlı, tarihi geleceğe ayarladım)
  List<IlanModel> ilanListesi = [
    // UYGULAMA BOŞ BAŞLASIN İSTİYORSANIZ BU BLOĞU TAMAMEN SİLİN.
    IlanModel(
      adSoyad: "Ahmet Yılmaz",
      baslik: "Bu akşam halısaha 21.00",
      konum: "Rüya Halı Saha - Kayseri",
      tarih: "01/10/${DateTime.now().year + 1}", // Örnek tarihi geleceğe ayarladık
      saat: "21:00",
      kisiSayisi: "2",
      mevki: "Kaleci, Forvet",
      seviye: "Orta",
      ucret: "150 TL",
      aciklama: "Bu akşam için 2 oyuncumuz eksik. Samimi bir ortam.",
      yas: "25",
    )
  ];

  void _ilanEkleSayfasinaGit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IlanGirisFormPage()),
    );

    if (result != null && result is IlanModel) {
      setState(() {
        ilanListesi.add(result);
      });
    }
  }

  void _detaySayfasinaGit(IlanModel ilan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IlanDetayPage(ilan: ilan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SÜRESİ DOLAN İLANLARI FİLTRELEME
    final aktifIlanlar = ilanListesi.where((ilan) => !ilan.isExpired).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text("İLANLAR",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22)),
        centerTitle: true,
        elevation: 0,
      ),

      // Filtrelenmiş listeyi kullanıyoruz
      body: aktifIlanlar.isEmpty ? _buildBosDurum() : _buildListeDurumu(aktifIlanlar),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: _mainGreen,
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 40, color: Colors.white),
          onPressed: _ilanEkleSayfasinaGit,
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: _mainGreen,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 40.0),
        child: const Text("İLAN VER",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text("İlan bulunmamaktadır",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildListeDurumu(List<IlanModel> ilanlar) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: ilanlar.length,
      itemBuilder: (context, index) {
        final ilan = ilanlar[index];
        return GestureDetector(
          onTap: () => _detaySayfasinaGit(ilan),
          child: _buildIlanCard(ilan),
        );
      },
    );
  }

  Widget _buildIlanCard(IlanModel ilan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2)),
                child: const Icon(Icons.person, size: 50, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoRow("AD SOYAD:", ilan.adSoyad),
                _buildInfoRow("YAŞ:", ilan.yas),
                _buildInfoRow("ARANAN KİŞİ SAYISI:", ilan.kisiSayisi),
                _buildInfoRow("MEVKİ:", ilan.mevki),
                const SizedBox(height: 5),
                // Konum ve Saat Satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            ilan.konum.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Saat Bilgisi (Sağ Alt)
                    Text(
                      "SAAT: ${ilan.saat}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.black
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10, fontFamily: 'Roboto'),
          children: [
            TextSpan(
                text: value.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// --- 3. SAYFA: İLAN DETAY (PROFİL GÖRÜNÜMÜ) ---
class IlanDetayPage extends StatelessWidget {
  final IlanModel ilan;
  const IlanDetayPage({super.key, required this.ilan});

  final Color _mainGreen = const Color(0xFF2FB335);

  Future<void> _launchMapsUrl() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/VWjyegEHEPM5UVNh7?g_st=ipc');
    if (!await launchUrl(url)) {
      // ignore: avoid_print
      print('Hata: Link açılamadı: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profil Resmi
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3)),
                  child: const Icon(Icons.person, size: 70, color: Colors.black),
                ),
                Positioned(
                    right: 0, top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 24, color: Colors.black),
                    ))
              ],
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ilan.baslik,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(Icons.location_on, ilan.konum),
                  _buildDetailRow(Icons.calendar_today, "${ilan.tarih} ${ilan.saat}"),
                  _buildDetailRow(Icons.people, "${ilan.kisiSayisi} OYUNCU ARANIYOR"),
                  _buildDetailRow(Icons.person, ilan.mevki.toUpperCase()),
                  _buildDetailRow(Icons.star, ilan.seviye.toUpperCase()),
                  _buildDetailRow(Icons.monetization_on, ilan.ucret),

                  const SizedBox(height: 15),
                  Text(
                    ilan.aciklama,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),

                  // Harita / Yol Tarifi Kısmı
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(Icons.map, size: 40, color: Colors.grey),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed: _launchMapsUrl,
                          child: const Text("YOL TARİFİ AL", style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all()),
                        child: const Icon(Icons.person, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ilan.adSoyad.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text("MAÇ DÜZENLEYEN", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _mainGreen),
                          onPressed: () {},
                          child: const Text("MESAJ GÖNDER", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _mainGreen),
                          onPressed: () {},
                          child: const Text("KATILMA TALEBİ", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}

// --- 4. SAYFA: İLAN GİRİŞ FORMU ---
class IlanGirisFormPage extends StatefulWidget {
  const IlanGirisFormPage({super.key});

  @override
  State<IlanGirisFormPage> createState() => _IlanGirisFormPageState();
}

class _IlanGirisFormPageState extends State<IlanGirisFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _mainGreen = const Color(0xFF2FB335);
  final Color _inputGrey = const Color(0xFFE0E0E0);

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _tarihController = TextEditingController();

  // Eskiden TextEditingController olan Saat artık Dropdown için String tutacak
  String? _secilenSaat;

  final TextEditingController _sayiController = TextEditingController();
  final TextEditingController _ucretController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();
  final TextEditingController _yasController = TextEditingController();

  String? secilenKonum = "Rüya Halı Saha - Kayseri";

  // Saat seçeneklerini 17:00'dan 23:00'a kadar oluşturuyoruz
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
        backgroundColor: _mainGreen,
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
              _buildLabel("Ad Soyad"),
              _buildInputBox(controller: _adController),

              _buildLabel("Yaş"),
              _buildInputBox(controller: _yasController, isNumber: true),

              _buildLabel("İlan Başlığı"),
              _buildInputBox(controller: _baslikController),

              _buildLabel("Konum"),
              Container(
                decoration: BoxDecoration(
                  color: _inputGrey,
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

              _buildLabel("Tarih ve Saat"),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInputBox(
                      controller: _tarihController,
                      hint: "Tarih Seç",
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context), // Tarih seçici açar
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    // SAAT DROPDOWN'I
                    child: Container(
                      decoration: BoxDecoration(
                        color: _inputGrey,
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

              _buildLabel("Aranan Oyuncu Sayısı"),
              _buildInputBox(controller: _sayiController, isNumber: true),

              _buildLabel("Mevki"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCheckbox("Kaleci", isKaleci, (v) => setState(() => isKaleci = v!)),
                  _buildCheckbox("Defans", isDefans, (v) => setState(() => isDefans = v!)),
                  _buildCheckbox("Orta Saha", isOrtaSaha, (v) => setState(() => isOrtaSaha = v!)),
                  _buildCheckbox("Forvet", isForvet, (v) => setState(() => isForvet = v!)),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Seviye"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: _inputGrey,
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
                        _buildLabel("Katılım Ücreti"),
                        _buildInputBox(controller: _ucretController, isNumber: true),
                      ],
                    ),
                  ),
                ],
              ),

              _buildLabel("Açıklama"),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: _inputGrey,
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
                    backgroundColor: _mainGreen,
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
                        saat: _secilenSaat!, // Seçilen saat Dropdown'dan geliyor
                        kisiSayisi: _sayiController.text,
                        mevki: mevkiler.join(", "),
                        seviye: secilenSeviye ?? "Belirtilmedi",
                        ucret: _ucretController.text.isEmpty ? "Ücretsiz" : "${_ucretController.text} TL", // Ücret girilmezse Ücretsiz yazsın
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    bool isNumber = false,
    bool readOnly = false,
    VoidCallback? onTap, // Tıklama eventi
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: readOnly, // Kullanıcı girişi engellenir
        onTap: onTap, // Tıklama eventi
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hint,
          suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        ),
        validator: (val) => (val == null || val.isEmpty) ? "Zorunlu alan" : null,
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Column(
      children: [
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: value,
            activeColor: _mainGreen,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}*/