// models/Reservation.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Reservation = sequelize.define(
  'Reservation',
  {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },

    tarih: { type: DataTypes.STRING, allowNull: false },
    saat: { type: DataTypes.STRING, allowNull: false },

    
    status: {
      type: DataTypes.ENUM('PENDING', 'APPROVED'),
      allowNull: false,
      defaultValue: 'PENDING',
    },

    
    userId: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: '1',
    },

    not: { type: DataTypes.TEXT, allowNull: true },
  },
  {
    tableName: 'reservations',
    timestamps: true,

    
    indexes: [{ unique: true, fields: ['tarih', 'saat'] }],
  }
);

module.exports = Reservation;