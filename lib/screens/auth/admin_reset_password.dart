import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider2.dart';
import 'admin_login.dart';

class AdminForgotPasswordWeb extends StatefulWidget {
  const AdminForgotPasswordWeb({super.key});

  @override
  State<AdminForgotPasswordWeb> createState() => _AdminForgotPasswordWebState();
}

class _AdminForgotPasswordWebState extends State<AdminForgotPasswordWeb> {
  // Tema Rengi
  final Color darkGreen = const Color(0xFF2E7D32);
  
  // Akışı takip etmek için adım kontrolü (0: E-posta, 1: Kod)
  int currentStep = 0;

  // Controllers
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: darkGreen, // Arka plan tamamen koyu yeşil
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450, // Web için ideal sabit genişlik
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                if (authProvider.errorMessage != null)
                   Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(authProvider.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),
                _buildCurrentStepContent(authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Üst Başlık Kısmı
  Widget _buildHeader() {
    String title = "Admin Şifre Sıfırlama";
    if (currentStep == 1) title = "Doğrulama Kodu";

    return Column(
      children: [
        Icon(Icons.lock_reset, size: 70, color: darkGreen),
        const SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGreen),
        ),
      ],
    );
  }

  // Adımlara Göre İçerik Değişimi
  Widget _buildCurrentStepContent(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (currentStep) {
      case 0: return _stepEmail(authProvider);
      case 1: return _stepVerifyCode(authProvider);
      default: return _stepEmail(authProvider);
    }
  }

  // 1. ADIM: E-POSTA GİRİŞİ
  Widget _stepEmail(AuthProvider authProvider) {
    return Column(
      children: [
        const Text("Sıfırlama kodu almak için kayıtlı admin e-posta adresinizi girin.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 25),
        _inputField("Admin E-posta", Icons.email_outlined, controller: _emailController),
        const SizedBox(height: 25),
        _actionButton("Kod Gönder", () async {
          if (_emailController.text.isEmpty) {
            _showError("Lütfen e-posta adresinizi girin.");
            return;
          }
          final success = await authProvider.resetPassword(_emailController.text.trim());
          if (success) {
            setState(() => currentStep = 1);
          }
        }),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: const Text("Giriş Ekranına Dön", style: TextStyle(color: Colors.grey))
        )
      ],
    );
  }

  // 2. ADIM: KOD DOĞRULAMA
  Widget _stepVerifyCode(AuthProvider authProvider) {
    return Column(
      children: [
        const Text("E-postanıza gelen 6 haneli kodu giriniz.", textAlign: TextAlign.center),
        const SizedBox(height: 25),
        _inputField("6 Haneli Kod", Icons.verified_user_outlined, controller: _codeController),
        const SizedBox(height: 25),
        _actionButton("Kodu Doğrula", () async {
          if (_codeController.text.isEmpty) {
            _showError("Lütfen kodu girin.");
            return;
          }
          final result = await authProvider.verifyResetCode(_emailController.text.trim(), _codeController.text.trim());
          if (result != null && result['success'] == true) {
             final token = result['temporaryToken'];
             Navigator.push(context, MaterialPageRoute(builder: (context) => AdminResetPasswordWeb(temporaryToken: token)));
          }
        }),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () => setState(() => currentStep = 0),
          child: const Text("E-posta Adresini Değiştir", style: TextStyle(color: Colors.grey))
        ),
      ],
    );
  }

  // Yardımcı Widgetlar
  Widget _inputField(String label, IconData icon, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: darkGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class AdminResetPasswordWeb extends StatefulWidget {
  final String temporaryToken;

  const AdminResetPasswordWeb({super.key, required this.temporaryToken});

  @override
  State<AdminResetPasswordWeb> createState() => _AdminResetPasswordWebState();
}

class _AdminResetPasswordWebState extends State<AdminResetPasswordWeb> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Admin Paneli Kurumsal Renkleri
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFF3BB54A);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.confirmResetPassword(
        widget.temporaryToken,
        _passwordController.text,
      );

      if (mounted && success) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Icon(Icons.check_circle, color: darkGreen, size: 60),
        content: const Text(
          'Admin şifresi başarıyla güncellendi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AdminLoginWeb()),
                  (route) => false,
                );
              },
              child: const Text('Giriş Ekranına Dön', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen, // Web arka planı tamamen koyu yeşil
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450, // Web için ideal genişlik
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst Kavisli Başlık
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.elliptical(300, 30),
                      bottomRight: Radius.elliptical(300, 30),
                    ),
                  ),
                  child: const Text(
                    'Yeni Admin Şifresi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Lütfen yönetici paneliniz için yeni bir güvenlik şifresi belirleyin.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),

                        // Yeni Şifre
                        _buildPasswordField(
                          controller: _passwordController,
                          label: "Yeni Şifre",
                          obscure: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 20),

                        // Şifre Tekrar
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: "Şifre Tekrar",
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          isConfirm: true,
                        ),

                        // Şifre Gereksinimleri Kutusu (Web Stili)
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Text(
                            "• En az 8 karakter, büyük/küçük harf, rakam ve özel karakter içermelidir.",
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Onayla Butonu
                        Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            return SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: darkGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: auth.isLoading ? null : _handleResetPassword,
                                child: auth.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text("Şifreyi Güncelle ve Kaydet", 
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: darkGreen),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Bu alan boş bırakılamaz';
        if (!isConfirm && value.length < 8) return 'En az 8 karakter giriniz';
        if (isConfirm && value != _passwordController.text) return 'Şifreler eşleşmiyor';
        return null;
      },
    );
  }
}