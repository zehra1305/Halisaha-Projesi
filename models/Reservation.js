const mongoose = require('mongoose');

// Tek bir halı saha için basit randevu şeması
const ReservationSchema = new mongoose.Schema({
  // Tarih: "2025-12-01" formatında string
  tarih: { type: String, required: true },

  // Saat: "17:00" – "23:00" arasında string
  saat: { type: String, required: true },

  // Kullanıcının yazdığı not (opsiyonel)
  not: { type: String }
});

module.exports = mongoose.model('Reservation', ReservationSchema);