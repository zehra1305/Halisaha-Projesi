// controllers/reservationController.js
const Reservation = require('../models/Reservation');

// Uygulamanın çalışma saatleri (17:00 - 23:00)
const allowedHours = [
  '17:00',
  '18:00',
  '19:00',
  '20:00',
  '21:00',
  '22:00',
  '23:00',
];

// Belirli bir tarihteki dolu saatleri getirir
// Flutter → GET isteği atar → Backend veritabanına bakar → dolu saatleri döner
exports.doluSaatleriGetir = async (req, res) => {
  try {
    const { tarih } = req.query;

    // Tarih gönderilmemişse hata ver
    if (!tarih) {
      return res.status(400).json({
        status: 'error',
        message: 'tarih parametresi zorunludur',
      });
    }

    // BU TARİHTEKİ TÜM RANDEVULARI BUL (Sequelize)
    const randevular = await Reservation.findAll({
      where: { tarih },
    });

    // Sadece saatleri al (["17:00","19:00", ...])
    const doluSaatler = randevular.map((r) => r.saat);

    return res.json({
      status: 'ok',
      tarih,
      doluSaatler,
      tumSaatler: allowedHours,
    });
  } catch (error) {
    console.error('doluSaatleriGetir hata:', error);
    res.status(500).json({ status: 'error', message: 'Sunucu hatası' });
  }
};

exports.randevuOlustur = async (req, res) => {
  try {
    const { tarih, saat, not } = req.body;

    // Zorunlu alan kontrolü
    if (!tarih || !saat) {
      return res.status(400).json({
        status: 'error',
        message: 'tarih ve saat alanları zorunludur',
      });
    }

    // Saat çalışma saatleri içinde mi?
    if (!allowedHours.includes(saat)) {
      return res.status(400).json({
        status: 'error',
        message: 'Bu saat çalışma saatleri (17:00-23:00) dışında',
      });
    }

    // Aynı gün ve aynı saat daha önce alınmış mı?
    const zatenVarMi = await Reservation.findOne({
      where: { tarih, saat },
    });

    if (zatenVarMi) {
      // Bu gün için güncel dolu saat listesini tekrar çek
      const randevular = await Reservation.findAll({
        where: { tarih },
      });
      const doluSaatler = randevular.map((r) => r.saat);

      return res.status(400).json({
        status: 'full',
        message: 'Bu saat zaten dolu!',
        tarih,
        doluSaatler,
        tumSaatler: allowedHours,
      });
    }

    // Saat uygunsa ve boşsa yeni randevu kaydı oluştur
    const yeniRandevu = await Reservation.create({ tarih, saat, not });

    // Kaydettikten sonra aynı günün güncel dolu saatlerini tekrar çek
    const randevularSon = await Reservation.findAll({
      where: { tarih },
    });
    const doluSaatlerSon = randevularSon.map((r) => r.saat);

    return res.status(201).json({
      status: 'success',
      message: 'Randevu başarıyla oluşturuldu',
      tarih,
      yeniRandevu,
      doluSaatler: doluSaatlerSon,
      tumSaatler: allowedHours,
    });
  } catch (error) {
    console.error('randevuOlustur hata:', error);
    res.status(500).json({ status: 'error', message: 'Sunucu hatası' });
  }
};