const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const fs = require('fs');
const path = require('path');
const uploadProfilePhoto = require('../middleware/uploadProfile');
const pool = require('../config/database');
const multer = require('multer');

// Basit veri doğrulama fonksiyonu
const validateProfileData = (data) => {
    const { ad, soyad, telefon, sifre } = data;
    
    // Ad ve soyad zorunludur
    if (!ad || !soyad) {
        return 'Ad ve Soyad alanları boş bırakılamaz.';
    }
    
    // Telefon kontrolü
    if (telefon && !/^\d{11}$/.test(telefon)) {
        return 'Geçerli bir telefon numarası giriniz.';
    }
    
    // Şifre kontrolü
    if (sifre && sifre.length < 8) {
        return 'Şifre en az 8 karakter uzunluğunda olmalıdır.';
    }
    
    return null;
};

// =================================================================
// GET: KULLANICININ MEVCUT BİLGİLERİNİ ÇEKME ROTASI
// Rota: /profile/:id
// =================================================================
router.get('/profile/:id', async (req, res) => {
    const requestedUserId = req.params.id;
    const loggedInUserId = req.session.kullanici_id ? req.session.kullanici_id.toString() : null;

    // Yetkilendirme kontrolü
    if (!loggedInUserId || requestedUserId !== loggedInUserId) {
        return res.status(403).json({ 
            success: false, 
            message: 'Bu profile erişim yetkiniz yok veya oturum açılmamış.' 
        });
    }

    try {
        const query = `
            SELECT kullanici_id, email, ad, soyad, telefon, profil_foto_url 
            FROM kullanici 
            WHERE kullanici_id = $1;
        `;
        const result = await pool.query(query, [requestedUserId]);

        if (result.rowCount === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Kullanıcı bulunamadı.' 
            });
        }

        res.status(200).json({ 
            success: true, 
            data: result.rows[0] 
        });

    } catch (dbError) {
        console.error('Veritabanından Veri Çekme Hatası:', dbError);
        res.status(500).json({ 
            success: false, 
            message: 'Sunucu hatası: Profil bilgileri alınamadı.' 
        });
    }
});

