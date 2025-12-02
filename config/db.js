const mongoose = require('mongoose');

// MongoDB bağlantısını başlatan fonksiyon
const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI;

    // .env içinde MONGO_URI yoksa uyarı ver
    if (!uri) {
      console.log("MONGO_URI .env içinde bulunamadı!");
      return;
    }

    await mongoose.connect(uri);
    console.log("MongoDB bağlantısı başarılı");
  } catch (err) {
    console.error("MongoDB bağlantı hatası:", err.message);
    
  }
};

module.exports = connectDB;