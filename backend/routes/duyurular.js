const express = require('express');
const router = express.Router();
const db = require('../config/database'); // Arkadaşının veritabanı bağlantısı

// 1. Duyuru Ekleme (POST)
router.post('/', async (req, res) => {
    try {
        // İsteğin içinden baslik, resim_url ve metin alıyoruz
        const { baslik, resim_url, metin } = req.body;
        
        console.log('📨 Yeni Duyuru İsteği:', { baslik, metin });
        
        // Basit doğrulama
        if (!baslik || !resim_url || !metin) {
            return res.status(400).json({ error: "baslik, resim_url ve metin zorunludur" });
        }

        // Veritabanına ekleme sorgusu
        const query = `
            INSERT INTO duyurular (baslik, resim_url, metin) 
            VALUES ($1, $2, $3) 
            RETURNING id, baslik, resim_url, metin, tarih
        `;
        
        const result = await db.query(query, [baslik, resim_url, metin]);
        
        res.status(201).json({
            success: true,
            message: "Duyuru başarıyla eklendi",
            data: result.rows[0]
        });

    } catch (err) {
        console.error('❌ Duyuru Ekleme Hatası:', err.message);
        res.status(500).json({ error: 'Sunucu hatası oluştu: ' + err.message });
    }
});

// 2. Duyuruları Getir (GET)
router.get('/', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM duyurular ORDER BY id DESC');
        res.json(result.rows);
    } catch (err) {
        console.error('❌ Duyuru Getirme Hatası:', err.message);
        res.status(500).json({ error: 'Veriler alınamadı' });
    }
});

// 3. Duyuru Sil (DELETE)
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await db.query('DELETE FROM duyurular WHERE id = $1 RETURNING id', [id]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Duyuru bulunamadı' });
        }
        
        res.json({ success: true, message: 'Duyuru silindi' });
    } catch (err) {
        console.error('❌ Silme Hatası:', err.message);
        res.status(500).json({ error: 'Silme işlemi başarısız' });
    }
});

module.exports = router;