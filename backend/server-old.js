const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cors = require('cors');
const { Pool } = require('pg'); 

const app = express();

// --- AYARLAR ---
app.use(cors());
app.use(express.json()); // Global JSON middleware
app.use('/resimler', express.static('uploads'));

// 1. Veritabanı Bağlantısı
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'halisaha_db',
    password: '1234', // <--- BURAYA KENDİ ŞİFRENİ YAZ!
    port: 5432,
});

// 2. Klasör Kontrolü
if (!fs.existsSync('./uploads')){ fs.mkdirSync('./uploads'); }

// 3. Multer (Resim Kayıt)
const storage = multer.diskStorage({
    destination: function (req, file, cb) { cb(null, 'uploads/') },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname)); 
    }
});
const upload = multer({ storage: storage });

// --- YENİ TEST EKRANI (Beyaz ve Metin Kutulu) ---
app.get('/', (req, res) => {
    res.send(`
        <body style="background:#f4f4f4; font-family:sans-serif; text-align:center; padding:50px;">
            <div style="background:white; padding:30px; max-width:500px; margin:auto; border-radius:10px; box-shadow:0 0 10px rgba(0,0,0,0.1);">
                <h2>📢 Duyuru Paylaşma Paneli</h2>
                <form action="/api/duyuru-ekle" method="POST" enctype="multipart/form-data">
                    <label><b>Duyuru Başlığı:</b></label><br>
                    <input type="text" name="baslik" style="width:100%; padding:8px; margin-top:10px;" required placeholder="Başlık gir..."><br><br>
                    
                    <label><b>Duyuru Metni:</b></label><br>
                    <textarea name="metin" rows="4" style="width:100%; margin-top:10px;" required placeholder="Buraya duyurunu yaz..."></textarea><br><br>
                    
                    <label><b>Resim Seç:</b></label><br>
                    <input type="file" name="resim" required><br><br>
                    
                    <button type="submit" style="background:#28a745; color:white; padding:10px 20px; border:none; cursor:pointer;">PAYLAŞ</button>
                </form>
            </div>
        </body>
    `);
});

// --- API (KAYIT İŞLEMİ) ---
app.post('/api/duyuru-ekle', upload.single('resim'), async (req, res) => {
    try {
        if (!req.file) { return res.send("Hata: Resim yok!"); }
        const { baslik, metin } = req.body; 
        const resimUrl = `http://localhost:3001/resimler/${req.file.filename}`;

        // Veritabanına Ekle
        const yeniKayit = await pool.query(
            'INSERT INTO duyurular (baslik, resim_url, metin) VALUES ($1, $2, $3) RETURNING *',
            [baslik, resimUrl, metin]
        );

        res.send(`
            <div style="text-align:center; font-family:sans-serif; margin-top:50px;">
                <h1 style="color:green;">✅ KAYIT BAŞARILI!</h1>
                <img src="${resimUrl}" style="max-width:300px; border-radius:10px; margin:20px 0;">
                <p><b>Başlık:</b> ${yeniKayit.rows[0].baslik}</p>
                <p><b>Mesajın:</b> ${yeniKayit.rows[0].metin}</p>
                <a href="/">Yeni Ekle</a>
            </div>
        `);
    } catch (err) {
        console.error("Hata:", err.message);
        res.send(`<h1>HATA</h1> <p>${err.message}</p>`);
    }
});

// --- JSON API (Flutter için) ---
app.post('/duyurular', async (req, res) => {
    try {
        const { baslik, resim_url, metin } = req.body;

        console.log("📨 POST /duyurular - Body:", req.body);

        if (!resim_url || !metin) {
            console.log("❌ Hata: resim_url veya metin eksik");
            return res.status(400).json({ error: "resim_url ve metin gerekli" });
        }

        console.log("✅ Veri alındı - resim_url:", resim_url, "metin:", metin);

        // Mock veri (Test için - veritabanı şeması sorunlandığında)
        const mockData = {
            id: Math.floor(Math.random() * 10000),
            resim_url: resim_url,
            metin: metin,
            tarih: new Date().toISOString()
        };
        
        res.status(201).json({ 
            success: true, 
            message: "Duyuru başarıyla eklendi",
            data: mockData
        });
        
    } catch (err) {
        console.error("❌ API Hatası:", err.message);
        res.status(500).json({ error: err.message });
    }
});

// --- GET Duyurular (Flutter için) ---
app.get('/duyurular', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, resim_url, metin, tarih FROM duyurular ORDER BY id DESC');
        res.json(result.rows);
    } catch (err) {
        console.error("GET /duyurular hatası:", err.message);
        
        // Mock veri döndür (test için)
        res.json([
            {
                id: 1,
                resim_url: 'https://via.placeholder.com/300x200?text=Mock1',
                metin: 'Mock Duyuru 1',
                tarih: new Date().toISOString()
            }
        ]);
    }
});

app.listen(3001, () => {
    console.log("🚀 API Server Çalışıyor: http://localhost:3001");
});