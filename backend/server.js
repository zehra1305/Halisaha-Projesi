const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const db = require('./config/database');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Routes
const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const profileRoutesNew = require('./routes/profileRoutes');
const ilanlarRoutes = require('./routes/ilanlar');
const randevularRoutes = require('./routes/randevular');
const duyurularRoutes = require('./routes/duyurular');
const sohbetRoutes = require('./routes/sohbet');
const mesajRoutes = require('./routes/mesaj');
const feedbackRoutes = require('./routes/feedback');
const kadrolarRoutes = require('./routes/kadrolar');

// Middleware
// CORS ayarları - Tüm originlere izin ver
app.use(cors({
    origin: '*', // Veya belirli domainler: ['https://halisaha-mobil-backend-c4dtaqfnfpdfepg5.germanywestcentral-01.azurewebsites.net']
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// Preflight istekleri için OPTIONS
app.options('*', cors());

app.use(express.json({ charset: 'utf-8' }));
app.use(express.urlencoded({ extended: true, charset: 'utf-8' }));

// UTF-8 encoding için header middleware
app.use((req, res, next) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    next();
});

// Session middleware
app.use(session({
    secret: process.env.SESSION_SECRET || 'halisaha-secret-key-2024',
    resave: false,
    saveUninitialized: false,
    cookie: { 
        secure: false, // Set to true if using HTTPS
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }
}));

// Static files - Profil fotoğrafları için
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/public', express.static(path.join(__dirname, 'public')));

// Sağlık kontrol endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'Server çalışıyor ✅' });
});

// Database bağlantı testi
app.get('/api/health-db', async (req, res) => {
    try {
        const result = await db.query('SELECT NOW()');
        res.json({ 
            status: 'Veritabanı bağlantısı başarılı ✅',
            timestamp: result.rows[0].now 
        });
    } catch (err) {
        res.status(500).json({ 
            status: 'Veritabanı bağlantı hatası ❌',
            error: err.message 
        });
    }
});
// Duyurular routes
app.use('/api/duyurular', duyurularRoutes);

// Auth routes
app.use('/api/auth', authRoutes);

// Profile routes (API)
app.use('/api/profile', profileRoutes);

// Profile routes (Session-based)
app.use('/api', profileRoutesNew);

// İlanlar routes
app.use('/api/ilanlar', ilanlarRoutes);

// Randevular routes
app.use('/api/randevular', randevularRoutes);

// Sohbet ve mesaj routes
app.use('/api/sohbet', sohbetRoutes);
app.use('/api/mesaj', mesajRoutes);

// Geri bildirim routes
app.use('/api/feedback', feedbackRoutes);

// Kadro routes
app.use('/api/kadrolar', kadrolarRoutes);

// Sunucuyu başlat
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server http://localhost:${PORT} adresinde çalışıyor`);
    console.log(`📱 Emülatör için: http://10.0.2.2:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n📴 Server kapatılıyor...');
    db.end();
    process.exit(0);
});
