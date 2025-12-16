const express = require('express');
const router = express.Router();
const ilanController = require('../controllers/ilanController');

// Tüm ilanları getir
router.get('/', ilanController.getAllIlanlar);

// Kullanıcıya ait ilanları getir
router.get('/user/:userId', ilanController.getIlanlarByUserId);

// Tek bir ilan getir
router.get('/:id', ilanController.getIlanById);

// Yeni ilan oluştur
router.post('/', ilanController.createIlan);

// İlan güncelle
router.put('/:id', ilanController.updateIlan);

// İlan sil
router.delete('/:id', ilanController.deleteIlan);

module.exports = router;
