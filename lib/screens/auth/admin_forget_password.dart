import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider2.dart';
import 'admin_verify_reset_code_screen.dart';

class ForgotPasswordWeb extends StatefulWidget {
  const ForgotPasswordWeb({super.key});

  @override
  State<ForgotPasswordWeb> createState() => _ForgotPasswordWebState();
}

class _ForgotPasswordWebState extends State<ForgotPasswordWeb> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  // Admin Paneli Kurumsal Renkleri
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFF3BB54A);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          setState(() => _emailSent = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen, // Web arka planı tamamen koyu yeşil
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450, // Web için ideal sabit genişlik
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kavisli Header Alanı
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
                    'Admin Şifre Sıfırlama',
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
                        _buildStatusIcon(),
                        const SizedBox(height: 30),
                        if (!_emailSent) _buildEmailForm() else _buildSuccessState(),
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

  Widget _buildStatusIcon() {
    return Center(
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: accentGreen.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _emailSent ? Icons.check_circle_outline : Icons.lock_reset,
          size: 40, color: accentGreen,
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        const Text(
          'Sıfırlama kodu almak için e-posta adresinizi girin',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 25),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline, color: darkGreen),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => (value == null || !value.contains('@')) ? 'Geçerli bir e-posta girin' : null,
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text('Sıfırlama Kodu Gönder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Giriş ekranına geri dön', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Text('E-posta Gönderildi!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentGreen)),
        const SizedBox(height: 15),
        Text('${_emailController.text} adresine talimatlar gönderildi.', textAlign: TextAlign.center),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminVerifyCodeWeb(email: _emailController.text.trim())),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: const Text('Doğrulama Kodunu Gir', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}