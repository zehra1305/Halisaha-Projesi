const { Pool } = require('pg');

// Veritabanı bilgilerini buraya elle giriyoruz (Hardcoded)
const pool = new Pool({
    user: 'postgres',       // Genelde kullanıcı adı 'postgres'tir
    host: 'localhost',      // Kendi bilgisayarın
    database: 'halisaha_db',// DİKKAT: pgAdmin'de oluşturduğun veritabanı ismini buraya yaz (halisaha_db veya halisaha_proje_db)
    password: '1234',       // <-- SENİN ŞİFREN (Eğer 1234 değilse burayı değiştir)
    port: 5432,             // Standart port
});

// Bağlantı durumunu kontrol etmek için loglar
pool.on('connect', () => {
    console.log('✅ Veritabanına başarıyla bağlanıldı!');
});

pool.on('error', (err) => {
    console.error('❌ Beklenmedik veritabanı hatası:', err);
    process.exit(-1); // Hata durumunda uygulamayı durdurur
});

module.exports = {
    query: (text, params) => pool.query(text, params),
    end: () => pool.end(),
};