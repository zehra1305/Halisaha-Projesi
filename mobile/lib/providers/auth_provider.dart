import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '679415860742-017f5bv77b4bja9ujsint6b8kuks9lhs.apps.googleusercontent.com',
  );
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Login
  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(
        email,
        password,
        rememberMe: rememberMe,
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

    // Google Sign Out
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }

    // Firebase Sign Out
    await _firebaseAuth.signOut();

    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Google ile giriş
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Google girişi iptal edildi';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Google Auth
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase Credential oluştur
      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      // Firebase ile giriş yap
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // ID Token al
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        _errorMessage = 'Token alınamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Backend'e gönder
      final result = await _apiService.googleLogin(idToken);

      if (result['success']) {
        final data = result['data'];

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
      _errorMessage = 'Google girişi başarısız: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

  // Update profile
  Future<bool> updateProfile({String? name, String? phone}) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updateProfile(
        _user!.id,
        name: name,
        phone: phone,
      );

      if (result['success']) {
        final data = result['data'];
        _user = User.fromJson(data['user']);

        // Storage'ı güncelle
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

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.changePassword(
        _user!.id,
        currentPassword,
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

  // Upload profile photo
  Future<bool> uploadProfilePhoto(File imageFile) async {
    if (_user == null) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.uploadProfilePhoto(_user!.id, imageFile);

      if (result['success']) {
        // Update user's photo path
        // Backend response: {success: true, data: {success: true, data: {photoPath: ...}}}
        final responseData = result['data'];
        final photoPath = responseData['data'] != null
            ? responseData['data']['photoPath']
            : responseData['photoPath'];

        _user = _user!.copyWith(profileImage: photoPath);

        // Save to storage
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

  // Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    if (_user == null) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.deleteProfilePhoto(_user!.id);

      if (result['success']) {
        // Update user's photo path to null
        _user = _user!.copyWith(clearProfileImage: true);

        // Save to storage
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
}
