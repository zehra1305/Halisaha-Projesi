require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');

const app = express();
const PORT = 3001;
const ADMIN_ID = 1; // Admin'in veritabanındaki ID'si (Sabit)

// Middleware
app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// =============================================================
//  VERİTABANI BAĞLANTISI (Supabase)
// =============================================================
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// Bağlantı Testi
pool.connect((err, client, release) => {
    if (err) {
        console.error('❌ Veritabanı bağlantı hatası:', err.message);
    } else {
        console.log('✅ Supabase Veritabanına başarıyla bağlanıldı!');
        release();
    }
});

// =============================================================
//  MAIL AYARLARI
// =============================================================
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});

let verificationCodes = {};

// Health Check
app.get('/health', (req, res) => {
    res.json({ status: 'Server çalışıyor ✅' });
});

// =============================================================
//  1. ADMIN LOGIN
// =============================================================
app.post('/api/admin-login', async (req, res) => {
    const { email, password } = req.body;
    console.log(`🔐 Login Denemesi: ${email}`);

    const VALID_EMAIL = "ruyahalisaha03@gmail.com";
    const VALID_PASS = "@dmin123";

    if (email === VALID_EMAIL && password === VALID_PASS) {
        console.log("✅ Giriş Başarılı!");
        return res.status(200).json({
            success: true,
            message: "Giriş başarılı",
            data: {
                token: "admin_token_new_secure_123",
                user: { 
                    id: ADMIN_ID.toString(), // Admin ID'yi buradan da gönderiyoruz
                    name: "Rüya Halısaha Admin", 
                    email: email 
                }
            }
        });
    } else {
        console.log("❌ Hatalı Giriş Denemesi");
        return res.status(401).json({ success: false, message: "E-posta veya şifre hatalı!" });
    }
});

