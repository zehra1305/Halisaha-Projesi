const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

const { connectDB } = require('./config/db');

const reservationRoutes = require('./routes/reservationRoutes');
const ilanRoutes = require('./routes/ilanRoutes');
const messageRoutes = require('./routes/messageRoutes');
const joinRequestRoutes = require('./routes/joinRequestRoutes');

// YENİ:
const appointmentsRoutes = require('./routes/appointmentsRoutes');

dotenv.config();
connectDB();

const app = express();

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

app.get('/', (req, res) => {
  res.send('Halı saha API çalışıyor');
});

// Köhnə sistem qalır:
app.use('/api/reservations', reservationRoutes);
app.use('/api/ilanlar', ilanRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/join-requests', joinRequestRoutes);

// Frontun gözlədiyi yeni endpoint:
app.use('/appointments', appointmentsRoutes);

const PORT = process.env.PORT || 5000;

console.log('Express ayarları bitti, server az sonra başlayacak...');

app.listen(PORT, () => {
  console.log(`Server ${PORT} portunda çalışıyor`);
});