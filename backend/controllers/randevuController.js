const pool = require('../config/database');

// Randevu oluştur
const createRandevu = async (req, res) => {
  const { kullaniciId, tarih, saatBaslangic, saatBitis, telefon, aciklama } = req.body;

  // DEBUG LOG
  console.log('=== BACKEND RANDEVU OLUŞTUR ===');
  console.log('Request Body:', req.body);
  console.log('Tarih:', tarih);
  console.log('Saat:', saatBaslangic, '-', saatBitis);
  console.log('================================');

  try {
    // Zorunlu alanları kontrol et
    if (!kullaniciId || !tarih || !saatBaslangic || !saatBitis || !telefon) {
      return res.status(400).json({
        success: false,
        message: 'Kullanıcı ID, tarih, saat ve telefon zorunludur',
      });
    }

    // Seçilen saat diliminin uygun olup olmadığını kontrol et
    const checkQuery = `
      SELECT * FROM randevular 
      WHERE tarih = $1 
      AND saat_baslangic = $2 
      AND saat_bitis = $3
      AND durum IN ('beklemede', 'onaylandi')
    `;
    const checkResult = await pool.query(checkQuery, [tarih, saatBaslangic, saatBitis]);

    if (checkResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Bu saat dilimi dolu veya onay bekliyor',
      });
    }

    // Randevu oluştur
    const insertQuery = `
      INSERT INTO randevular 
      (kullanici_id, tarih, saat_baslangic, saat_bitis, telefon, aciklama, durum) 
      VALUES ($1, $2, $3, $4, $5, $6, 'beklemede') 
      RETURNING 
        randevu_id as "randevuId",
        kullanici_id as "kullaniciId",
        tarih,
        saat_baslangic as "saatBaslangic",
        saat_bitis as "saatBitis",
        durum,
        telefon,
        aciklama,
        olusturma_tarihi as "olusturmaTarihi"
    `;

    const result = await pool.query(insertQuery, [
      kullaniciId,
      tarih,
      saatBaslangic,
      saatBitis,
      telefon,
      aciklama || null,
    ]);

    res.status(201).json({
      success: true,
      message: 'Randevu talebi oluşturuldu, onay bekleniyor',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Randevu oluşturma hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Randevu oluşturulurken hata oluştu',
      error: error.message,
    });
  }
};

// Kullanıcının randevularını getir
const getRandevularByUser = async (req, res) => {
  const { userId } = req.params;

  try {
    const query = `
      SELECT 
        randevu_id as "randevuId",
        kullanici_id as "kullaniciId",
        tarih,
        saat_baslangic as "saatBaslangic",
        saat_bitis as "saatBitis",
        durum,
        telefon,
        aciklama,
        olusturma_tarihi as "olusturmaTarihi"
      FROM randevular 
      WHERE kullanici_id = $1 
      ORDER BY tarih DESC, saat_baslangic DESC
    `;

    const result = await pool.query(query, [userId]);

    res.status(200).json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error('Randevu getirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Randevular getirilirken hata oluştu',
    });
  }
};

// Yaklaşan onaylı randevuyu getir (anasayfa için)
const getYaklasanRandevu = async (req, res) => {
  const { userId } = req.params;

  try {
    const query = `
      SELECT 
        randevu_id as "randevuId",
        kullanici_id as "kullaniciId",
        tarih,
        saat_baslangic as "saatBaslangic",
        saat_bitis as "saatBitis",
        durum,
        saha,
        telefon,
        aciklama
      FROM randevular 
      WHERE kullanici_id = $1 
      AND durum = 'onaylandi'
      AND tarih >= CURRENT_DATE
      AND (tarih > CURRENT_DATE OR 
           (tarih = CURRENT_DATE AND saat_baslangic > CURRENT_TIME))
      ORDER BY tarih ASC, saat_baslangic ASC
      LIMIT 1
    `;

    const result = await pool.query(query, [userId]);

    res.status(200).json({
      success: true,
      data: result.rows[0] || null,
    });
  } catch (error) {
    console.error('Yaklaşan randevu getirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Yaklaşan randevu getirilirken hata oluştu',
    });
  }
};

// Tüm yaklaşan onaylı randevuları getir (anasayfa için)
const getYaklasanRandevular = async (req, res) => {
  const { userId } = req.params;

  try {
    const query = `
      SELECT 
        randevu_id as "randevuId",
        kullanici_id as "kullaniciId",
        tarih,
        saat_baslangic as "saatBaslangic",
        saat_bitis as "saatBitis",
        durum,
        saha,
        telefon,
        aciklama
      FROM randevular 
      WHERE kullanici_id = $1 
      AND durum = 'onaylandi'
      AND tarih >= CURRENT_DATE
      AND (tarih > CURRENT_DATE OR 
           (tarih = CURRENT_DATE AND saat_baslangic > CURRENT_TIME))
      ORDER BY tarih ASC, saat_baslangic ASC
    `;

    const result = await pool.query(query, [userId]);

    res.status(200).json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error('Yaklaşan randevular getirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Yaklaşan randevular getirilirken hata oluştu',
    });
  }
};

