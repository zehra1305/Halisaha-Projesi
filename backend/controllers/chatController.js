const pool = require("../db");

// 1. Yeni Sohbet Başlat veya Varsa Getir
exports.sohbetBaslat = async (req, res) => {
  try {
    // Veri validasyonu
    const { ilan_id, baslatan_id, ilan_sahibi_id } = req.body;

    if (!ilan_id || !baslatan_id || !ilan_sahibi_id) {
      return res.status(400).json({
        error: "Gerekli alanlar: ilan_id, baslatan_id, ilan_sahibi_id",
      });
    }

    // Tip kontrolü
    if (
      !Number.isInteger(ilan_id) ||
      !Number.isInteger(baslatan_id) ||
      !Number.isInteger(ilan_sahibi_id)
    ) {
      return res.status(400).json({ error: "ID'ler sayı olmalıdır" });
    }

    // Önce böyle bir sohbet var mı kontrol et
    const varmi = await pool.query(
      "SELECT * FROM sohbet WHERE ilan_id = $1 AND baslatan_id = $2",
      [ilan_id, baslatan_id]
    );

    if (varmi.rows.length > 0) {
      return res.json(varmi.rows[0]);
    }

    // Yoksa yeni oluştur
    const yeniSohbet = await pool.query(
      "INSERT INTO sohbet (ilan_id, baslatan_id, ilan_sahibi_id) VALUES ($1, $2, $3) RETURNING *",
      [ilan_id, baslatan_id, ilan_sahibi_id]
    );

    res.status(201).json(yeniSohbet.rows[0]);
  } catch (err) {
    console.error("❌ Sohbet başlatma hatası:", err.message);
    res.status(500).json({
      error: "Sohbet oluşturulamadı",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// 2. Bir sohbetteki eski mesajları getir
exports.mesajlariGetir = async (req, res) => {
  try {
    const { sohbet_id } = req.params;

    // Validasyon
    if (!sohbet_id) {
      return res.status(400).json({ error: "Sohbet ID gereklidir" });
    }

    if (!Number.isInteger(parseInt(sohbet_id))) {
      return res.status(400).json({ error: "Sohbet ID sayı olmalıdır" });
    }

    const mesajlar = await pool.query(
      "SELECT * FROM mesaj WHERE sohbet_id = $1 ORDER BY gonderme_zamani ASC",
      [sohbet_id]
    );

    res.json(mesajlar.rows);
  } catch (err) {
    console.error("❌ Mesaj çekme hatası:", err.message);
    res.status(500).json({
      error: "Mesajlar getirilemedi",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};

// 3. Kullanıcının Gelen Kutusu (Inbox)
exports.sohbetListem = async (req, res) => {
  try {
    const { kullanici_id } = req.params;

    // Validasyon
    if (!kullanici_id) {
      return res.status(400).json({ error: "Kullanıcı ID gereklidir" });
    }

    if (!Number.isInteger(parseInt(kullanici_id))) {
      return res.status(400).json({ error: "Kullanıcı ID sayı olmalıdır" });
    }

    const result = await pool.query(
      `SELECT 
                s.sohbet_id, 
                s.olusturma_zamani,
                s.baslatan_id,
                s.ilan_sahibi_id,
                kb.ad AS baslatan_ad, 
                kb.soyad AS baslatan_soyad,
                ks.ad AS sahip_ad, 
                ks.soyad AS sahip_soyad
             FROM sohbet s
             JOIN kullanici kb ON s.baslatan_id = kb.kullanici_id
             JOIN kullanici ks ON s.ilan_sahibi_id = ks.kullanici_id
             WHERE s.baslatan_id = $1 OR s.ilan_sahibi_id = $1
             ORDER BY s.olusturma_zamani DESC`,
      [kullanici_id]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("❌ Sohbet listesi hatası:", err.message);
    res.status(500).json({
      error: "Sohbet listesi alınamadı",
      details: process.env.NODE_ENV === "development" ? err.message : undefined,
    });
  }
};
