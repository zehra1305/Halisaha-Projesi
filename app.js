console.log('Backend başlıyor...');

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

const connectDB = require('./config/db');
const reservationRoutes = require('./routes/reservationRoutes');

// .env dosyasını projeye yüklüyoruz
dotenv.config();

// Veritabanı bağlantısını başlat
connectDB();

const app = express();

// JSON gövde (body) okumak ve CORS açmak için middleware'ler
app.use(cors());
app.use(express.json());

// test endpoint'i – backend ayakta mı kontrol etmek için
app.get('/', (req, res) => {
  res.send('Halı saha API çalışıyor');
});

// Randevu ile ilgili tüm endpoint'ler
app.use('/api/reservations', reservationRoutes);

const PORT = process.env.PORT || 5000;

console.log('Express ayarları bitti, server az sonra başlayacak...');

app.listen(PORT, () => {
  console.log(`Server ${PORT} portunda çalışıyor`);
});