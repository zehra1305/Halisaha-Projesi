const db = require('../config/database');

// Tüm ilanları getir
exports.getAllIlanlar = async (req, res) => {
    try {
        const result = await db.query(`
            SELECT 
                i.ilan_id,
                i.baslik,
                i.aciklama,
                i.tarih,
                i.saat,
                i.konum,
                i.kisi_sayisi,
                i.mevki,
                i.seviye,
                i.ucret,
                i.kullanici_id,
                i.olusturma_tarihi,
                CONCAT(k.ad, ' ', k.soyad) as kullanici_adi,
                k.profil_fotografi
            FROM ilanlar i
            LEFT JOIN kullanici k ON i.kullanici_id = k.kullanici_id
            ORDER BY i.olusturma_tarihi DESC
        `);

        return res.status(200).json(result.rows);
    } catch (err) {
        console.error('İlanlar getirme hatası:', err);
        return res.status(500).json({ 
            message: 'İlanlar yüklenirken hata oluştu',
            error: err.message 
        });
    }
};

// Tek bir ilan getir
exports.getIlanById = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await db.query(`
            SELECT 
                i.ilan_id,
                i.baslik,
                i.aciklama,
                i.tarih,
                i.saat,
                i.konum,
                i.kisi_sayisi,
                i.mevki,
                i.seviye,
                i.ucret,
                i.kullanici_id,
                i.olusturma_tarihi,
                CONCAT(k.ad, ' ', k.soyad) as kullanici_adi,
                k.profil_fotografi,
                k.telefon
            FROM ilanlar i
            LEFT JOIN kullanici k ON i.kullanici_id = k.kullanici_id
            WHERE i.ilan_id = $1
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'İlan bulunamadı' 
            });
        }

        return res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('İlan getirme hatası:', err);
        return res.status(500).json({ 
            message: 'İlan yüklenirken hata oluştu',
            error: err.message 
        });
    }
};

// Yeni ilan oluştur
exports.createIlan = async (req, res) => {
    try {
        console.log('İlan oluşturma isteği:', req.body);
        
        const {
            baslik,
            aciklama,
            tarih,
            saat,
            konum,
            kisiSayisi,
            mevki,
            seviye,
            ucret,
            kullaniciId
        } = req.body;

        // Zorunlu alanları kontrol et (açıklama, kisiSayisi, mevki, seviye, ucret opsiyonel)
        if (!baslik || !tarih || !saat || !konum || !kullaniciId) {
            console.log('Eksik alanlar:', { baslik, tarih, saat, konum, kullaniciId });
            return res.status(400).json({ 
                message: 'Zorunlu alanlar eksik' 
            });
        }

        const result = await db.query(`
            INSERT INTO ilanlar (
                baslik, 
                aciklama, 
                tarih, 
                saat, 
                konum,
                kisi_sayisi,
                mevki,
                seviye,
                ucret,
                kullanici_id
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            RETURNING *
        `, [baslik, aciklama || null, tarih, saat, konum, kisiSayisi || null, mevki || null, seviye || null, ucret || null, kullaniciId]);

        return res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('İlan oluşturma hatası:', err);
        return res.status(500).json({ 
            message: 'İlan oluşturulurken hata oluştu',
            error: err.message 
        });
    }
};

// İlan sil
exports.deleteIlan = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await db.query(
            'DELETE FROM ilanlar WHERE ilan_id = $1 RETURNING ilan_id',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'İlan bulunamadı' 
            });
        }

        return res.status(200).json({ 
            message: 'İlan başarıyla silindi',
            id: result.rows[0].ilan_id
        });
    } catch (err) {
        console.error('İlan silme hatası:', err);
        return res.status(500).json({ 
            message: 'İlan silinirken hata oluştu',
            error: err.message 
        });
    }
};

// İlan güncelle
exports.updateIlan = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            baslik,
            aciklama,
            tarih,
            saat,
            konum,
            kisiSayisi,
            mevki,
            seviye,
            ucret
        } = req.body;

        // İlan var mı kontrol et
        const checkIlan = await db.query(
            'SELECT ilan_id FROM ilanlar WHERE ilan_id = $1',
            [id]
        );

        if (checkIlan.rows.length === 0) {
            return res.status(404).json({ 
                message: 'İlan bulunamadı' 
            });
        }

        const result = await db.query(`
            UPDATE ilanlar 
            SET baslik = $1,
                aciklama = $2,
                tarih = $3,
                saat = $4,
                konum = $5,
                kisi_sayisi = $6,
                mevki = $7,
                seviye = $8,
                ucret = $9
            WHERE ilan_id = $10
            RETURNING *
        `, [baslik, aciklama || null, tarih, saat, konum, kisiSayisi || null, mevki || null, seviye || null, ucret || null, id]);

        return res.status(200).json({
            message: 'İlan başarıyla güncellendi',
            data: result.rows[0]
        });
    } catch (err) {
        console.error('İlan güncelleme hatası:', err);
        return res.status(500).json({ 
            message: 'İlan güncellenirken hata oluştu',
            error: err.message 
        });
    }
};

// Kullanıcıya ait ilanları getir
exports.getIlanlarByUserId = async (req, res) => {
    try {
        const { userId } = req.params;

        const result = await db.query(`
            SELECT 
                ilan_id,
                baslik,
                aciklama,
                tarih,
                saat,
                konum,
                kullanici_id,
                olusturma_tarihi
            FROM ilanlar 
            WHERE kullanici_id = $1
            ORDER BY olusturma_tarihi DESC
        `, [userId]);

        return res.status(200).json(result.rows);
    } catch (err) {
        console.error('Kullanıcı ilanları getirme hatası:', err);
        return res.status(500).json({ 
            message: 'İlanlar yüklenirken hata oluştu',
            error: err.message 
        });
    }
};
