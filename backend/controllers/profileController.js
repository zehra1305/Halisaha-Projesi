const db = require('../config/database');
const crypto = require('crypto');
const path = require('path');
const fs = require('fs');

// Şifre hash'leme
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

// Profil bilgilerini getir
exports.getProfile = async (req, res) => {
    try {
        const { userId } = req.params;

        if (!userId) {
            return res.status(400).json({ 
                message: 'Kullanıcı ID gereklidir' 
            });
        }

        const result = await db.query(
            'SELECT kullanici_id, email, ad, soyad, telefon, profil_fotografi, kayit_tarihi FROM kullanici WHERE kullanici_id = $1',
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı' 
            });
        }

        const user = result.rows[0];

        // Profil fotoğrafı için tam URL oluştur
        let profileImageUrl = null;
        if (user.profil_fotografi) {
            // Eğer zaten http ile başlıyorsa olduğu gibi kullan
            if (user.profil_fotografi.startsWith('http')) {
                profileImageUrl = user.profil_fotografi;
            } else {
                // Android emülatör için 10.0.2.2 kullan
                // Eğer path / ile başlıyorsa ekstra / ekleme
                const path = user.profil_fotografi.startsWith('/') ? user.profil_fotografi.substring(1) : user.profil_fotografi;
                profileImageUrl = `http://10.0.2.2:3001/${path}`;
            }
        }

        return res.status(200).json({
            success: true,
            data: {
                id: user.kullanici_id,
                name: `${user.ad} ${user.soyad}`.trim(),
                email: user.email,
                phone: user.telefon,
                profileImage: profileImageUrl,
                createdAt: user.kayit_tarihi
            }
        });

    } catch (err) {
        console.error('Profil getirme hatası:', err);
        return res.status(500).json({ 
            message: 'Profil bilgileri alınırken hata oluştu',
            error: err.message 
        });
    }
};

// Profil bilgilerini güncelle
exports.updateProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const { name, phone } = req.body;

        if (!userId) {
            return res.status(400).json({ 
                message: 'Kullanıcı ID gereklidir' 
            });
        }

        // Kullanıcı var mı kontrol et
        const checkUser = await db.query(
            'SELECT kullanici_id FROM kullanici WHERE kullanici_id = $1',
            [userId]
        );

        if (checkUser.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı' 
            });
        }

        // Ad soyad ayır
        let ad, soyad;
        if (name) {
            const nameParts = name.trim().split(' ');
            ad = nameParts[0];
            soyad = nameParts.slice(1).join(' ') || '';
        }

        // Telefon başka kullanıcıda var mı kontrol et
        if (phone) {
            const checkPhone = await db.query(
                'SELECT kullanici_id FROM kullanici WHERE telefon = $1 AND kullanici_id != $2',
                [phone, userId]
            );

            if (checkPhone.rows.length > 0) {
                return res.status(400).json({ 
                    message: 'Bu telefon numarası başka bir kullanıcı tarafından kullanılıyor' 
                });
            }
        }

        // Güncellenecek alanları belirle
        const updates = [];
        const values = [];
        let paramIndex = 1;

        if (name) {
            updates.push(`ad = $${paramIndex}`);
            values.push(ad);
            paramIndex++;
            
            updates.push(`soyad = $${paramIndex}`);
            values.push(soyad);
            paramIndex++;
        }

        if (phone !== undefined) {
            updates.push(`telefon = $${paramIndex}`);
            values.push(phone || null);
            paramIndex++;
        }

        if (updates.length === 0) {
            return res.status(400).json({ 
                message: 'Güncellenecek alan belirtilmedi' 
            });
        }

        // Son parametre userId
        values.push(userId);

        // Profili güncelle
        const result = await db.query(
            `UPDATE kullanici SET ${updates.join(', ')} WHERE kullanici_id = $${paramIndex} RETURNING kullanici_id, email, ad, soyad, telefon, kayit_tarihi`,
            values
        );

        const updatedUser = result.rows[0];

        return res.status(200).json({
            success: true,
            message: 'Profil başarıyla güncellendi',
            user: {
                id: updatedUser.kullanici_id,
                name: `${updatedUser.ad} ${updatedUser.soyad}`.trim(),
                email: updatedUser.email,
                phone: updatedUser.telefon,
                createdAt: updatedUser.kayit_tarihi
            }
        });

    } catch (err) {
        console.error('Profil güncelleme hatası:', err);
        return res.status(500).json({ 
            message: 'Profil güncellenirken hata oluştu',
            error: err.message 
        });
    }
};

