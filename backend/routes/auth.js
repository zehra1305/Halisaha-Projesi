const express = require('express');
const router = express.Router();

// Gerçek veritabanı controller'ı kullan
const authController = require('../controllers/authController');

// Kayıt olma
router.post('/register', authController.register);

// Giriş yapma
router.post('/login', authController.login);

module.exports = router;
