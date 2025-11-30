const crypto = require('crypto');
const db = require('../config/database');

// Şifre hash'leme
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

// Kayıt olma
exports.register = async (req, res) => {
    try {
        const { name, email, phone, password } = req.body;

        // Validasyon
        if (!name || !email || !password) {
            return res.status(400).json({ 
                message: 'Ad, email ve şifre gereklidir' 
            });
        }

        if (password.length < 8) {
            return res.status(400).json({ 
                message: 'Şifre en az 8 karakter olmalıdır' 
            });
        }

        // Email formatı kontrolü
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ 
                message: 'Geçersiz email formatı' 
            });
        }

        // Email zaten var mı kontrol et
        const checkEmail = await db.query('SELECT email FROM kullanici WHERE email = $1', [email]);
        if (checkEmail.rows.length > 0) {
            return res.status(400).json({ 
                message: 'Bu email zaten kayıtlı' 
            });
        }

        // Telefon zaten var mı kontrol et
        if (phone) {
            const checkPhone = await db.query('SELECT telefon FROM kullanici WHERE telefon = $1', [phone]);
            if (checkPhone.rows.length > 0) {
                return res.status(400).json({ 
                    message: 'Bu telefon numarası zaten kayıtlı' 
                });
            }
        }

        // Ad soyad ayır
        const nameParts = name.trim().split(' ');
        const ad = nameParts[0];
        const soyad = nameParts.slice(1).join(' ') || '';

        // Şifreyi hash'le
        const hashedPassword = hashPassword(password);

        // Veritabanına kaydet
        const result = await db.query(
            'INSERT INTO kullanici (email, sifre_hash, ad, soyad, telefon) VALUES ($1, $2, $3, $4, $5) RETURNING kullanici_id, email, ad, soyad, telefon, kayit_tarihi',
            [email, hashedPassword, ad, soyad, phone || null]
        );

        const newUser = result.rows[0];

        // Token oluştur
        const token = `token-${newUser.kullanici_id}-${Date.now()}`;

        return res.status(201).json({
            token,
            user: {
                id: newUser.kullanici_id,
                name: `${newUser.ad} ${newUser.soyad}`.trim(),
                email: newUser.email,
                phone: newUser.telefon,
                createdAt: newUser.kayit_tarihi
            }
        });

    } catch (err) {
        console.error('Kayıt hatası:', err);
        return res.status(500).json({ 
            message: 'Kayıt sırasında hata oluştu',
            error: err.message 
        });
    }
};

// Giriş yapma
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validasyon
        if (!email || !password) {
            return res.status(400).json({ 
                message: 'Email ve şifre gereklidir' 
            });
        }

        // Email formatı kontrolü
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ 
                message: 'Geçersiz email formatı' 
            });
        }

        // Kullanıcıyı bul
        const result = await db.query(
            'SELECT kullanici_id, email, sifre_hash, ad, soyad, telefon, kayit_tarihi FROM kullanici WHERE email = $1',
            [email]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ 
                message: 'Email veya şifre hatalı' 
            });
        }

        const user = result.rows[0];
        const hashedPassword = hashPassword(password);

        // Şifre kontrolü
        if (user.sifre_hash !== hashedPassword) {
            return res.status(401).json({ 
                message: 'Email veya şifre hatalı' 
            });
        }

        // Token oluştur
        const token = `token-${user.kullanici_id}-${Date.now()}`;

        // Başarılı giriş
        return res.status(200).json({
            token,
            user: {
                id: user.kullanici_id,
                name: `${user.ad} ${user.soyad}`.trim(),
                email: user.email,
                phone: user.telefon,
                createdAt: user.kayit_tarihi
            }
        });

    } catch (err) {
        console.error('Giriş hatası:', err);
        return res.status(500).json({ 
            message: 'Giriş sırasında hata oluştu',
            error: err.message 
        });
    }
};
