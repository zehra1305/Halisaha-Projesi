const db = require('../config/database');

// Kullanıcıya ait sohbetleri getir
exports.getSohbetlerByUser = async (req, res) => {
    try {
        const { userId } = req.query;
        if (!userId) return res.status(400).json({ message: 'userId sorgu parametresi gerekli' });

        const result = await db.query(`
            SELECT s.sohbet_id, s.ilan_id, s.baslatan_id, s.ilan_sahibi_id, s.olusturma_zamani,
                   m.icerik as son_mesaj, m.gonderme_zamani as son_mesaj_zamani,
                   CASE WHEN s.baslatan_id = $1 THEN s.ilan_sahibi_id ELSE s.baslatan_id END as diger_kullanici_id,
                   k.ad as diger_kullanici_ad, k.profil_fotografi as diger_kullanici_fotografi
            FROM sohbet s
            LEFT JOIN LATERAL (
                SELECT icerik, gonderme_zamani
                FROM mesaj
                WHERE sohbet_id = s.sohbet_id
                ORDER BY gonderme_zamani DESC
                LIMIT 1
            ) m ON true
            LEFT JOIN kullanici k ON k.kullanici_id = CASE WHEN s.baslatan_id = $1 THEN s.ilan_sahibi_id ELSE s.baslatan_id END
            WHERE s.baslatan_id = $1 OR s.ilan_sahibi_id = $1
            ORDER BY COALESCE(m.gonderme_zamani, s.olusturma_zamani) DESC
        `, [userId]);

        return res.status(200).json(result.rows);
    } catch (err) {
        console.error('Sohbetler getirme hatası:', err);
        return res.status(500).json({ message: 'Sohbetler yüklenirken hata oluştu', error: err.message });
    }
};

// Yeni sohbet oluştur (varsa var olanı döndür)
exports.createSohbet = async (req, res) => {
    try {
        const { ilan_id, baslatan_id, ilan_sahibi_id } = req.body;
        if (!ilan_id || !baslatan_id || !ilan_sahibi_id) {
            return res.status(400).json({ message: 'ilan_id, baslatan_id ve ilan_sahibi_id gerekli' });
        }

        // Eğer zaten varsa, mevcut sohbeti döndür
        const existing = await db.query(
            `SELECT * FROM sohbet WHERE ilan_id = $1 AND baslatan_id = $2 AND ilan_sahibi_id = $3`,
            [ilan_id, baslatan_id, ilan_sahibi_id]
        );

        if (existing.rows.length > 0) {
            return res.status(200).json(existing.rows[0]);
        }

        const result = await db.query(
            `INSERT INTO sohbet (ilan_id, baslatan_id, ilan_sahibi_id) VALUES ($1, $2, $3) RETURNING *`,
            [ilan_id, baslatan_id, ilan_sahibi_id]
        );

        return res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Sohbet oluşturma hatası:', err);
        return res.status(500).json({ message: 'Sohbet oluşturulurken hata oluştu', error: err.message });
    }
};

// Sohbet detayını getir
exports.getSohbetById = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await db.query(`SELECT * FROM sohbet WHERE sohbet_id = $1`, [id]);
        if (result.rows.length === 0) return res.status(404).json({ message: 'Sohbet bulunamadı' });
        return res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('Sohbet getirme hatası:', err);
        return res.status(500).json({ message: 'Sohbet yüklenirken hata oluştu', error: err.message });
    }
};
