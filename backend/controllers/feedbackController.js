const db = require('../config/database');
const SendMailer = require('../utils/sendMail');

// Geri bildirim gönder
exports.sendFeedback = async (req, res) => {
    try {
        const { kullaniciId, baslik, mesaj, kategori } = req.body;

        // Validasyon
        if (!kullaniciId || !mesaj) {
            return res.status(400).json({ 
                message: 'Kullanıcı ID ve mesaj gereklidir' 
            });
        }

        // Kullanıcı bilgilerini al
        const userResult = await db.query(
            'SELECT ad, soyad, email FROM kullanici WHERE kullanici_id = $1',
            [kullaniciId]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ 
                message: 'Kullanıcı bulunamadı' 
            });
        }

        const user = userResult.rows[0];
        const kullaniciAdi = `${user.ad} ${user.soyad}`;
        const kullaniciEmail = user.email;

        // Veritabanına kaydet
        const result = await db.query(
            `INSERT INTO geri_bildirimler 
            (kullanici_id, baslik, mesaj, kategori) 
            VALUES ($1, $2, $3, $4) 
            RETURNING *`,
            [kullaniciId, baslik || 'Geri Bildirim', mesaj, kategori || 'Genel']
        );

        // Email içeriği
        const emailContent = `
            <!DOCTYPE html>
            <html lang="tr">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body>
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #2FB335;">🔔 Yeni Geri Bildirim</h2>
                <div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">
                    <p><strong>👤 Kullanıcı:</strong> ${kullaniciAdi}</p>
                    <p><strong>📧 Email:</strong> ${kullaniciEmail}</p>
                    <p><strong>📂 Kategori:</strong> <span style="background-color: #2FB335; color: white; padding: 4px 8px; border-radius: 4px;">${kategori || 'Genel'}</span></p>
                    ${baslik ? `<p><strong>📝 Başlık:</strong> ${baslik}</p>` : ''}
                </div>
                <div style="background-color: white; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
                    <h3 style="color: #333; margin-top: 0;">Mesaj:</h3>
                    <p style="color: #666; line-height: 1.6;">${mesaj.replace(/\n/g, '<br>')}</p>
                </div>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
                <p style="color: #999; font-size: 12px; text-align: center;">
                    📅 Gönderim Zamanı: ${new Date().toLocaleString('tr-TR', { 
                        dateStyle: 'full', 
                        timeStyle: 'short' 
                    })}
                </p>
            </div>
            </body>
            </html>
        `;

        // Email gönder - ÖNCE EMAIL GÖNDER
        try {
            const mailOptions = {
                from: `"Halısaha Sistemi" <${process.env.EMAIL_USER}>`,
                to: process.env.EMAIL_USER, // Kendi mailinize gönderiliyor
                subject: `📬 Geri Bildirim: ${baslik || kategori || 'Yeni Mesaj'}`,
                html: emailContent,
                headers: {
                    'Content-Type': 'text/html; charset=UTF-8'
                }
            };
            
            await SendMailer(mailOptions);
            console.log('✅ Geri bildirim email gönderildi:', process.env.EMAIL_USER);
        } catch (emailError) {
            console.error('❌ Email gönderme hatası:', emailError);
            // Email gönderilemezse hata döndür
            return res.status(500).json({
                success: false,
                message: 'Email gönderilemedi, lütfen tekrar deneyin',
                error: emailError.message
            });
        }

        return res.status(201).json({
            success: true,
            message: 'Geri bildiriminiz başarıyla gönderildi',
            data: result.rows[0]
        });

    } catch (err) {
        console.error('Geri bildirim gönderme hatası:', err);
        return res.status(500).json({ 
            success: false,
            message: 'Geri bildirim gönderilirken hata oluştu',
            error: err.message 
        });
    }
};

// Kullanıcının geri bildirimlerini getir
exports.getUserFeedbacks = async (req, res) => {
    try {
        const { userId } = req.params;

        const result = await db.query(
            `SELECT * FROM geri_bildirimler 
            WHERE kullanici_id = $1 
            ORDER BY olusturma_tarihi DESC`,
            [userId]
        );

        return res.status(200).json({
            success: true,
            data: result.rows
        });

    } catch (err) {
        console.error('Geri bildirimleri getirme hatası:', err);
        return res.status(500).json({ 
            success: false,
            message: 'Geri bildirimler yüklenirken hata oluştu',
            error: err.message 
        });
    }
};
