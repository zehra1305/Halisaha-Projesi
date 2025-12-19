const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chatController");

// Validasyon Middleware'leri
const validatePostBody = (req, res, next) => {
  if (!req.body || Object.keys(req.body).length === 0) {
    return res.status(400).json({ error: "İstek gövdesi boş olamaz" });
  }
  next();
};

const validateId = (paramName) => {
  return (req, res, next) => {
    const id = req.params[paramName];
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({ error: `Geçersiz ${paramName}` });
    }
    next();
  };
};

// Hata işleme Middleware
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Yeni sohbet başlatma veya var olanı getirme
router.post(
  "/baslat",
  validatePostBody,
  asyncHandler(chatController.sohbetBaslat)
);

// Bir sohbetin geçmiş mesajlarını çekme
router.get(
  "/mesajlar/:sohbet_id",
  validateId("sohbet_id"),
  asyncHandler(chatController.mesajlariGetir)
);

// Kullanıcının sohbet listesi (Gelen Kutusu)
router.get(
  "/liste/:kullanici_id",
  validateId("kullanici_id"),
  asyncHandler(chatController.sohbetListem)
);

module.exports = router;
