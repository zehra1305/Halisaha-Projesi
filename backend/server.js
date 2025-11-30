const express = require('express');
const cors = require('cors');
const db = require('./config/database');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Routes
const authRoutes = require('./routes/auth');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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

// Auth routes
app.use('/api/auth', authRoutes);

// Sunucuyu başlat
app.listen(PORT, () => {
    console.log(`🚀 Server http://localhost:${PORT} adresinde çalışıyor`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n📴 Server kapatılıyor...');
    db.end();
    process.exit(0);
});
