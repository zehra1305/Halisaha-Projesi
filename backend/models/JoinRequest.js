// models/JoinRequest.js
// Bir ilana katılmak isteyen oyuncuların taleplerini tutan model

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const Ilan = require('./Ilan'); // İlan modeli ile ilişki kuracağız

const JoinRequest = sequelize.define(
  'JoinRequest',
  {
    // Birincil anahtar
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },

    // Hangi ilana başvurulduğu
    ilanId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Ilan,
        key: 'id',
      },
      onDelete: 'CASCADE',
    },

    // Başvuran oyuncunun adı soyadı
    adSoyad: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    // İsteğe bağlı açıklama / not
    not: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    // Talep durumu: beklemede / kabul / red
    durum: {
      type: DataTypes.ENUM('beklemede', 'kabul', 'red'),
      allowNull: false,
      defaultValue: 'beklemede',
    },
  },
  {
    tableName: 'join_requests',
    timestamps: true,
  }
);

// İlan ↔ KatılımTalebi ilişkisi
Ilan.hasMany(JoinRequest, { foreignKey: 'ilanId', as: 'katilimTalepleri' });
JoinRequest.belongsTo(Ilan, { foreignKey: 'ilanId', as: 'ilan' });

module.exports = JoinRequest;