const crypto = require('crypto');
const moment = require('moment-timezone');
const bcrypt = require('bcrypt');
const db = require('../config/database');
const SendMailer = require('../utils/sendMail');
const { createTemporaryToken, decodedTemporaryToken } = require('../utils/tokenHelper');
const { auth } = require('../config/firebase');

// Moment timezone ayarı
moment.tz.setDefault('Europe/Istanbul');

// Şifre hash'leme
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

// JWT Token oluştur
function generateToken(userId, email, expiresIn) {
    // Header oluştur
    const header = Buffer.from(JSON.stringify({ 
        alg: 'HS256', 
        typ: 'JWT' 
    })).toString('base64');
    
    // Payload oluştur (kullanıcı bilgileri + geçerlilik süresi)
    const payload = Buffer.from(JSON.stringify({
        userId,
        email,
        iat: Math.floor(Date.now() / 1000),           // Oluşturulma zamanı
        exp: Math.floor(Date.now() / 1000) + expiresIn, // Dinamik süre
    })).toString('base64');
    
    // İmza oluştur
    const signature = crypto
        .createHmac('sha256', process.env.JWT_SECRET || 'your-secret-key')
        .update(`${header}.${payload}`)
        .digest('base64');
    
    // Token döndür: Header.Payload.Signature formatında
    return `${header}.${payload}.${signature}`;
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
        const { email, password, rememberMe } = req.body;

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

        // Token oluştur: rememberMe true ise 1 yıl (365 gün), false ise 1 gün
        const expiresIn = rememberMe ? (365 * 24 * 60 * 60) : (24 * 60 * 60);
        const token = generateToken(user.kullanici_id, user.email, expiresIn);

        // Başarılı giriş
        return res.status(200).json({
            success: true,
            message: 'Giriş başarılı',
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

// Şifre sıfırlama isteği
exports.resetPassword = async (req, res) => {
    try {
        const { email } = req.body;

        // Validasyon
        if (!email) {
            return res.status(400).json({ 
                message: 'Email adresi gereklidir' 
            });
        }

        // Email formatı kontrolü
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ 
                message: 'Geçersiz email formatı' 
            });
        }

        // Kullanıcı var mı kontrol et
        const result = await db.query(
            'SELECT kullanici_id, email, ad, soyad FROM kullanici WHERE email = $1',
            [email]
        );

        if (result.rows.length === 0) {
            // Güvenlik için kullanıcı bulunamasa bile başarılı mesajı döndür
            return res.status(200).json({ 
                message: 'Eğer bu email kayıtlıysa, şifre sıfırlama kodu gönderildi',
                success: true
            });
        }

        const kullaniciInfo = result.rows[0];

        // 6 haneli rastgele sayı kodu oluştur (sadece rakamlar)
        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
        const resetCodeExpiry = moment(new Date()).add(15, 'minutes').format('YYYY-MM-DD HH:mm:ss');

        // Email gönder
        const emailSent = await SendMailer({
            from: process.env.EMAIL_USER,
            to: kullaniciInfo.email,
            subject: 'Halısaha Sistemi - Şifre Sıfırlama Talebi',
            text: `Merhaba ${kullaniciInfo.ad} ${kullaniciInfo.soyad},\n\nŞifre sıfırlama kodunuz: ${resetCode}\n\nBu kod 15 dakika geçerlidir.\n\nEğer bu talebi siz yapmadıysanız, lütfen bu emaili görmezden gelin.`
        });

        if (!emailSent) {
            return res.status(500).json({ 
                message: 'Email gönderilemedi. Lütfen daha sonra tekrar deneyin.',
                success: false
            });
        }

        // Kodu veritabanına kaydet
        await db.query(
            'UPDATE kullanici SET reset_code = $1, reset_code_expiry = $2 WHERE email = $3',
            [resetCode, resetCodeExpiry, email]
        );

        console.log(`🔐 Şifre sıfırlama kodu:`);
        console.log(`   Email: ${email}`);
        console.log(`   Kod: ${resetCode}`);
        console.log(`   Geçerlilik: ${resetCodeExpiry}`);

        return res.status(200).json({ 
            message: 'Şifre sıfırlama kodu e-postanıza gönderildi',
            success: true,
            // Geliştirme için (üretimde kaldırılmalı):
            dev_info: {
                email: email,
                resetCode: resetCode,
                expiresAt: resetCodeExpiry
            }
        });

    } catch (err) {
        console.error('Şifre sıfırlama hatası:', err);
        return res.status(500).json({ 
            message: 'Şifre sıfırlama sırasında hata oluştu',
            error: err.message 
        });
    }
};

// Kod doğrulama
exports.verifyResetCode = async (req, res) => {
    try {
        const { email, code } = req.body;

        // Validasyon
        if (!email || !code) {
            return res.status(400).json({ 
                message: 'Email ve kod gereklidir' 
            });
        }

        if (code.length !== 6) {
            return res.status(400).json({ 
                message: 'Kod 6 haneli olmalıdır' 
            });
        }

        // Kullanıcıyı ve kodunu kontrol et
        const result = await db.query(
            'SELECT kullanici_id, reset_code, reset_code_expiry FROM kullanici WHERE email = $1',
            [email]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı',
                success: false
            });
        }

        const user = result.rows[0];

        // Kod kontrolü
        if (!user.reset_code) {
            return res.status(400).json({ 
                message: 'Şifre sıfırlama talebi bulunamadı',
                success: false
            });
        }

        if (user.reset_code !== code) {
            return res.status(400).json({ 
                message: 'Geçersiz kod',
                success: false
            });
        }

        // Süre kontrolü
        const now = moment(new Date()).format('YYYY-MM-DD HH:mm:ss');
        if (moment(now).isAfter(user.reset_code_expiry)) {
            return res.status(400).json({ 
                message: 'Kodun süresi dolmuş. Lütfen yeni kod talep edin.',
                success: false
            });
        }

        // Geçici token oluştur (3 dakika geçerli)
        const temporaryToken = await createTemporaryToken(user.kullanici_id, email);

        console.log(`✅ Kod doğrulama başarılı:`);
        console.log(`   Email: ${email}`);
        console.log(`   Kod: ${code}`);
        console.log(`   Temporary Token oluşturuldu`);

        return res.status(200).json({ 
            message: 'Kod doğrulandı. Şifre sıfırlama yapabilirsiniz.',
            success: true,
            temporaryToken: temporaryToken
        });

    } catch (err) {
        console.error('Kod doğrulama hatası:', err);
        return res.status(500).json({ 
            message: 'Kod doğrulama sırasında hata oluştu',
            error: err.message 
        });
    }
};

