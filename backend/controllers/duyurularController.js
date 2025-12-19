const { Pool } = require('pg');
require('dotenv').config();

// Supabase bağlantısı için Pool oluştur
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

// Tüm duyuruları getir
exports.getAllDuyurular = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM duyurular ORDER BY tarih DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Duyurular çekilemedi:', error);
    res.status(500).json({ error: 'Duyurular alınamadı.' });
  }
};
