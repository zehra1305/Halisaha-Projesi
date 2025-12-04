const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const upload = require('../middleware/upload');

// Profil bilgilerini getir
router.get('/:userId', profileController.getProfile);

// Profil bilgilerini güncelle
router.put('/:userId', profileController.updateProfile);

// Şifre değiştir
router.put('/:userId/change-password', profileController.changePassword);

// Profil fotoğrafı yükle
router.post('/:userId/upload-photo', upload.single('photo'), profileController.uploadProfilePhoto);

// Profil fotoğrafını sil
router.delete('/:userId/photo', profileController.deleteProfilePhoto);

module.exports = router;