// Şifre değiştirme (temporary token ile)
exports.confirmResetPassword = async (req, res) => {
    try {
        const { newPassword, temporaryToken } = req.body;

        // Validasyon
        if (!temporaryToken || !newPassword) {
            return res.status(400).json({ 
                message: 'Token ve yeni şifre gereklidir' 
            });
        }

        if (newPassword.length < 8) {
            return res.status(400).json({ 
                message: 'Şifre en az 8 karakter olmalıdır' 
            });
        }

        // Token'ı doğrula
        let decoded;
        try {
            decoded = await decodedTemporaryToken(temporaryToken);
        } catch (err) {
            return res.status(400).json({ 
                message: 'Geçersiz veya süresi dolmuş token',
                success: false
            });
        }

        // Kullanıcıyı kontrol et
        const result = await db.query(
            'SELECT kullanici_id, email FROM kullanici WHERE kullanici_id = $1',
            [decoded.userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı' 
            });
        }

        const user = result.rows[0];

        // Şifreyi hash'le (SHA-256 ile - mevcut sistemle uyumlu)
        const hashedPassword = hashPassword(newPassword);

        // Şifreyi güncelle ve reset kodunu temizle
        await db.query(
            'UPDATE kullanici SET sifre_hash = $1, reset_code = NULL, reset_code_expiry = NULL WHERE kullanici_id = $2',
            [hashedPassword, user.kullanici_id]
        );

        console.log(`✅ Şifre değiştirildi:`);
        console.log(`   Email: ${user.email}`);
        console.log(`   User ID: ${user.kullanici_id}`);

        return res.status(200).json({ 
            message: 'Şifreniz başarıyla değiştirildi',
            success: true
        });

    } catch (err) {
        console.error('Şifre değiştirme hatası:', err);
        return res.status(500).json({ 
            message: 'Şifre değiştirme sırasında hata oluştu',
            error: err.message 
        });
    }
};

// Google ile giriş
exports.googleLogin = async (req, res) => {
    try {
        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).json({ 
                success: false,
                message: 'ID token gereklidir' 
            });
        }

        // Firebase token'ını doğrula
        const decodedToken = await auth.verifyIdToken(idToken);
        const email = decodedToken.email;
        const fullName = decodedToken.name || '';
        const [ad = '', soyad = ''] = fullName.split(' ', 2);

        // Kullanıcıyı veritabanında kontrol et
        let kullanici = await db.query(
            'SELECT kullanici_id, email, ad, soyad, profil_fotografi FROM kullanici WHERE email = $1',
            [email]
        );

        let userData;

        if (kullanici.rows.length === 0) {
            // Yeni kullanıcı ekle
            const insertResult = await db.query(
                'INSERT INTO kullanici (email, sifre_hash, ad, soyad) VALUES ($1, $2, $3, $4) RETURNING kullanici_id, email, ad, soyad, profil_fotografi',
                [email, 'google_auth', ad, soyad]
            );
            
            userData = insertResult.rows[0];
            
            return res.status(201).json({
                success: true,
                message: 'Kullanıcı kaydedildi ve giriş yapıldı',
                user: {
                    id: userData.kullanici_id,
                    email: userData.email,
                    name: `${userData.ad} ${userData.soyad}`.trim(),
                    phone: null,
                    profileImage: userData.profil_fotografi,
                    createdAt: new Date().toISOString()
                },
            });
        } else {
            // Var olan kullanıcı giriş yaptı
            userData = kullanici.rows[0];
            
            return res.status(200).json({
                success: true,
                message: 'Giriş başarılı',
                user: {
                    id: userData.kullanici_id,
                    email: userData.email,
                    name: `${userData.ad} ${userData.soyad}`.trim(),
                    phone: null,
                    profileImage: userData.profil_fotografi,
                    createdAt: null
                },
            });
        }
    } catch (error) {
        console.error('Google login hatası:', error);
        return res.status(401).json({
            success: false,
            message: 'Kimlik doğrulama başarısız',
            error: error.message,
        });
    }
};

// Firebase token doğrulama
exports.verifyToken = async (req, res) => {
    try {
        const token = req.headers.authorization?.split('Bearer ')[1];

        if (!token) {
            return res.status(401).json({ 
                success: false,
                message: 'Token gereklidir' 
            });
        }

        const decodedToken = await auth.verifyIdToken(token);
        
        return res.status(200).json({
            success: true,
            user: decodedToken,
        });
    } catch (error) {
        console.error('Token doğrulama hatası:', error);
        return res.status(401).json({
            success: false,
            message: 'Geçersiz token',
            error: error.message
        });
    }
};

