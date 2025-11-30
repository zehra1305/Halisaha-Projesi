// models/Reservation.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Reservation = sequelize.define(
  'Reservation',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },

    // "2025-12-01" kimi saxlayacaqsan deyə STRING burda da iş görür
    tarih: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    // "17:00" - "23:00" arası saat string kimi
    saat: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    // İstəyə bağlı not
    not: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    tableName: 'reservations', // Cədvəl adı
    timestamps: true, // createdAt, updatedAt əlavə edir, istəməsən false elə
  }
);

module.exports = Reservation;