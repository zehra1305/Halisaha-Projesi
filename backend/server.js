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
app.use(cors());
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
app.post('/api/support/start', async (req, res) => {

    const { kullanici_id } = req.body;

    try {

        // 1. Önce var olan bir sohbet var mı bak (Admin ID her zaman 1 varsayılır)

        // İlan ID'si 2 olan (Bizim Canlı Destek İlanı) sohbete bakıyoruz

        const checkQuery = `

            SELECT * FROM sohbet 

            WHERE (baslatan_id = $1 AND ilan_sahibi_id = 1 AND ilan_id = 2) 

               OR (baslatan_id = 1 AND ilan_sahibi_id = $1 AND ilan_id = 2) 

            LIMIT 1`;

        const existingChat = await db.query(checkQuery, [kullanici_id]);
 
        if (existingChat.rows.length > 0) {

            return res.json({ sohbet_id: existingChat.rows[0].sohbet_id });

        }
 
        // 2. Yoksa yeni oluştur (İlan ID = 2 KURALI BURADA)

        const insertQuery = `

            INSERT INTO sohbet (ilan_id, baslatan_id, ilan_sahibi_id) 

            VALUES (2, $1, 1) 

            RETURNING sohbet_id`;

        const newChat = await db.query(insertQuery, [kullanici_id]);

        res.json({ sohbet_id: newChat.rows[0].sohbet_id });
 
    } catch (err) {

        console.error("Support Chat Başlatma Hatası:", err);

        res.status(500).json({ error: 'Sohbet başlatılamadı' });

    }

});
 
// B. Mesajları Getir (Canlı Destek İçin)

app.get('/api/mesajlar/:sohbetId', async (req, res) => {

    try {

        const { sohbetId } = req.params;

        const query = `

            SELECT * FROM mesaj 

            WHERE sohbet_id = $1 

            ORDER BY gonderme_zamani ASC`;

        const result = await db.query(query, [sohbetId]);

        res.json(result.rows);

    } catch (err) {

        console.error("Mesaj Getirme Hatası:", err);

        res.status(500).json({ error: 'Mesajlar alınamadı' });

    }

});
 
// C. Mesaj Gönder (Canlı Destek İçin)

app.post('/api/mesajlar', async (req, res) => {

    try {

        const { sohbet_id, gonderen_id, icerik } = req.body;

        const query = `

            INSERT INTO mesaj (sohbet_id, gonderen_id, icerik) 

            VALUES ($1, $2, $3) 

            RETURNING *`;

        const result = await db.query(query, [sohbet_id, gonderen_id, icerik]);

        res.status(201).json(result.rows[0]);

    } catch (err) {

        console.error("Mesaj Gönderme Hatası:", err);

        res.status(500).json({ error: 'Mesaj gönderilemedi' });

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
