# 📱 Flutter / Backend Entegrasyonu - GitHub Yükleme Kılavuzu

## 🎯 Takım Arkadaşınız Ne Yapmalı?

### 1. **Repository'yi Clone Etme**
```bash
git clone https://github.com/zehra1305/Halisaha-Projesi.git
cd Halisaha-Projesi
```

### 2. **Backend Setup (Node.js)**
```bash
cd halisaha

# Dependency'leri yükle
npm install

# .env dosyasını kontrol et (PostgreSQL bağlantısı)
# Eğer veritabanı adresi farklıysa .env dosyasını düzenle

# Tabloları oluştur
npm run seed  # veya: node seed.js

# Sunucuyu başlat
npm run dev
```

### 3. **Mobile Setup (Flutter)**
```bash
cd Halisaha-Projesi/mobile

# Flutter dependency'lerini yükle
flutter pub get

# Windows Desktop'ta çalıştır
flutter run -d windows

# Veya Web'de çalıştır
flutter run -d chrome

# Veya Android Emulator'de
flutter run
```

---

## 📦 GitHub'a Yüklemeden Önce Yapılacaklar

### Backend (.gitignore)
```
node_modules/
.env
.env.local
.env.*.local
.DS_Store
*.log
npm-debug.log*
```

### Mobile (Zaten .gitignore var ✅)
- `build/` klasörü
- `.dart_tool/` klasörü
- `.pub-cache/` otomatik hariç tutulur

---

## ✅ GitHub'a Yüklenen Dosyalar

### Backend
```
halisaha/
├── config/database.js
├── controllers/authController.js
├── routes/auth.js
├── database/schema.sql
├── server.js
├── seed.js
├── package.json
├── .env.example  (← .env'nin template'i)
├── .gitignore
├── README.md
└── API_DOCS.md
```

### Mobile
```
Halisaha-Projesi/mobile/
├── lib/
│   ├── services/auth_service.dart
│   ├── screens/auth_screen.dart
│   ├── screens/home_screen.dart
│   └── main.dart
├── pubspec.yaml
├── .gitignore
└── README.md
```

---

## 🔒 Hassas Bilgileri Gizle

### Backend için .env.example oluştur
```bash
# .env.example dosyası oluştur
cp .env .env.example

# .env.example'deki parolaları değiştir
# İçeriği:
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD_HERE
DB_NAME=halisaha_proje_db
PORT=3000
NODE_ENV=development
```

Takım arkadaşı `.env.example`'dan kopyala ve kendi veritabanı bilgisini ekle:
```bash
cp .env.example .env
# Sonra .env dosyasını düzenle
```

---

## 🌐 API URL'sini Dinamik Yapma (Mobile)

Takım arkadaşınızın farklı bir sunucu IP'si varsa, `auth_service.dart`'ta değişiklik yapması gerekir:

**Geliştirme (localhost):**
```dart
final String baseUrl = 'http://localhost:3001/api/auth';
```

**Android Emulator:**
```dart
final String baseUrl = 'http://10.0.2.2:3001/api/auth';
```

**Gerçek cihaz/başka sunucu:**
```dart
final String baseUrl = 'http://YOUR_SERVER_IP:3001/api/auth';
```

---

## 📋 Checklist - GitHub'a Yüklemeden Önce

- [ ] Backend `.gitignore` kontrol et (node_modules hariç)
- [ ] `.env` dosyasını `.gitignore`'a ekle
- [ ] `.env.example` template'i oluştur
- [ ] Mobile `pubspec.lock` dosyasını yükle (dependency sürümleri sabitlemek için)
- [ ] `README.md` dosyalarını kontrol et
- [ ] `API_DOCS.md` backend'de var mı kontrol et

---

## 🚀 Takım Arkadaşınız Bu Adımları İzleyecek

1. Repo'yu clone et
2. `halisaha` klasörüne gir → `npm install` → `npm run dev`
3. `mobile` klasörüne gir → `flutter pub get` → `flutter run`
4. Backend ve Mobile'ın aynı ağda olduğundan emin ol
5. Test et: Kayıt ol → Giriş yap → Ana sayfa

---

## ⚠️ Önemli Notlar

- Flutter projesinde `pubspec.lock` yükle (sürümleri sabitle)
- Backend'de `package-lock.json` yükle
- `.env` dosyasını GIT'e yükleme (gizli bilgiler)
- Database schema'sı `database/schema.sql`'de

---

## 📞 Sorun Çıkarsa

### Backend bağlanmıyor?
- PostgreSQL çalışıyor mu kontrol et
- `.env` dosyasında host/port doğru mu kontrol et
- `npm run seed` ile veritabanını başlat

### Flutter localhost'a bağlanmıyor?
- Backend gerçekten çalışıyor mu?
- Windows: `localhost:3001` kullan
- Android: `10.0.2.2:3001` kullan
- Firewall kontrol et

### Dependency sorunları?
```bash
# Backend
rm -r node_modules
npm install

# Mobile
flutter pub get --no-offline
flutter clean
```

