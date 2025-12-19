const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
});

// Veritabanı bağlantı hataları
pool.on("error", (err) => {
  console.error("❌ Veritabanı bağlantı hatası:", err.message);
});

pool.on("connect", () => {
  console.log("✅ Veritabanına bağlandı");
});

module.exports = pool;
