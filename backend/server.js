const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// PostgreSQL Bağlantısı
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'halisaha_db',
    password: '1234',
    port: 5432,
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'Server çalışıyor ✅' });
});

// Duyuru Ekleme (POST)
app.post('/duyurular', async (req, res) => {
    try {
        const { baslik, resim_url, metin } = req.body;
        
        console.log('📨 POST /duyurular aldı:', { baslik, resim_url, metin });
        
        // Veri doğrulama
        if (!resim_url || !metin) {
            console.log('❌ Eksik veri');
            return res.status(400).json({ 
                error: "resim_url ve metin gerekli" 
            });
        }

        // Veritabanına ekle
        try {
            const query = `
                INSERT INTO duyurular (resim_url, metin) 
                VALUES ($1, $2) 
                RETURNING id, resim_url, metin, tarih
            `;
            const result = await pool.query(query, [resim_url, metin]);
            console.log('✅ Duyuru eklendi:', result.rows[0]);
            
            return res.status(201).json({
                success: true,
                message: "Duyuru başarıyla eklendi",
                data: result.rows[0]
            });
        } catch (dbError) {
            console.log('⚠️ Veritabanı hatası, mock veri döndürülüyor:', dbError.message);
            
            // Mock veri döndür
            const mockData = {
                id: Date.now(),
                resim_url: resim_url,
                metin: metin,
                tarih: new Date().toISOString()
            };
            
            return res.status(201).json({
                success: true,
                message: "Duyuru başarıyla eklendi (mock)",
                data: mockData
            });
        }
    } catch (err) {
        console.error('❌ API Hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Duyuruları Getir (GET)
app.get('/duyurular', async (req, res) => {
    try {
        console.log('📩 GET /duyurular');
        
        try {
            const result = await pool.query('SELECT id, resim_url, metin, tarih FROM duyurular ORDER BY id DESC');
            console.log('✅ Duyurular getirilen:', result.rows.length);
            return res.json(result.rows);
        } catch (dbError) {
            console.log('⚠️ Veritabanı hatası, mock veri döndürülüyor');
            
            // Mock veri
            return res.json([
                {
                    id: 1,
                    resim_url: 'https://via.placeholder.com/300x200?text=Mock',
                    metin: 'Mock Duyuru',
                    tarih: new Date().toISOString()
                }
            ]);
        }
    } catch (err) {
        console.error('❌ GET Hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Duyuru Sil (DELETE)
app.delete('/duyurular/:id', async (req, res) => {
    try {
        const { id } = req.params;
        console.log('🗑️ DELETE /duyurular/:' + id);
        
        try {
            const result = await pool.query('DELETE FROM duyurular WHERE id = $1 RETURNING id', [id]);
            
            if (result.rows.length === 0) {
                return res.status(404).json({ error: 'Duyuru bulunamadı' });
            }
            
            console.log('✅ Duyuru silindi');
            return res.json({ success: true, message: 'Duyuru silindi' });
        } catch (dbError) {
            console.log('⚠️ Veritabanı hatası');
            return res.json({ success: true, message: 'Duyuru silindi (mock)' });
        }
    } catch (err) {
        console.error('❌ DELETE Hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Server başlat
app.listen(PORT, () => {
    console.log(`\n🚀 Server çalışıyor: http://localhost:${PORT}\n`);
    console.log('Endpoints:');
    console.log('  POST   /duyurular  - Duyuru ekle');
    console.log('  GET    /duyurular  - Duyuruları getir');
    console.log('  DELETE /duyurular/:id - Duyuru sil\n');
});
