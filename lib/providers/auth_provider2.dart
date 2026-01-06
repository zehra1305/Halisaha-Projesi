import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Paket eklendi
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

  // ==================================================
  // 1. LOGIN (GÜNCELLENDİ ✅)
  // ==================================================
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(
        email,
        password,
        rememberMe: rememberMe,
      );

      if (result['success'] == true) {
        // --- WEB REFRESH ÇÖZÜMÜ BURADA ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        // ---------------------------------

        final data = result['data'] ?? result; 
        final token = data['token'];
        
        if (token != null) {
          await _storageService.saveToken(token);
        }

        if (data['user'] != null) {
          _user = User.fromJson(data['user']);
          await _storageService.saveUserInfo(
            userId: _user!.id,
            email: _user!.email,
            name: _user!.name,
          );
        } else {
          _user = User(id: "1", name: "Admin", email: email, createdAt: DateTime.now());
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Giriş başarısız';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Giriş hatası: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // 2. REGISTER
  // ==================================================
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
        password: password,
        phone: phone,
      );

      if (result['success'] == true) {
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
      _errorMessage = 'Kayıt hatası: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // 3. LOGOUT (GÜNCELLENDİ ✅)
  // ==================================================
  Future<void> logout() async {
    // --- GİRİŞ KAYDINI TEMİZLE ---
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    // ----------------------------

    await _storageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Check Login Status
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

  // ==================================================
  // 4. ŞİFRE SIFIRLAMA
  // ==================================================
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.resetPassword(email);

      if (result['success'] == true) {
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
      _errorMessage = 'Hata: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // 5. KOD DOĞRULAMA
  // ==================================================
  Future<Map<String, dynamic>?> verifyResetCode(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.verifyResetCode(email, code);

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'temporaryToken': result['temporaryToken']};
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return {'success': false};
      }
    } catch (e) {
      _errorMessage = 'Hata: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false};
    }
  }

  // ==================================================
  // 6. ŞİFREYİ ONAYLA
  // ==================================================
  Future<bool> confirmResetPassword(String temporaryToken, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.confirmResetPassword(temporaryToken, newPassword);

      if (result['success'] == true) {
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
      _errorMessage = 'Hata: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================================================
  // PROFİL İŞLEMLERİ
  // ==================================================
  
  Future<bool> updateProfile({String? name, String? phone}) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updateProfile(
        name: name,
        phone: phone,
        email: _user!.email,
      );

      if (result['success'] == true) {
        if (name != null) {
          _user = User(
            id: _user!.id,
            name: name,
            email: _user!.email,
            profileImage: _user!.profileImage,
            createdAt: _user!.createdAt,
          );
          
          await _storageService.saveUserInfo(
            userId: _user!.id,
            email: _user!.email,
            name: _user!.name,
          );
        }
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
      _errorMessage = 'Güncelleme hatası: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.changePassword(currentPassword, newPassword);
      if (result['success'] == true) {
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
      _errorMessage = 'Şifre değiştirme hatası: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(dynamic imageFile) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.uploadProfilePhoto(imageFile);
      if (result['success'] == true) {
        _user = _user!.copyWith(profileImage: "https://via.placeholder.com/150");
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
      _errorMessage = 'Fotoğraf yükleme hatası: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProfilePhoto() async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.deleteProfilePhoto();
      if (result['success'] == true) {
        _user = _user!.copyWith(clearProfileImage: true);
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
      _errorMessage = 'Fotoğraf silme hatası: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}