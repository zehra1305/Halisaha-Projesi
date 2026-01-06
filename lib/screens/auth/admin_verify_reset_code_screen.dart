import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider2.dart';
import 'admin_reset_password.dart';

class AdminVerifyCodeWeb extends StatefulWidget {
  final String email;

  const AdminVerifyCodeWeb({super.key, required this.email});

  @override
  State<AdminVerifyCodeWeb> createState() => _AdminVerifyCodeWebState();
}

class _AdminVerifyCodeWebState extends State<AdminVerifyCodeWeb> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  // Kurumsal Renkler
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFF3BB54A);

  @override
  void dispose() {
    for (var c in _controllers) {c.dispose();}
    for (var n in _focusNodes) {n.dispose();}
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Lütfen 6 haneli kodu giriniz');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.verifyResetCode(widget.email, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null && result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminResetPasswordWeb(temporaryToken: result['temporaryToken'])),
        );
      } else {
        setState(() => _errorMessage = authProvider.errorMessage ?? 'Kod hatalı');
        for (var c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen, // Web arka planı
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 480, // Web kart genişliği
            padding: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kavisli Header
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
                    'Güvenlik Doğrulaması',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 30, 40, 40),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_unread_outlined, size: 60, color: Color(0xFF3BB54A)),
                      const SizedBox(height: 20),
                      Text(
                        '${widget.email}\nadresine gönderilen kodu giriniz',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 35),
                      
                      // 6 Haneli Inputlar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _buildCodeBox(index)),
                      ),

                      if (_errorMessage != null) _buildErrorLabel(),

                      const SizedBox(height: 35),
                      _buildVerifyButton(),
                      
                      const SizedBox(height: 20),
                      _buildResendButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 55,
      height: 65,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentGreen, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
          if (_controllers.every((c) => c.text.isNotEmpty)) _handleVerifyCode();
        },
      ),
    );
  }

  Widget _buildErrorLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Doğrula ve Devam Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _isLoading ? null : () {}, // Buraya resend fonksiyonu gelecek
      child: Text('Kodu Tekrar Gönder', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600)),
    );
  }
}