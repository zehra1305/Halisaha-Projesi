const { Client } = require('pg');
require('dotenv').config();

const db = new Client({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'postgres',
    port: parseInt(process.env.DB_PORT) || 5432,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'halisaha_proje_db'
});

// Veritabanı bağlantısını kur
db.connect((err) => {
    if (err) {
        console.error('❌ Veritabanı bağlantı hatası:', err.message);
        console.error('Detaylar:', {
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            port: process.env.DB_PORT,
            database: process.env.DB_NAME
        });
    } else {
        console.log('Veritabanına başarıyla bağlandı');
        console.log(` Bağlı: ${process.env.DB_USER}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`);
    }
});

// Connection error handling
db.on('error', (err) => {
    console.error(' Veritabanı runtime hatası:', err.message);
});

module.exports = db;
