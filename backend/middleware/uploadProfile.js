const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Dosya türü kontrolü: Yalnızca resim dosyalarına (JPEG, JPG, PNG) izin verir.
const fileFilter = (req, file, cb) => {
    const allowedFileTypes = ['image/jpeg', 'image/jpg', 'image/png'];
    
    // Dosya türü izin verilenler listesinde yoksa hata fırlat.
    if (!allowedFileTypes.includes(file.mimetype)) {
        cb(new Error('Yalnızca jpeg, jpg ve png formatındaki resim dosyalarına izin verilir.'), false); 
    } else {
        // Dosya türü doğru ise devam et.
        cb(null, true);
    }
}

// Depolama ayarları
const storage = multer.diskStorage({
    // Yükleme dizini ayarı
    destination: (req, file, cb) => { 
        const rootdir = path.dirname(require.main.filename);
        // Klasörü daha spesifik bir yere ayırma: public/uploads/profile_photos
        const uploadPath = path.join(rootdir, 'public/uploads/profile_photos'); 
        
        // Klasör yoksa oluştur
        if (!fs.existsSync(uploadPath)) {
             fs.mkdirSync(uploadPath, { recursive: true });
        }
        
        cb(null, uploadPath); 
    },
    
    // Dosya adı oluşturma ayarı
    filename: function (req, file, cb) {
        // Kullanıcı ID'sini al (varsa) ve rastgele sayı ile benzersiz dosya adı oluşturma
        // NOT: req.user veya req.session'da kullanıcı ID'sinin olduğu varsayılır.
        const userId = req.user && req.user.id ? req.user.id : 'anonymous';
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9); 
        
        // Orijinal dosya uzantısını path modülü ile al
        const extension = path.extname(file.originalname); 
        
        // Yeni dosya adı formatı: [kullanici_id]-[timestamp]-[random_suffix][uzanti]
        const url = `${userId}-${uniqueSuffix}${extension}`;
        
        // req.savedimage gibi gereksiz mantık kaldırıldı.
        cb(null, url); 
    }
});

// Multer yapılandırması: Tekil dosya yükleme middleware'i
const uploadProfilePhoto = multer({ 
    storage: storage, 
    fileFilter: fileFilter,
    limits: { 
        fileSize: 1024 * 1024 * 5 // Max 5MB limit eklendi
    } 
}).single('profile_photo'); // Form alan adı 'profile_photo' olarak ayarlandı

module.exports = uploadProfilePhoto;
