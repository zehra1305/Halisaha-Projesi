const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');

// Geri bildirim gönder
router.post('/', feedbackController.sendFeedback);

// Kullanıcının geri bildirimlerini getir
router.get('/user/:userId', feedbackController.getUserFeedbacks);

module.exports = router;
