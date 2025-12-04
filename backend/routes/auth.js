const express = require('express');
const router = express.Router();

// Gerçek veritabanı controller'ı kullan
const authController = require('../controllers/authController');

// Kayıt olma
router.post('/register', authController.register);

// Giriş yapma
router.post('/login', authController.login);

// Şifre sıfırlama - Kod gönder
router.post('/reset-password', authController.resetPassword);

// Şifre sıfırlama - Kodu doğrula
router.post('/verify-reset-code', authController.verifyResetCode);

// Şifre sıfırlama - Yeni şifre belirle
router.post('/confirm-reset-password', authController.confirmResetPassword);

// Google ile giriş
router.post('/google-login', authController.googleLogin);

// Firebase token doğrulama
router.post('/verify-token', authController.verifyToken);

module.exports = router;
