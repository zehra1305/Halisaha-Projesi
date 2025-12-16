const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const db = require('./config/database');
require('dotenv').config();

// --- ROUTE TANIMLAMALARI ---
const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const profileRoutesNew = require('./routes/profileRoutes');
const duyuruRoutes = require('./routes/duyurular'); // <-- BİZİM EKLEDİĞİMİZ

const app = express();
const PORT = process.env.PORT || 3001;

// --- MIDDLEWARE ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Session middleware
app.use(session({
    secret: process.env.SESSION_SECRET || 'halisaha-secret-key-2024',
    resave: false,
    saveUninitialized: false,
    cookie: { 
        secure: false, 
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000 
    }
}));

// Statik dosyalar
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/public', express.static(path.join(__dirname, 'public')));

// Sağlık kontrolü
app.get('/health', (req, res) => {
    res.json({ status: 'Server çalışıyor ✅' });
});

// DB Bağlantı Testi
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

// --- ROTA KULLANIMLARI ---
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api', profileRoutesNew);
app.use('/api/duyurular', duyuruRoutes); // <-- BİZİM SİSTEM DEVREDE

// --- SUNUCUYU BAŞLAT (ÖNEMLİ DÜZELTME) ---
// '0.0.0.0' ekleyerek dışarıdan (emülatörden) erişime izin veriyoruz.
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server tüm ağlara açık ve çalışıyor: http://0.0.0.0:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n📴 Server kapatılıyor...');
    db.end();
    process.exit(0);
});