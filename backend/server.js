const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const { Pool } = require('pg'); // Veritabanı kütüphanesi
require('dotenv').config();

// --- ROUTE DOSYALARI ---
const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');

const app = express();
const PORT = process.env.PORT || 3001;

// --- VERİTABANI BAĞLANTISI (SABİT) ---
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'halisaha_db', // Senin veritabanı adın
    password: '1234',      // Senin şifren
    port: 5432,
});

// DB Bağlantı Testi
pool.connect((err, client, release) => {
    if (err) {
        return console.error('❌ Veritabanı bağlantı hatası:', err.message);
    }
    client.query('SELECT NOW()', (err, result) => {
        release();
        if (err) {
            return console.error('❌ Sorgu hatası:', err.message);
        }
        console.log('✅ Veritabanına başarıyla bağlanıldı!');
    });
});

// --- MIDDLEWARE ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Session
app.use(session({
    secret: 'halisaha-secret-key-2024',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, httpOnly: true }
}));

// Statik Dosyalar
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// --- ANA ROUTES (Login, Profil vb.) ---
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);

// --- YENİ EKLENEN: DUYURU SİSTEMİ (Senin Admin Kodların) ---

// 1. Duyuru Ekleme (POST)
app.post('/api/duyurular', async (req, res) => {
    try {
        const { baslik, resim_url, metin } = req.body;
        console.log('📨 Yeni Duyuru İsteği:', { baslik, metin });

        // Basit doğrulama
        if (!resim_url || !metin) {
            return res.status(400).json({ error: "Resim ve metin zorunludur" });
        }

        // Veritabanına ekle
        // Not: Tablonda 'baslik' sütunu varsa $3 olarak ekle, yoksa çıkart.
        // Senin SQL tablonda 'baslik' varsayılan 'Duyuru' idi, o yüzden şimdilik eklemiyorum.
        const query = `
            INSERT INTO duyurular (resim_url, metin) 
            VALUES ($1, $2) 
            RETURNING *
        `;
        
        const result = await pool.query(query, [resim_url, metin]);
        
        res.status(201).json({
            success: true,
            message: "Duyuru başarıyla eklendi",
            data: result.rows[0]
        });
    } catch (err) {
        console.error('❌ Duyuru Ekleme Hatası:', err.message);
        res.status(500).json({ error: 'Sunucu hatası: ' + err.message });
    }
});

// 2. Duyuruları Getir (GET)
app.get('/api/duyurular', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM duyurular ORDER BY id DESC');
        res.json(result.rows);
    } catch (err) {
        console.error('❌ Duyuru Getirme Hatası:', err.message);
        res.status(500).json({ error: 'Veriler alınamadı' });
    }
});

// 3. Duyuru Sil (DELETE)
app.delete('/api/duyurular/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM duyurular WHERE id = $1 RETURNING id', [id]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Duyuru bulunamadı' });
        }
        
        res.json({ success: true, message: 'Duyuru silindi' });
    } catch (err) {
        console.error('❌ Silme Hatası:', err.message);
        res.status(500).json({ error: 'Silme işlemi başarısız' });
    }
});

// --- SUNUCUYU BAŞLAT ---
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server tüm ağlara açık: http://0.0.0.0:${PORT}`);
});