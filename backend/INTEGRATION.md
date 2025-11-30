# Backend ve Mobile Entegrasyonu - Halisaha Projesi

## 📋 Tamamlanan İşlemler

### Backend (Node.js + PostgreSQL)
✅ **Konum:** `c:\Users\Monster\Desktop\halisaha`
- Express.js sunucusu (Port: 3001)
- PostgreSQL veritabanı bağlantısı
- API Routes:
  - `POST /api/auth/register` - Kullanıcı kayıt
  - `POST /api/auth/login` - Kullanıcı giriş
- Veritabanı tabloları ve şema

### Mobile (Flutter)
✅ **Konum:** `c:\Users\Monster\Desktop\Halisaha-Projesi\mobile`
- Flutter mobil uygulaması
- Giriş/Kayıt ekranları (Auth Screen)
- Ana sayfa (Home Screen)
- Backend bağlantısı (HTTP service)

---

## 🔗 Entegrasyon Detayları

### 1. **AuthService** (API Bağlantısı)
**Dosya:** `lib/services/auth_service.dart`
- Register endpoint'ine istek gönder
- Login endpoint'ine istek gönder
- JSON serialize/deserialize

### 2. **Auth Screen** (Giriş/Kayıt UI)
**Dosya:** `lib/screens/auth_screen.dart`
- Email, Şifre, Ad, Soyad, Telefon alanları
- Form validasyonu
- Backend'e API çağrısı
- Hata/Başarı mesajları

### 3. **Home Screen** (Ana Sayfa)
**Dosya:** `lib/screens/home_screen.dart`
- Kullanıcı bilgilerini göster
- Çıkış Yap butonu

### 4. **Main App**
**Dosya:** `lib/main.dart`
- State yönetimi (Kullanıcı oturumu)
- Navigation (Auth <-> Home)

---

## 🚀 API Endpoints

```
BASE URL: http://localhost:3001/api/auth
```

### Register
```
POST /register
{
  "email": "user@example.com",
  "password": "password123",
  "passwordConfirm": "password123",
  "ad": "Ahmet",
  "soyad": "Yılmaz",
  "telefon": "05551234567"
}

Response (201):
{
  "success": true,
  "message": "Kayıt başarılı",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "ad": "Ahmet",
    "soyad": "Yılmaz"
  }
}
```

### Login
```
POST /login
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "success": true,
  "message": "Giriş başarılı",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "ad": "Ahmet",
    "soyad": "Yılmaz"
  }
}
```

---

## 📁 Proje Yapısı

```
halisaha/                          (Backend)
├── config/
│   └── database.js
├── controllers/
│   └── authController.js
├── routes/
│   └── auth.js
├── database/
│   └── schema.sql
├── .env
├── package.json
├── server.js
└── seed.js

Halisaha-Projesi/mobile/           (Mobile)
├── lib/
│   ├── services/
│   │   └── auth_service.dart
│   ├── screens/
│   │   ├── auth_screen.dart
│   │   └── home_screen.dart
│   └── main.dart
├── pubspec.yaml
└── ...
```

---

## 🔧 Dependencies

### Backend
- `express` - Web framework
- `pg` - PostgreSQL client
- `dotenv` - Environment variables
- `cors` - Cross-Origin Resource Sharing

### Mobile
- `http` - HTTP client
- `flutter` - UI framework

---

## ✅ Sonraki Adımlar

1. **Backend'i çalıştır:**
   ```bash
   cd c:\Users\Monster\Desktop\halisaha
   npm run dev
   ```

2. **Database test verisini yükle:**
   ```bash
   node seed.js
   ```

3. **Flutter'ı çalıştır:**
   ```bash
   cd c:\Users\Monster\Desktop\Halisaha-Projesi\mobile
   flutter pub get
   flutter run
   ```

4. **Test Et:**
   - Giriş ekranında kayıt ol
   - Giriş yap
   - Ana sayfada kullanıcı bilgisini gör

---

## 🌐 Network Bağlantısı

- **Development:** `localhost:3001` (Android emülatör için: `10.0.2.2:3001`)
- **Production:** Sunucu IP'si kullanılacak

Flutter Android emülatörü için `authService.dart`'ta değişiklik:
```dart
final String baseUrl = 'http://10.0.2.2:3001/api/auth';
```

---

## 📝 Notlar

- Database şifresi hash'lenir (SHA256)
- Email ve telefon benzersizlik kontrolü yapılır
- Şifre minimum 8 karakter
- Tüm API yanıtları JSON formatında

