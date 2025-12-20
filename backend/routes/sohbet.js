const express = require('express');
const router = express.Router();
const sohbetController = require('../controllers/sohbetController');

// GET /api/sohbet?userId=123 -> Kullanıcının sohbetleri
router.get('/', sohbetController.getSohbetlerByUser);

// POST /api/sohbet -> Yeni sohbet oluştur veya var olanı döndür
router.post('/', sohbetController.createSohbet);

// GET /api/sohbet/:id -> Sohbet detay
router.get('/:id', sohbetController.getSohbetById);

module.exports = router;
