const express = require('express');
const router = express.Router();

// Controller fonksiyonlarını içe aktarıyoruz
const {
  randevuOlustur,
  doluSaatleriGetir
} = require('../controllers/reservationController');


// Belirli bir tarih için dolu saatleri getir
router.get('/availability', doluSaatleriGetir);

// Yeni randevu oluştur
router.post('/', randevuOlustur);

module.exports = router;