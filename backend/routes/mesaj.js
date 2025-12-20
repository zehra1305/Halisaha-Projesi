const express = require('express');
const router = express.Router();
const mesajController = require('../controllers/mesajController');

// GET /api/mesaj/sohbet/:sohbetId -> Sohbete ait mesajlar
router.get('/sohbet/:sohbetId', mesajController.getMessagesBySohbet);

// POST /api/mesaj -> Yeni mesaj gönder
router.post('/', mesajController.sendMessage);

module.exports = router;
