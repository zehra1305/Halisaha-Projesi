// routes/messageRoutes.js
// Mesaj ile ilgili tüm HTTP endpoint'leri burada tanımlanır

const express = require('express');
const router = express.Router();

// Controller fonksiyonlarını içe aktarıyoruz
const {
  mesajOlustur,
  ilanMesajlariniGetir,
} = require('../controllers/messageController');

// Yeni mesaj oluştur – POST /api/messages
router.post('/', mesajOlustur);

// Belirli ilana ait mesajlar – GET /api/messages/:ilanId
router.get('/:ilanId', ilanMesajlariniGetir);

module.exports = router;