// models/Ilan.js

// Sequelize'den veri tiplerini alıyoruz
const { DataTypes } = require('sequelize');

// config/db.js içindeki "sequelize" nesnesini alıyoruz
// NOT: db.js içinde büyük ihtimalle şöyle bir export vardır:
// module.exports = { sequelize, connectDB };
const { sequelize } = require('../config/db');

// "ilanlar" tablosu için model tanımı
const Ilan = sequelize.define('Ilan', {
  ad_soyad: {
    type: DataTypes.STRING,
    allowNull: false, // Boş bırakılamaz
  },
  baslik: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  konum: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  tarih: {
    // "05/11/2025" gibi string olarak tutulacak
    type: DataTypes.STRING,
    allowNull: false,
  },
  saat: {
    // "21:00" gibi string saat bilgisi
    type: DataTypes.STRING,
    allowNull: false,
  },
  kisi_sayisi: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  mevki: {
    // Örnek: "Kaleci, Forvet"
    type: DataTypes.STRING,
    allowNull: false,
  },
  seviye: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  ucret: {
    // Flutter bazen "Ücretsiz", bazen "150 TL" gönderecek
    type: DataTypes.STRING,
    allowNull: true,
  },
  aciklama: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  yas: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
}, {
  tableName: 'ilanlar', // Veritabanındaki tablo adı
});

module.exports = Ilan;