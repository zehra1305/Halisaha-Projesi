// config/db.js
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    logging: false,
  }
);

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ PostgreSQL bağlantısı başarılı');

    await sequelize.sync();
    console.log('✅ Sequelize sync tamamlandı');
  } catch (err) {
    console.error('❌ PostgreSQL bağlantı hatası:', err.message);
    console.error(err); 
    process.exit(1);
  }
};

module.exports = {
  sequelize,
  connectDB,
};