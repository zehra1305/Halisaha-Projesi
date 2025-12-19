const express = require("express");
const http = require("http"); // Socket.io için gerekli
const { Server } = require("socket.io");
const cors = require("cors");
require("dotenv").config();

// Rota dosyalarını içe aktar
const chatRoutes = require("./routes/chatRoutes");
const socketHandler = require("./socket");

const app = express();
const server = http.createServer(app); // Express'i http sunucusuna sarıyoruz

// Middleware
app.use(cors());
app.use(express.json());

// API Rotaları
app.use("/api/chat", chatRoutes);
// app.use('/api/auth', authRoutes); // Senin mevcut auth rotaların buraya gelecek

// Socket.io Başlatma
const io = new Server(server, {
  cors: {
    origin: "*", // Flutter ve Web'den erişim izni
    methods: ["GET", "POST"],
  },
});

// Socket mantığını çalıştır
socketHandler(io);

// Sunucuyu Ayağa Kaldır
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Sunucu ${PORT} portunda çalışıyor...`);
});

// Server hataları
server.on("error", (err) => {
  console.error("❌ Sunucu hatası:", err.message);
  if (err.code === "EADDRINUSE") {
    console.error(`Port ${PORT} zaten kullanımda`);
  }
  process.exit(1);
});

// İşlem hataları
process.on("uncaughtException", (err) => {
  console.error("❌ Beklenmeyen hata:", err.message);
  process.exit(1);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("❌ İşlenmeyen Promise hatası:", reason);
});
