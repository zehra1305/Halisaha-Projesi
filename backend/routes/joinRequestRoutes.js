// routes/joinRequestRoutes.js
// Katılma talepleri ile ilgili HTTP endpoint'leri

const express = require('express');
const router = express.Router();

const {
  katilimTalebiOlustur,
  ilanKatilimTalepleriniGetir,
  talepDurumGuncelle,
} = require('../controllers/joinRequestController');

// Yeni katılım talebi – POST /api/join-requests
router.post('/', katilimTalebiOlustur);

// Belirli ilana ait talepler – GET /api/join-requests/ilan/:ilanId
router.get('/ilan/:ilanId', ilanKatilimTalepleriniGetir);

// Talep durumunu güncelle – PATCH /api/join-requests/:id
router.patch('/:id', talepDurumGuncelle);

module.exports = router;