// Müsait saatleri getir
const getMusaitSaatler = async (req, res) => {
  const { tarih } = req.query;

  try {
    if (!tarih) {
      return res.status(400).json({
        success: false,
        message: 'Tarih zorunludur',
      });
    }

    // Tüm dolu/bekleyen saatleri getir
    const query = `
      SELECT saat_baslangic, saat_bitis 
      FROM randevular 
      WHERE tarih = $1 
      AND durum IN ('beklemede', 'onaylandi')
    `;

    const result = await pool.query(query, [tarih]);

    // Tüm saatler (12:00-00:00)
    const tumSaatler = [
      { baslangic: '12:00', bitis: '13:00' },
      { baslangic: '13:00', bitis: '14:00' },
      { baslangic: '14:00', bitis: '15:00' },
      { baslangic: '15:00', bitis: '16:00' },
      { baslangic: '16:00', bitis: '17:00' },
      { baslangic: '17:00', bitis: '18:00' },
      { baslangic: '18:00', bitis: '19:00' },
      { baslangic: '19:00', bitis: '20:00' },
      { baslangic: '20:00', bitis: '21:00' },
      { baslangic: '21:00', bitis: '22:00' },
      { baslangic: '22:00', bitis: '23:00' },
      { baslangic: '23:00', bitis: '00:00' },
    ];

    // Dolu saatleri filtrele (saniye kısmını kaldır: '15:00:00' -> '15:00')
    const doluSaatler = result.rows.map(row => row.saat_baslangic.substring(0, 5));
    const musaitSaatler = tumSaatler.filter(
      saat => !doluSaatler.includes(saat.baslangic)
    );

    res.status(200).json({
      success: true,
      data: musaitSaatler,
    });
  } catch (error) {
    console.error('Müsait saatler getirme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Müsait saatler getirilirken hata oluştu',
    });
  }
};

// Randevu iptal et
const cancelRandevu = async (req, res) => {
  const { id } = req.params;
  const { kullaniciId } = req.body;

  try {
    const query = `
      UPDATE randevular 
      SET durum = 'iptal' 
      WHERE randevu_id = $1 
      AND kullanici_id = $2 
      AND durum IN ('beklemede', 'onaylandi')
      RETURNING randevu_id as "randevuId"
    `;

    const result = await pool.query(query, [id, kullaniciId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Randevu bulunamadı veya iptal edilemez',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Randevu iptal edildi',
    });
  } catch (error) {
    console.error('Randevu iptal hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Randevu iptal edilirken hata oluştu',
    });
  }
};

// ADMIN: Tüm randevuları getir
const getAllRandevularAdmin = async (req, res) => {
  try {
    const query = `
      SELECT 
        r.randevu_id as "randevuId",
        r.kullanici_id as "kullaniciId",
        r.tarih,
        r.saat_baslangic as "saatBaslangic",
        r.saat_bitis as "saatBitis",
        r.durum,
        r.telefon,
        r.aciklama,
        r.olusturma_tarihi as "olusturmaTarihi",
        CONCAT(k.ad, ' ', k.soyad) as "kullaniciAdi",
        k.email as "kullaniciEmail"
      FROM randevular r
      LEFT JOIN kullanici k ON r.kullanici_id = k.kullanici_id
      ORDER BY r.tarih DESC, r.saat_baslangic DESC
    `;

    const result = await pool.query(query);

    res.status(200).json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error('Admin randevu listesi hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Randevular getirilirken hata oluştu',
    });
  }
};

// ADMIN: Randevu onayla/reddet
const updateRandevuDurum = async (req, res) => {
  const { id } = req.params;
  const { durum } = req.body; // 'onaylandi' veya 'reddedildi'

  try {
    if (!['onaylandi', 'reddedildi'].includes(durum)) {
      return res.status(400).json({
        success: false,
        message: 'Geçersiz durum',
      });
    }

    const query = `
      UPDATE randevular 
      SET durum = $1 
      WHERE randevu_id = $2 
      RETURNING randevu_id as "randevuId", durum
    `;

    const result = await pool.query(query, [durum, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Randevu bulunamadı',
      });
    }

    res.status(200).json({
      success: true,
      message: `Randevu ${durum === 'onaylandi' ? 'onaylandı' : 'reddedildi'}`,
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Randevu durum güncelleme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Randevu durumu güncellenirken hata oluştu',
    });
  }
};

module.exports = {
  createRandevu,
  getRandevularByUser,
  getYaklasanRandevu,
  getYaklasanRandevular,
  getMusaitSaatler,
  cancelRandevu,
  getAllRandevularAdmin,
  updateRandevuDurum,
};