// =================================================================
// POST: PROFİL GÜNCELLEME ROTASI
// Rota: /profile/update/:id
// =================================================================
router.post('/profile/update/:id', (req, res) => {
    const requestedUserId = req.params.id;
    const loggedInUserId = req.session.kullanici_id ? req.session.kullanici_id.toString() : null;

    // Yetkilendirme kontrolü
    if (!loggedInUserId || requestedUserId !== loggedInUserId) {
        return res.status(403).json({ 
            success: false, 
            message: 'Bu profili güncelleme yetkiniz yok veya oturum açılmamış.' 
        });
    }
    
    // Multer ile dosya yükleme
    uploadProfilePhoto(req, res, async (err) => {
        // Multer hata kontrolü
        if (err) {
            const errorMessage = err instanceof multer.MulterError 
                               ? `Dosya yükleme hatası: ${err.message}` 
                               : err.message;
            console.error('Multer Hatası:', errorMessage);
            return res.status(400).json({ 
                success: false, 
                message: errorMessage 
            });
        }
        
        // Veri doğrulama
        const validationError = validateProfileData(req.body);
        if (validationError) {
            return res.status(400).json({ 
                success: false, 
                message: validationError 
            });
        }

        const userIdToUpdate = requestedUserId;
        const { ad, soyad, telefon, sifre } = req.body;
        const newPhotoName = req.file ? req.file.filename : null;
        
        let oldPhotoName = null;
        
        try {
            // Eski fotoğrafı al
            if (newPhotoName) {
                const oldPhotoQuery = 'SELECT profil_foto_url FROM kullanici WHERE kullanici_id = $1';
                const oldPhotoResult = await pool.query(oldPhotoQuery, [userIdToUpdate]);
                if (oldPhotoResult.rowCount > 0 && oldPhotoResult.rows[0].profil_foto_url) {
                    oldPhotoName = oldPhotoResult.rows[0].profil_foto_url;
                }
            }

            let setClauses = [];
            const updateValues = [];
            let paramIndex = 1;
            
            // Şifre güncelleme
            if (sifre) {
                const saltRounds = 10;
                const newHashedPassword = await bcrypt.hash(sifre, saltRounds);
                setClauses.push(`sifre_hash = $${paramIndex}`);
                updateValues.push(newHashedPassword);
                paramIndex++;
            }
            
            // Diğer alanlar
            setClauses.push(`ad = COALESCE($${paramIndex}, ad)`);
            updateValues.push(ad);
            paramIndex++;
            
            setClauses.push(`soyad = COALESCE($${paramIndex}, soyad)`);
            updateValues.push(soyad);
            paramIndex++;

            setClauses.push(`telefon = COALESCE($${paramIndex}, telefon)`);
            updateValues.push(telefon);
            paramIndex++;

            setClauses.push(`profil_foto_url = COALESCE($${paramIndex}, profil_foto_url)`);
            updateValues.push(newPhotoName);
            paramIndex++;
            
            updateValues.push(userIdToUpdate);
            const whereIndex = paramIndex;
            
            // UPDATE sorgusu
            const userUpdateQuery = `
                UPDATE kullanici 
                SET ${setClauses.join(', ')}
                WHERE kullanici_id = $${whereIndex} 
                RETURNING kullanici_id, ad, soyad, email, telefon, profil_foto_url;
            `;
            
            const result = await pool.query(userUpdateQuery, updateValues);

            if (result.rowCount === 0) {
                return res.status(404).json({ 
                    success: false, 
                    message: 'Kullanıcı bulunamadı.' 
                });
            }
            
            // Eski fotoğrafı sil
            if (oldPhotoName) {
                const rootdir = path.dirname(require.main.filename);
                const oldPhotoPath = path.join(rootdir, 'public/uploads', oldPhotoName);
                
                try {
                    fs.unlinkSync(oldPhotoPath);
                    console.log(`Eski dosya başarıyla silindi: ${oldPhotoName}`);
                } catch (unlinkError) {
                    console.error(`Eski dosya silinemedi: ${oldPhotoName}. Hata:`, unlinkError.message);
                }
            }

            // Başarılı yanıt
            res.status(200).json({ 
                success: true, 
                message: sifre ? 'Profil ve şifre başarıyla güncellendi.' : 'Profil bilgileri başarıyla güncellendi.',
                data: result.rows[0] 
            });

        } catch (dbError) {
            console.error('Veritabanı Güncelleme Hatası:', dbError);
            
            // Hata durumunda yeni dosyayı sil
            if (newPhotoName) {
                const rootdir = path.dirname(require.main.filename);
                const newPhotoPath = path.join(rootdir, 'public/uploads', newPhotoName);
                try {
                    fs.unlinkSync(newPhotoPath);
                    console.log(`Hata nedeniyle yeni dosya geri alındı: ${newPhotoName}`);
                } catch (unlinkError) {
                    console.error(`Geri alınan yeni dosya silinemedi: ${newPhotoName}. Hata:`, unlinkError.message);
                }
            }
            
            // Duplicate key hatası
            if (dbError.code === '23505') {
                return res.status(409).json({ 
                    success: false, 
                    message: 'Bu telefon numarası zaten başka bir kullanıcı tarafından kullanılıyor.' 
                });
            }
            
            res.status(500).json({ 
                success: false, 
                message: 'Sunucu hatası: Profil güncellenemedi.' 
            });
        }
    });
});

// =================================================================
// POST: RESİM YÜKLEME ROTASI
// Rota: /upload-image
// =================================================================
router.post("/upload-image", function(req, res) {
    uploadProfilePhoto(req, res, function(err) {
        if (err instanceof multer.MulterError) {
            console.error('Multer Hatası:', err);
            return res.status(400).json({
                success: false,
                message: `Dosya yüklenirken multer kaynaklı hata oluştu: ${err.message}`
            });
        } else if (err) {
            console.error('Dosya Yükleme Hatası:', err);
            return res.status(400).json({
                success: false,
                message: `Dosya yüklenirken hata oluştu: ${err.message}`
            });
        } else {
            // Başarılı yükleme
            return res.status(200).json({
                success: true,
                message: "Dosya başarıyla yüklendi",
                data: req.savedimage || []
            });
        }
    });
});

module.exports = router;
