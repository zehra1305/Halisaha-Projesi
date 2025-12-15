// models/Message.js
// İlan sahibine gönderilen mesajları tutan model

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const Ilan = require('./Ilan'); // İlişki kurmak için ilan modelini çekiyoruz

// Mesaj tablosunu tanımlıyoruz
const Message = sequelize.define(
  'Message',
  {
    // Birincil anahtar (id)
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true, // Her yeni kayıt için otomatik artan id
    },

    // Hangi ilana ait olduğu – yabancı anahtar
    ilanId: {
      type: DataTypes.INTEGER,
      allowNull: false, // Boş bırakılamaz
      references: {
        model: Ilan, // İlan tablosuna bağlı
        key: 'id',
      },
      onDelete: 'CASCADE', // İlan silinince mesajlar da silinsin
    },

    // Mesajı atan kişinin adı soyadı
    adSoyad: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    // Mesaj içeriği
    mesaj: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
  },
  {
    tableName: 'messages', // Veritabanındaki tablo adı
    timestamps: true,      // createdAt ve updatedAt otomatik gelsin
  }
);

// İlan ↔ Mesaj ilişkisini tanımlıyoruz
Ilan.hasMany(Message, { foreignKey: 'ilanId', as: 'mesajlar' });
Message.belongsTo(Ilan, { foreignKey: 'ilanId', as: 'ilan' });

// Bu modeli dışarıya açıyoruz
module.exports = Message;