// Şifre değiştir
exports.changePassword = async (req, res) => {
    try {
        const { userId } = req.params;
        const { currentPassword, newPassword } = req.body;

        if (!userId || !currentPassword || !newPassword) {
            return res.status(400).json({ 
                message: 'Mevcut şifre ve yeni şifre gereklidir' 
            });
        }

        if (newPassword.length < 8) {
            return res.status(400).json({ 
                message: 'Yeni şifre en az 8 karakter olmalıdır' 
            });
        }

        // Kullanıcıyı ve mevcut şifresini al
        const result = await db.query(
            'SELECT kullanici_id, email, sifre_hash FROM kullanici WHERE kullanici_id = $1',
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı' 
            });
        }

        const user = result.rows[0];

        // Mevcut şifreyi kontrol et
        const currentHashedPassword = hashPassword(currentPassword);
        if (user.sifre_hash !== currentHashedPassword) {
            return res.status(401).json({ 
                message: 'Mevcut şifre hatalı' 
            });
        }

        // Yeni şifreyi hash'le ve güncelle
        const newHashedPassword = hashPassword(newPassword);
        await db.query(
            'UPDATE kullanici SET sifre_hash = $1 WHERE kullanici_id = $2',
            [newHashedPassword, userId]
        );

        return res.status(200).json({
            success: true,
            message: 'Şifreniz başarıyla değiştirildi'
        });

    } catch (err) {
        console.error('Şifre değiştirme hatası:', err);
        return res.status(500).json({ 
            message: 'Şifre değiştirilirken hata oluştu',
            error: err.message 
        });
    }
};

// Profil fotoğrafı yükle
exports.uploadProfilePhoto = async (req, res) => {
    try {
        const { userId } = req.params;

        if (!userId) {
            return res.status(400).json({ 
                message: 'Kullanıcı ID gereklidir' 
            });
        }

        if (!req.file) {
            return res.status(400).json({ 
                message: 'Lütfen bir fotoğraf seçin' 
            });
        }

        // Eski fotoğrafı sil (varsa)
        const oldPhotoResult = await db.query(
            'SELECT profil_fotografi FROM kullanici WHERE kullanici_id = $1',
            [userId]
        );

        if (oldPhotoResult.rows.length > 0 && oldPhotoResult.rows[0].profil_fotografi) {
            const oldPhotoPath = path.join(__dirname, '..', oldPhotoResult.rows[0].profil_fotografi);
            if (fs.existsSync(oldPhotoPath)) {
                fs.unlinkSync(oldPhotoPath);
            }
        }

        // Yeni fotoğraf yolunu kaydet (relatif path)
        const photoPath = `/uploads/profiles/${req.file.filename}`;
        
        await db.query(
            'UPDATE kullanici SET profil_fotografi = $1 WHERE kullanici_id = $2',
            [photoPath, userId]
        );

        return res.status(200).json({
            success: true,
            message: 'Profil fotoğrafı başarıyla güncellendi',
            data: {
                photoPath: photoPath
            }
        });

    } catch (err) {
        console.error('Profil fotoğrafı yükleme hatası:', err);
        // Hata durumunda yüklenen dosyayı sil
        if (req.file) {
            const filePath = req.file.path;
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
            }
        }
        return res.status(500).json({ 
            message: 'Profil fotoğrafı yüklenirken hata oluştu',
            error: err.message 
        });
    }
};

// Profil fotoğrafını sil
exports.deleteProfilePhoto = async (req, res) => {
    try {
        const { userId } = req.params;

        if (!userId) {
            return res.status(400).json({ 
                message: 'Kullanıcı ID gereklidir' 
            });
        }

        // Mevcut fotoğrafı bul
        const result = await db.query(
            'SELECT profil_fotografi FROM kullanici WHERE kullanici_id = $1',
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı' 
            });
        }

        const photoPath = result.rows[0].profil_fotografi;
        
        if (photoPath) {
            // Dosyayı sil
            const fullPath = path.join(__dirname, '..', photoPath);
            if (fs.existsSync(fullPath)) {
                fs.unlinkSync(fullPath);
            }

            // Veritabanından kaldır
            await db.query(
                'UPDATE kullanici SET profil_fotografi = NULL WHERE kullanici_id = $1',
                [userId]
            );

            return res.status(200).json({
                success: true,
                message: 'Profil fotoğrafı başarıyla silindi'
            });
        } else {
            return res.status(404).json({ 
                message: 'Profil fotoğrafı bulunamadı' 
            });
        }

    } catch (err) {
        console.error('Profil fotoğrafı silme hatası:', err);
        return res.status(500).json({ 
            message: 'Profil fotoğrafı silinirken hata oluştu',
            error: err.message 
        });
    }
};

