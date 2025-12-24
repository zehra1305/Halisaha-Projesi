import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _acceptKVKK = false;

  // Telefon formatı: 05XX XXX XX XX (05 sabit)
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '05## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    // Telefon alanını 05 ile başlat
    _phoneController.text = '05';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kullanım koşullarını kabul edin')),
      );
      return;
    }

    if (!_acceptKVKK) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen KVKK metnini kabul edin')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.replaceAll(' ', ''), // Boşlukları kaldır
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Kayıt başarılı!')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Kayıt başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Kullanım Koşulları',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '1. Genel Hükümler\n\n'
                  'Bu uygulama, halısaha rezervasyon hizmeti sunmaktadır. '
                  'Uygulamayı kullanarak aşağıdaki koşulları kabul etmiş sayılırsınız.\n\n'
                  '2. Kullanıcı Yükümlülükleri\n\n'
                  '• Doğru ve güncel bilgi vermeyi kabul edersiniz\n'
                  '• Hesabınızın güvenliğinden siz sorumlusunuz\n'
                  '• Yaptığınız rezervasyonlara uymanız gerekmektedir\n\n'
                  '3. Rezervasyon Koşulları\n\n'
                  '• Rezervasyonlar onay sonrası kesinleşir\n'
                  '• İptal koşulları saha sahipleri tarafından belirlenir\n'
                  '• Ödeme bilgileri güvenli şekilde saklanır\n\n'
                  '4. Gizlilik\n\n'
                  'Kişisel verileriniz KVKK kapsamında korunur ve üçüncü '
                  'şahıslarla paylaşılmaz.\n\n'
                  '5. Sorumluluk Sınırlaması\n\n'
                  'Uygulama, saha hizmetlerinden sorumlu değildir. '
                  'Sadece aracılık hizmeti sunmaktadır.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kapat',
                style: TextStyle(color: Color(0xFF3BB54A)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _acceptTerms = true;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3BB54A),
              ),
              child: const Text('Kabul Ediyorum'),
            ),
          ],
        );
      },
    );
  }

  void _showKVKKDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'KVKK Aydınlatma Metni',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kişisel Verilerin Korunması Kanunu (KVKK) Aydınlatma Metni\n\n'
                  '1. Veri Sorumlusu\n\n'
                  'Halısaha Rezervasyon Uygulaması olarak, kişisel verilerinizin '
                  'korunmasına önem veriyoruz.\n\n'
                  '2. İşlenen Kişisel Veriler\n\n'
                  '• Ad Soyad\n'
                  '• E-posta adresi\n'
                  '• Telefon numarası\n'
                  '• Rezervasyon bilgileri\n\n'
                  '3. Kişisel Verilerin İşlenme Amacı\n\n'
                  'Verileriniz sadece aşağıdaki amaçlarla işlenmektedir:\n\n'
                  '• Rezervasyon işlemlerinin gerçekleştirilmesi\n'
                  '• Kullanıcı hesabı yönetimi\n'
                  '• İletişim ve bilgilendirme\n'
                  '• Hukuki yükümlülüklerin yerine getirilmesi\n\n'
                  '4. Veri Güvenliği\n\n'
                  'Kişisel verileriniz, güvenli sunucularda saklanır ve '
                  'şifreleme teknolojileri ile korunur.\n\n'
                  '5. Haklarınız\n\n'
                  'KVKK kapsamında aşağıdaki haklara sahipsiniz:\n\n'
                  '• Verilerinizi öğrenme\n'
                  '• Düzeltme talep etme\n'
                  '• Silme talep etme\n'
                  '• İtiraz etme\n\n'
                  'Daha fazla bilgi için: info@halisaha.com',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kapat',
                style: TextStyle(color: Color(0xFF3BB54A)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _acceptKVKK = true;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3BB54A),
              ),
              child: const Text('Kabul Ediyorum'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Header Section - Top 35%
          Container(
            height: screenHeight * 0.35,
            decoration: const BoxDecoration(color: Color(0xFF3BB54A)),
            child: const Center(
              child: Text(
                'Kayıt Ol',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Form Container - Bottom Sheet Style
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ad Soyad
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Ad Soyad',
                          hintText: 'Ahmet Yılmaz',
                          prefixIcon: const Icon(Icons.person_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı ve soyadınızı girin';
                          }
                          if (value.split(' ').length < 2) {
                            return 'Lütfen ad ve soyadınızı girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'ornek@email.com',
                          prefixIcon: const Icon(Icons.mail_outline),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen e-posta adresinizi girin';
                          }
                          if (!value.contains('@')) {
                            return 'Geçerli bir e-posta adresi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Telefon
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneMaskFormatter],
                        decoration: InputDecoration(
                          labelText: 'Telefon *',
                          hintText: '05XX XXX XX XX',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () {
                          // Eğer alan boşsa 05 ile başlat
                          if (_phoneController.text.isEmpty) {
                            _phoneController.text = '05';
                            _phoneController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _phoneController.text.length,
                                  ),
                                );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty || value == '05') {
                            return 'Lütfen telefon numaranızı girin';
                          }
                          // Boşlukları kaldır ve kontrol et
                          final cleanPhone = value.replaceAll(' ', '');
                          if (cleanPhone.length != 11) {
                            return 'Telefon numarası 11 haneli olmalıdır';
                          }
                          if (!cleanPhone.startsWith('05')) {
                            return 'Telefon numarası 05 ile başlamalıdır';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Şifre
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          helperText:
                              'Min: 8 karakter, 1 büyük, 1 küçük, 1 rakam, 1 özel karakter',
                          helperMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifre girin';
                          }
                          if (value.length < 8) {
                            return 'Şifre en az 8 karakter olmalıdır';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Şifre en az 1 büyük harf içermelidir';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Şifre en az 1 küçük harf içermelidir';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Şifre en az 1 rakam içermelidir';
                          }
                          if (!RegExp(
                            r'[!@#$%^&*(),.?":{}|<>]',
                          ).hasMatch(value)) {
                            return 'Şifre en az 1 özel karakter içermelidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Şifre Tekrar
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre Tekrar',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi tekrar girin';
                          }
                          if (value != _passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Kullanım koşulları
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            activeColor: const Color(0xFF3BB54A),
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                ),
                                children: [
                                  const TextSpan(text: 'Okudum, '),
                                  TextSpan(
                                    text: 'Kullanım Koşullarını',
                                    style: const TextStyle(
                                      color: Color(0xFF3BB54A),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showTermsDialog,
                                  ),
                                  const TextSpan(text: ' kabul ediyorum'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // KVKK
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptKVKK,
                            activeColor: const Color(0xFF3BB54A),
                            onChanged: (value) {
                              setState(() {
                                _acceptKVKK = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                ),
                                children: [
                                  const TextSpan(text: 'Okudum, '),
                                  TextSpan(
                                    text: 'KVKK Metnini',
                                    style: const TextStyle(
                                      color: Color(0xFF3BB54A),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showKVKKDialog,
                                  ),
                                  const TextSpan(text: ' kabul ediyorum'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Kayıt ol butonu
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3BB54A),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Kayıt Ol',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Giriş yap bağlantısı
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Zaten hesabın var mı? ',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: Color(0xFF3BB54A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
