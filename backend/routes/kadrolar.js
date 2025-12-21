const express = require('express');
const router = express.Router();
const kadroController = require('../controllers/kadroController');

// Kadro route'ları
router.get('/', kadroController.getKadrolar);
router.get('/:id', kadroController.getKadro);
router.post('/', kadroController.createKadro);
router.put('/:id', kadroController.updateKadro);
router.delete('/:id', kadroController.deleteKadro);

module.exports = router;