// 2. ŞİFREMİ UNUTTUM
app.post('/api/forgot-password', async (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ success: false, message: "E-posta gerekli" });

    if (email !== "ruyahalisaha03@gmail.com") {
        return res.status(404).json({ success: false, message: "Bu e-posta adresi sistemde kayıtlı değil." });
    }

    const code = Math.floor(1000 + Math.random() * 9000).toString();
    verificationCodes[email] = code;

    const mailOptions = {
        from: '"Rüya Halısaha Güvenlik" <halisahasistem@gmail.com>',
        to: email,
        subject: 'Yönetici Şifre Sıfırlama Kodu',
        text: `Doğrulama Kodunuz: ${code}`,
        html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 5px;">
                <h2 style="color: #2E7D32;">Rüya Halısaha Admin Paneli</h2>
                <p>Şifrenizi sıfırlamak için aşağıdaki kodu kullanın:</p>
                <h1 style="background-color: #f1f8e9; color: #2E7D32; padding: 10px; display: inline-block; border-radius: 5px;">${code}</h1>
                <p style="font-size: 12px; color: #666;">Bu işlemi siz yapmadıysanız lütfen dikkate almayın.</p>
            </div>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Mail gönderildi: ${email}`);
        return res.status(200).json({ success: true, message: "Kod gönderildi" });
    } catch (error) {
        console.error("❌ Mail hatası:", error);
        return res.status(500).json({ success: false, message: "Mail gönderilemedi" });
    }
});

// 3. KOD DOĞRULAMA
app.post('/api/verify-code', (req, res) => {
    const { email, code } = req.body;
    if (verificationCodes[email] === code) {
        delete verificationCodes[email];
        return res.status(200).json({ success: true, temporaryToken: "temp_token_verified_123" });
    } else {
        return res.status(400).json({ success: false, message: "Hatalı Kod" });
    }
});

// 4. ŞİFRE SIFIRLAMA ONAY
app.post('/api/reset-password-confirm', (req, res) => {
    console.log("🔐 Şifre değiştirme isteği geldi (Admin şifresi sabit olduğu için işlem simüle edildi).");
    return res.status(200).json({ success: true, message: "Şifre başarıyla güncellendi" });
});

// =============================================================
//  DUYURU İŞLEMLERİ
// =============================================================

app.post('/api/duyurular', async (req, res) => {
    try {
        const { baslik, resim_url, metin } = req.body;
        if (!baslik || !metin) return res.status(400).json({ error: "Eksik veri" });

        const query = `INSERT INTO duyurular (baslik, resim_url, metin) VALUES ($1, $2, $3) RETURNING *`;
        const result = await pool.query(query, [baslik, resim_url, metin]);
        
        return res.status(201).json({ success: true, data: result.rows[0] });
    } catch (err) {
        console.error('❌ DB Ekleme Hatası:', err.message);
        return res.status(500).json({ error: err.message });
    }
});

app.get('/api/duyurular', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM duyurular ORDER BY id DESC');
        return res.json(result.rows);
    } catch (err) {
        console.error('❌ DB Okuma Hatası:', err.message);
        return res.json([]);
    }
});

app.delete('/api/duyurular/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM duyurular WHERE id = $1', [req.params.id]);
        return res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// =============================================================
//  RANDEVU SİSTEMİ
// =============================================================

// 1. Randevuları Listele
app.get('/api/randevular', async (req, res) => {
    try {
        const query = `
            SELECT 
                randevular.*, 
                CONCAT(kullanici.ad, ' ', kullanici.soyad) AS musteri_ad 
            FROM randevular 
            LEFT JOIN kullanici ON randevular.kullanici_id = kullanici.kullanici_id
            ORDER BY randevular.tarih DESC, randevular.saat_baslangic ASC
        `;
        
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error('Randevu listeleme hatası:', err.message);
        res.status(500).json([]);
    }
});

// 2. Randevu Ekle (Mobil Uygulamadan Gelen İstekler İçin)
app.post('/api/randevular', async (req, res) => {
    try {
        const { kullanici_id, telefon, saha, tarih, saat_baslangic, saat_bitis, aciklama } = req.body;
        
        const query = `
            INSERT INTO randevular (kullanici_id, telefon, saha, tarih, saat_baslangic, saat_bitis, aciklama, durum) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, 'beklemede') 
            RETURNING *
        `;
        const values = [kullanici_id, telefon, saha, tarih, saat_baslangic, saat_bitis, aciklama];
        
        const result = await pool.query(query, values);
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (err) {
        console.error('Randevu ekleme hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// 3. Randevu Durumu Güncelle (ONAYLA / İPTAL)
app.put('/api/randevular/:id/durum', async (req, res) => {
    try {
        const { id } = req.params;
        const { durum } = req.body; // 'onaylandi' veya 'beklemede'

        const result = await pool.query(
            'UPDATE randevular SET durum = $1 WHERE randevu_id = $2 RETURNING *',
            [durum, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: "Randevu bulunamadı" });
        }

        res.json({ success: true, message: "Durum güncellendi", data: result.rows[0] });
    } catch (err) {
        console.error('Randevu güncelleme hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// =============================================================
//  MÜŞTERİ (KULLANICI) İŞLEMLERİ
// =============================================================

// Müşterileri Listele
app.get('/api/kullanicilar', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM kullanici ORDER BY kullanici_id DESC');
        res.json(result.rows);
    } catch (err) {
        console.error('Kullanıcı listeleme hatası:', err.message);
        res.status(500).json([]);
    }
});

// Müşteri Sil
app.delete('/api/kullanicilar/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM randevular WHERE kullanici_id = $1', [id]);
        await pool.query('DELETE FROM kullanici WHERE kullanici_id = $1', [id]);
        res.json({ success: true, message: "Kullanıcı silindi." });
    } catch (err) {
        console.error('Kullanıcı silme hatası:', err.message);
        res.status(500).json({ error: "Silme işlemi başarısız." });
    }
});

// =============================================================
//  SOHBET VE MESAJ İŞLEMLERİ (GİZLİLİK FİLTRELİ 🔒)
// =============================================================

// 1. Sohbetleri Listele (SADECE Admin'i İlgilendirenler)
app.get('/api/sohbetler', async (req, res) => {
    try {
        const query = `
            SELECT 
                sohbet.sohbet_id,
                sohbet.olusturma_zamani,
                CASE 
                    WHEN sohbet.baslatan_id = $1 THEN CONCAT(k2.ad, ' ', k2.soyad)
                    ELSE CONCAT(k1.ad, ' ', k1.soyad)
                END AS karsi_taraf_ad
            FROM sohbet
            LEFT JOIN kullanici k1 ON sohbet.baslatan_id = k1.kullanici_id
            LEFT JOIN kullanici k2 ON sohbet.ilan_sahibi_id = k2.kullanici_id
            WHERE sohbet.baslatan_id = $1 OR sohbet.ilan_sahibi_id = $1
            ORDER BY sohbet.olusturma_zamani DESC
        `;
        const result = await pool.query(query, [ADMIN_ID]);
        res.json(result.rows);
    } catch (err) {
        console.error('Sohbet listeleme hatası:', err.message);
        res.status(500).json([]);
    }
});

// 2. Mesajları Getir
app.get('/api/mesajlar/:sohbetId', async (req, res) => {
    try {
        const { sohbetId } = req.params;
        const query = `
            SELECT 
                mesaj.*, 
                CONCAT(kullanici.ad, ' ', kullanici.soyad) AS gonderen_ad 
            FROM mesaj
            LEFT JOIN kullanici ON mesaj.gonderen_id = kullanici.kullanici_id
            WHERE sohbet_id = $1
            ORDER BY gonderme_zamani ASC
        `;
        const result = await pool.query(query, [sohbetId]);
        res.json(result.rows);
    } catch (err) {
        console.error('Mesajları getirme hatası:', err.message);
        res.status(500).json([]);
    }
});

// 3. Mesaj Gönder (Admin veya Mobil Kullanıcı İçin Güncellendi ✅)
app.post('/api/mesajlar', async (req, res) => {
    try {
        const { sohbet_id, icerik, gonderen_id } = req.body;
        
        // MANTIK: Eğer gonderen_id gelirse onu kullan, gelmezse Admin kabul et.
        const sender = gonderen_id || ADMIN_ID; 

        const query = `
            INSERT INTO mesaj (sohbet_id, gonderen_id, icerik) 
            VALUES ($1, $2, $3) 
            RETURNING *
        `;
        const result = await pool.query(query, [sohbet_id, sender, icerik]);
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (err) {
        console.error('Mesaj gönderme hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// =============================================================
//  MOBİL UYGULAMA İÇİN: DESTEK SOHBETİ BAŞLAT
// =============================================================
app.post('/api/support/start', async (req, res) => {
    try {
        const { kullanici_id } = req.body; 
        
        // 1. Bu kullanıcı ile Admin arasında zaten bir sohbet var mı?
        const checkQuery = `
            SELECT sohbet_id FROM sohbet 
            WHERE (baslatan_id = $1 AND ilan_sahibi_id = $2) 
               OR (baslatan_id = $2 AND ilan_sahibi_id = $1)
        `;
        const existingChat = await pool.query(checkQuery, [kullanici_id, ADMIN_ID]);

        if (existingChat.rows.length > 0) {
            return res.json({ success: true, sohbet_id: existingChat.rows[0].sohbet_id, isNew: false });
        }

        // 2. Yoksa, yeni bir sohbet oluştur
        // ilan_id varsayılan olarak 2 veriyoruz (Hata almamak için)
        const createQuery = `
            INSERT INTO sohbet (baslatan_id, ilan_sahibi_id, ilan_id, olusturma_zamani) 
            VALUES ($1, $2, 2, NOW()) 
            RETURNING sohbet_id
        `;
        const newChat = await pool.query(createQuery, [kullanici_id, ADMIN_ID]);

        return res.json({ success: true, sohbet_id: newChat.rows[0].sohbet_id, isNew: true });

    } catch (err) {
        console.error('Destek sohbeti başlatma hatası:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// =============================================================
//  SERVER BAŞLAT
// =============================================================
app.listen(PORT, () => {
    console.log(`\n🚀 Server çalışıyor: http://localhost:${PORT}`);
    console.log(`👤 Yetkili: ruyahalisaha03@gmail.com`);
    console.log(`📡 API Randevu Endpoint: http://localhost:${PORT}/api/randevular`);
});