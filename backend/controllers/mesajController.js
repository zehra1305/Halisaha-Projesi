const db = require('../config/database');

// Sohbete ait mesajları getir
exports.getMessagesBySohbet = async (req, res) => {
    try {
        const { sohbetId } = req.params;
        const result = await db.query(
            `SELECT m.mesaj_id, m.sohbet_id, m.gonderen_id, m.icerik, m.gonderme_zamani,
                    CONCAT(k.ad, ' ', k.soyad) as gonderen_adi, k.profil_fotografi
             FROM mesaj m
             LEFT JOIN kullanici k ON m.gonderen_id = k.kullanici_id
             WHERE m.sohbet_id = $1
             ORDER BY m.gonderme_zamani ASC`,
            [sohbetId]
        );

        // Profil fotoğrafı URL'lerini düzenle
        const rows = result.rows.map(row => {
            if (row.profil_fotografi && !row.profil_fotografi.startsWith('http')) {
                const path = row.profil_fotografi.startsWith('/') ? row.profil_fotografi.substring(1) : row.profil_fotografi;
                row.profil_fotografi = `http://10.0.2.2:3001/${path}`;
            }
            return row;
        });

        return res.status(200).json(rows);
    } catch (err) {
        console.error('Mesajlar getirme hatası:', err);
        return res.status(500).json({ message: 'Mesajlar yüklenirken hata oluştu', error: err.message });
    }
};

// Yeni mesaj gönder
exports.sendMessage = async (req, res) => {
    try {
        const { sohbet_id, gonderen_id, icerik } = req.body;
        if (!sohbet_id || !gonderen_id || !icerik) {
            return res.status(400).json({ message: 'sohbet_id, gonderen_id ve icerik gerekli' });
        }

        // Sohbetin varlığını kontrol et
        const sohbet = await db.query('SELECT * FROM sohbet WHERE sohbet_id = $1', [sohbet_id]);
        if (sohbet.rows.length === 0) {
            return res.status(404).json({ message: 'Sohbet bulunamadı' });
        }

        const result = await db.query(
            `INSERT INTO mesaj (sohbet_id, gonderen_id, icerik) VALUES ($1, $2, $3) RETURNING *`,
            [sohbet_id, gonderen_id, icerik]
        );

        return res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Mesaj gönderme hatası:', err);
        return res.status(500).json({ message: 'Mesaj gönderilirken hata oluştu', error: err.message });
    }
};
