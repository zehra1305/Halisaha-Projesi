const pool = require('../config/database');

// Tüm kadroları getir
exports.getKadrolar = async (req, res) => {
  try {
    const { kullanici_id } = req.query;
    
    if (!kullanici_id) {
      return res.status(400).json({ success: false, message: 'Kullanıcı ID gerekli' });
    }

    const result = await pool.query(
      'SELECT * FROM kadrolar WHERE kullanici_id = $1 ORDER BY olusturulma_tarihi DESC',
      [kullanici_id]
    );

    res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('Kadro getirme hatası:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası' });
  }
};

// Tek kadro getir
exports.getKadro = async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query(
      'SELECT * FROM kadrolar WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Kadro bulunamadı' });
    }

    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Kadro getirme hatası:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası' });
  }
};

// Kadro oluştur
exports.createKadro = async (req, res) => {
  try {
    console.log('Kadro oluşturma isteği:', req.body);
    const {
      kullanici_id,
      kadro_adi,
      format,
      takim_a_adi,
      takim_b_adi,
      takim_a_renk,
      takim_b_renk,
      takim_a_oyunculari,
      takim_b_oyunculari,
    } = req.body;

    if (!kullanici_id || !kadro_adi || !format) {
      return res.status(400).json({ success: false, message: 'Gerekli alanlar eksik' });
    }

    const result = await pool.query(
      `INSERT INTO kadrolar 
        (kullanici_id, kadro_adi, format, takim_a_adi, takim_b_adi, 
         takim_a_renk, takim_b_renk, takim_a_oyunculari, takim_b_oyunculari) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
       RETURNING *`,
      [
        kullanici_id,
        kadro_adi,
        format,
        takim_a_adi,
        takim_b_adi,
        takim_a_renk,
        takim_b_renk,
        JSON.stringify(takim_a_oyunculari),
        JSON.stringify(takim_b_oyunculari),
      ]
    );

    res.json({ success: true, data: result.rows[0], message: 'Kadro oluşturuldu' });
  } catch (error) {
    console.error('Kadro oluşturma hatası:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası' });
  }
};

// Kadro güncelle
exports.updateKadro = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      kadro_adi,
      format,
      takim_a_adi,
      takim_b_adi,
      takim_a_renk,
      takim_b_renk,
      takim_a_oyunculari,
      takim_b_oyunculari,
    } = req.body;

    const result = await pool.query(
      `UPDATE kadrolar 
       SET kadro_adi = $1, format = $2, takim_a_adi = $3, takim_b_adi = $4,
           takim_a_renk = $5, takim_b_renk = $6, 
           takim_a_oyunculari = $7, takim_b_oyunculari = $8
       WHERE id = $9 
       RETURNING *`,
      [
        kadro_adi,
        format,
        takim_a_adi,
        takim_b_adi,
        takim_a_renk,
        takim_b_renk,
        JSON.stringify(takim_a_oyunculari),
        JSON.stringify(takim_b_oyunculari),
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Kadro bulunamadı' });
    }

    res.json({ success: true, data: result.rows[0], message: 'Kadro güncellendi' });
  } catch (error) {
    console.error('Kadro güncelleme hatası:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası' });
  }
};

// Kadro sil
exports.deleteKadro = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM kadrolar WHERE id = $1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Kadro bulunamadı' });
    }

    res.json({ success: true, message: 'Kadro silindi' });
  } catch (error) {
    console.error('Kadro silme hatası:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası' });
  }
};
