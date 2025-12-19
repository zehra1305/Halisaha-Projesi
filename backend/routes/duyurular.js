const express = require('express');
const router = express.Router();
const duyurularController = require('../controllers/duyurularController');

// GET /api/duyurular
router.get('/', duyurularController.getAllDuyurular);

module.exports = router;
