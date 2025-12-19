const pool = require("./db");

module.exports = (io) => {
  io.on("connection", (socket) => {
    console.log("⚡ Socket bağlandı:", socket.id);

    // Kullanıcı odaya (sohbet_id) katılıyor
    socket.on("join_room", (sohbet_id) => {
      // Validasyon
      if (!sohbet_id) {
        socket.emit("error", { message: "Sohbet ID gereklidir" });
        return;
      }

      socket.join(sohbet_id);
      console.log(`✅ Kullanıcı ${sohbet_id} nolu odaya girdi.`);
    });

    // Mesaj Gönderme İşlemi
    socket.on("send_message", async (data) => {
      try {
        // Veri validasyonu
        if (!data) {
          socket.emit("error", { message: "Geçersiz veri" });
          return;
        }

        const { sohbet_id, gonderen_id, icerik } = data;

        if (!sohbet_id || !gonderen_id || !icerik) {
          socket.emit("error", { message: "Tüm alanlar gereklidir" });
          return;
        }

        if (icerik.trim().length === 0) {
          socket.emit("error", { message: "Mesaj boş olamaz" });
          return;
        }

        // 1. Veritabanına kaydet
        const yeniMesaj = await pool.query(
          "INSERT INTO mesaj (sohbet_id, gonderen_id, icerik) VALUES ($1, $2, $3) RETURNING *",
          [sohbet_id, gonderen_id, icerik]
        );

        // 2. Odadaki herkese ilet
        io.to(sohbet_id).emit("receive_message", yeniMesaj.rows[0]);
        socket.emit("message_sent", {
          success: true,
          message: yeniMesaj.rows[0],
        });
      } catch (err) {
        console.error("❌ Socket mesaj hatası:", err.message);
        socket.emit("error", {
          message: "Mesaj gönderilemedi",
          details: err.message,
        });
      }
    });

    socket.on("disconnect", () => {
      console.log("❌ Socket ayrıldı:", socket.id);
    });

    // Genel Socket hatası
    socket.on("error", (error) => {
      console.error("❌ Socket hatası:", error);
    });
  });
};
