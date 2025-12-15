// routes/appointmentsRoutes.js
const express = require('express');
const router = express.Router();

const {
  getAppointmentsByDate,
  createAppointment,
  approveAppointment,
} = require('../controllers/appointmentsController');

// GET /appointments?date=YYYY-MM-DD
router.get('/', getAppointmentsByDate);

// POST /appointments
router.post('/', createAppointment);

// PUT /appointments/:id/approve
router.put('/:id/approve', approveAppointment);

module.exports = router;