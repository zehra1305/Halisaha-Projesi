import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider2.dart';
import 'auth/admin_login.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Kurumsal Renkler
    const Color darkGreen = Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli', style: TextStyle(color: Colors.white)),
        backgroundColor: darkGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginWeb()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 100, color: darkGreen),
            const SizedBox(height: 20),
            Text(
              'Hoşgeldiniz, ${authProvider.user?.name ?? "Admin"}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Yönetim Paneli Başlangıç Ekranı',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}