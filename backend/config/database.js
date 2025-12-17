const { Pool } = require('pg');
require('dotenv').config();

// DATABASE_URL varsa onu kullan, yoksa parametreleri kullan
const connectionString = process.env.DATABASE_URL;

const pool = new Pool(
    connectionString 
    ? { 
        connectionString, 
        ssl: { rejectUnauthorized: false },
        // Session pooler için önemli
        max: 20, // Maximum pool connections
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 10000,
    }
    : {
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'postgres',
        port: parseInt(process.env.DB_PORT) || 5432,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME || 'halisaha_proje_db',
        ssl: false
    }
);

// Test bağlantısı
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('❌ Veritabanı bağlantı hatası:', err.message);
    } else {
        console.log('✓ Veritabanına başarıyla bağlandı');
        if (connectionString) {
            console.log('→ Bağlantı: DATABASE_URL kullanılıyor (Supabase)');
        } else {
            console.log(`→ Bağlı: ${process.env.DB_USER}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`);
        }
    }
});

// Connection error handling
pool.on('error', (err) => {
    console.error('⚠ Veritabanı runtime hatası:', err.message);
});

module.exports = pool;
