const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Upload dizinini oluştur
const uploadDir = path.join(__dirname, '../uploads/profiles');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer storage yapılandırması
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        // Dosya adı: userId-timestamp.extension
        const userId = req.params.userId;
        const ext = path.extname(file.originalname);
        const filename = `user-${userId}-${Date.now()}${ext}`;
        cb(null, filename);
    }
});

// Dosya filtresi (sadece resimler)
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype) || file.mimetype === 'application/octet-stream';

    // Extension doğruysa kabul et (mimetype bazen yanlış olabiliyor)
    if (extname) {
        return cb(null, true);
    } else {
        cb(new Error('Sadece resim dosyaları yüklenebilir (jpeg, jpg, png, gif)'));
    }
};

// Multer middleware
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB limit
    },
    fileFilter: fileFilter
});

module.exports = upload;
