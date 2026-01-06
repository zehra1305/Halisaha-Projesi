import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Flutter Secure Storage başlatılıyor
  final _storage = const FlutterSecureStorage();

  // Anahtarlar (Keys) - Yazım hatası olmaması için sabitler
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // --- TOKEN İŞLEMLERİ ---

  // Token Kaydet
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Token Getir
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // --- KULLANICI BİLGİLERİ ---

  // Kullanıcı Bilgilerini Toplu Kaydet
  Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userNameKey, value: name);
  }

  // User ID Getir
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Email Getir
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  // İsim Getir
  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  // --- ÇIKIŞ İŞLEMİ ---

  // Tüm Verileri Sil (Logout yapınca çağırılır)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}