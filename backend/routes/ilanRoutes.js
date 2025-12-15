// routes/ilanRoutes.js

const express = require('express');
const router = express.Router();

// Controller fonksiyonlarını içe aktarıyoruz
const {
  ilanOlustur,
  ilanListele,
  ilanDetay,
} = require('../controllers/ilanController');

// Tüm ilanları listeleme endpoint'i
// Örnek: GET /api/ilanlar
router.get('/', ilanListele);

// Yeni ilan oluşturma endpoint'i
// Örnek: POST /api/ilanlar
router.post('/', ilanOlustur);

// Tek bir ilan detayını getirme endpoint'i
// Örnek: GET /api/ilanlar/5
router.get('/:id', ilanDetay);

// Dışa aktarma – Express burada bir router bekliyor
module.exports = router;