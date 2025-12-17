import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Save Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Save User Info
  Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userNameKey, value: name);
  }

  // Get User ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Get User Email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  // Get User Name
  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  // Clear All Data (Logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}