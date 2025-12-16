const db = require('../config/database');

// Tüm ilanları getir
exports.getAllIlanlar = async (req, res) => {
    try {
        const result = await db.query(`
            SELECT 
                ilan_id as id,
                ad_soyad as "adSoyad",
                baslik,
                konum,
                tarih,
                saat,
                kisi_sayisi as "kisiSayisi",
                mevki,
                seviye,
                ucret,
                aciklama,
                yas,
                kullanici_id as "userId",
                olusturma_tarihi as "olusturmaTarihi"
            FROM ilanlar 
            ORDER BY olusturma_tarihi DESC
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
                ilan_id as id,
                ad_soyad as "adSoyad",
                baslik,
                konum,
                tarih,
                saat,
                kisi_sayisi as "kisiSayisi",
                mevki,
                seviye,
                ucret,
                aciklama,
                yas,
                kullanici_id as "userId",
                olusturma_tarihi as "olusturmaTarihi"
            FROM ilanlar 
            WHERE ilan_id = $1
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
        console.log('Gelen ilan verisi:', req.body);
        
        const {
            adSoyad,
            baslik,
            konum,
            tarih,
            saat,
            kisiSayisi,
            mevki,
            seviye,
            ucret,
            aciklama,
            yas,
            userId
        } = req.body;

        // Zorunlu alanları kontrol et
        if (!adSoyad || !baslik || !konum || !tarih || !saat || !kisiSayisi || !mevki) {
            console.log('Eksik alanlar:', { adSoyad, baslik, konum, tarih, saat, kisiSayisi, mevki });
            return res.status(400).json({ 
                message: 'Zorunlu alanlar eksik' 
            });
        }

        const result = await db.query(`
            INSERT INTO ilanlar (
                ad_soyad, 
                baslik, 
                konum, 
                tarih, 
                saat, 
                kisi_sayisi, 
                mevki, 
                seviye, 
                ucret, 
                aciklama, 
                yas, 
                kullanici_id
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            RETURNING 
                ilan_id as id,
                ad_soyad as "adSoyad",
                baslik,
                konum,
                tarih,
                saat,
                kisi_sayisi as "kisiSayisi",
                mevki,
                seviye,
                ucret,
                aciklama,
                yas,
                kullanici_id as "userId",
                olusturma_tarihi as "olusturmaTarihi"
        `, [adSoyad, baslik, konum, tarih, saat, kisiSayisi, mevki, seviye, ucret, aciklama, yas, userId]);

        return res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('İlan oluşturma hatası:', err);
        return res.status(500).json({ 
            message: 'İlan oluşturulurken hata oluştu',
            error: err.message 
        });
    }
};

// İlan güncelle
exports.updateIlan = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            adSoyad,
            baslik,
            konum,
            tarih,
            saat,
            kisiSayisi,
            mevki,
            seviye,
            ucret,
            aciklama,
            yas
        } = req.body;

        const result = await db.query(`
            UPDATE ilanlar 
            SET 
                ad_soyad = COALESCE($1, ad_soyad),
                baslik = COALESCE($2, baslik),
                konum = COALESCE($3, konum),
                tarih = COALESCE($4, tarih),
                saat = COALESCE($5, saat),
                kisi_sayisi = COALESCE($6, kisi_sayisi),
                mevki = COALESCE($7, mevki),
                seviye = COALESCE($8, seviye),
                ucret = COALESCE($9, ucret),
                aciklama = COALESCE($10, aciklama),
                yas = COALESCE($11, yas)
            WHERE ilan_id = $12
            RETURNING 
                ilan_id as id,
                ad_soyad as "adSoyad",
                baslik,
                konum,
                tarih,
                saat,
                kisi_sayisi as "kisiSayisi",
                mevki,
                seviye,
                ucret,
                aciklama,
                yas,
                kullanici_id as "userId",
                olusturma_tarihi as "olusturmaTarihi"
        `, [adSoyad, baslik, konum, tarih, saat, kisiSayisi, mevki, seviye, ucret, aciklama, yas, id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'İlan bulunamadı' 
            });
        }

        return res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('İlan güncelleme hatası:', err);
        return res.status(500).json({ 
            message: 'İlan güncellenirken hata oluştu',
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

// Kullanıcıya ait ilanları getir
exports.getIlanlarByUserId = async (req, res) => {
    try {
        const { userId } = req.params;

        const result = await db.query(`
            SELECT 
                ilan_id as id,
                ad_soyad as "adSoyad",
                baslik,
                konum,
                tarih,
                saat,
                kisi_sayisi as "kisiSayisi",
                mevki,
                seviye,
                ucret,
                aciklama,
                yas,
                kullanici_id as "userId",
                olusturma_tarihi as "olusturmaTarihi"
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
