import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider2.dart';
import '../admin_dashboard.dart';
import 'admin_reset_password.dart';

class AdminLoginWeb extends StatefulWidget {
  const AdminLoginWeb({super.key});

  @override
  State<AdminLoginWeb> createState() => _AdminLoginWebState();
}

class _AdminLoginWebState extends State<AdminLoginWeb> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Admin teması için koyu yeşil tonu
    const Color adminGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: adminGreen, // Arka planın tamamı koyu yeşil
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450, // Web için ideal form genişliği
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık Alanı (Görseldeki kavisli yeşil alan)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3BB54A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.elliptical(300, 40),
                      bottomRight: Radius.elliptical(300, 40),
                    ),
                  ),
                  child: const Text(
                    'Rüya Halısaha\nAdmin Girişi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Admin E-posta',
                            prefixIcon: const Icon(Icons.admin_panel_settings, color: adminGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value!.isEmpty ? 'E-posta gerekli' : null,
                        ),
                        const SizedBox(height: 20),

                        // Şifre
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock_outline, color: adminGreen),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value!.isEmpty ? 'Şifre gerekli' : null,
                        ),

                        // Hata Mesajı
                        Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            if (auth.errorMessage == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 35),

                        // Giriş Butonu
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3BB54A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Giriş Yap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Şifremi Unuttum (Opsiyonel)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminForgotPasswordWeb()),
                              );
                            },
                            child: const Text(
                              'Şifremi Unuttum',
                              style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                            ),
                          ),
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
}