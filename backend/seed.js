const db = require('./config/database');
const crypto = require('crypto');

async function seedDatabase() {
    try {
        console.log('\n📊 Test verisi ekleniyor...\n');

        // Şifreyi hash'le (test123 => hash değeri)
        const password = 'test123';
        const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');

        // Test kullanıcısı ekle
        const result = await db.query(
            'INSERT INTO kullanici (email, sifre_hash, ad, soyad, telefon) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (email) DO NOTHING RETURNING *',
            ['test@test.com', hashedPassword, 'Test', 'Kullanıcı', '05551234567']
        );

        if (result.rows.length > 0) {
            console.log('✅ Yeni kullanıcı eklendi:');
            console.log(result.rows[0]);
        } else {
            console.log('ℹ️  Bu email zaten mevcut, yeni kullanıcı eklenmedi');
        }

        // Tüm kullanıcıları listele
        const allUsers = await db.query('SELECT kullanici_id, email, ad, soyad, telefon FROM kullanici');
        console.log('\n📋 Veritabanındaki tüm kullanıcılar:');
        console.log(allUsers.rows);

        console.log('\n✅ Test verisi başarıyla yüklendi!\n');
        
        db.end();
        process.exit(0);
    } catch (err) {
        console.error('❌ Hata:', err.message);
        db.end();
        process.exit(1);
    }
}

seedDatabase();
