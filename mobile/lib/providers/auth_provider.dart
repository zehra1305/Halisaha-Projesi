import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);

      if (result['success']) {
        final data = result['data'];

        // Token kaydet
        await _storageService.saveToken(data['token']);

        // User bilgilerini kaydet
        _user = User.fromJson(data['user']);
        await _storageService.saveUserInfo(
          userId: _user!.id,
          email: _user!.email,
          name: _user!.name,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (result['success']) {
        final data = result['data'];

        // Token kaydet
        await _storageService.saveToken(data['token']);

        // User bilgilerini kaydet
        _user = User.fromJson(data['user']);
        await _storageService.saveUserInfo(
          userId: _user!.id,
          email: _user!.email,
          name: _user!.name,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user is logged in
  Future<void> checkLoginStatus() async {
    final token = await _storageService.getToken();
    if (token != null) {
      final userId = await _storageService.getUserId();
      final email = await _storageService.getUserEmail();
      final name = await _storageService.getUserName();

      if (userId != null && email != null && name != null) {
        _user = User(
          id: userId,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.resetPassword(email);

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify Reset Code
  Future<Map<String, dynamic>?> verifyResetCode(
    String email,
    String code,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.verifyResetCode(email, code);

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        // Temporary token'ı döndür
        return {'success': true, 'temporaryToken': result['temporaryToken']};
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return {'success': false};
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false};
    }
  }

  // Confirm Reset Password
  Future<bool> confirmResetPassword(
    String temporaryToken,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.confirmResetPassword(
        temporaryToken,
        newPassword,
      );

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
