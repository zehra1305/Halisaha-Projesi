const express = require('express');
const router = express.Router();
const randevuController = require('../controllers/randevuController');

// Kullanıcı işlemleri
router.post('/', randevuController.createRandevu);
router.get('/kullanici/:userId', randevuController.getRandevularByUser);
router.get('/yaklasan/:userId', randevuController.getYaklasanRandevu);
router.get('/yaklasanlar/:userId', randevuController.getYaklasanRandevular);
router.get('/musait-saatler', randevuController.getMusaitSaatler);
router.delete('/:id', randevuController.cancelRandevu);

// Admin işlemleri
router.get('/admin/all', randevuController.getAllRandevularAdmin);
router.put('/admin/:id/durum', randevuController.updateRandevuDurum);

module.exports = router;
