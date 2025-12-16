# Halisaha Projesi - Backend API

Node.js ile PostgreSQL veritabanı bağlantısı

## Proje Yapısı

```
halisaha/
├── config/
│   └── database.js          # Database bağlantı yapılandırması
├── database/
│   └── schema.sql           # Veritabanı tabloları SQL kodları
├── routes/                  # API route'ları (yakında eklenecek)
├── controllers/             # Business logic (yakında eklenecek)
├── models/                  # Database models (yakında eklenecek)
├── .env                     # Çevre değişkenleri (GIT ignore yapılmalı)
├── package.json             # Proje bağımlılıkları
├── server.js                # Ana sunucu dosyası
└── README.md               # Bu dosya
```

## Kurulum

### 1. Bağımlılıkları yükle
```bash
npm install
```

### 2. .env dosyasını kontrol et
```
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=z1234
DB_NAME=halisaha_proje_db
PORT=3000
NODE_ENV=development
```

### 3. PostgreSQL'de veritabanını ve tabloları oluştur
```bash
# PostgreSQL komut satırında
psql -U postgres -h localhost

# Veritabanını oluştur
CREATE DATABASE halisaha_proje_db;

# Tabloları oluştur (database/schema.sql dosyasını çalıştır)
\c halisaha_proje_db
\i database/schema.sql
```

Veya terminal'den doğrudan:
```bash
psql -U postgres -h localhost -c "CREATE DATABASE halisaha_proje_db;"
psql -U postgres -h localhost -d halisaha_proje_db -f database/schema.sql
```

### 4. Sunucuyu başlat

Geliştirme modu (nodemon ile):
```bash
npm run dev
```

Üretim modu:
```bash
npm start
```

## API Endpoints

### Health Check
- **GET** `/health` - Sunucu sağlık kontrolü
- **GET** `/api/health-db` - Veritabanı bağlantı testi

## Database Bağlantı Bilgileri

- **Host:** localhost
- **Port:** 5432
- **User:** postgres
- **Password:** z1234
- **Database:** halisaha_proje_db

## Veritabanı Tabloları

1. **kullanici** - Kullanıcı bilgileri
2. **oyuncu_ilan_bilgisi** - Oyuncu ilanları
3. **Sabit_Saat_Araliklari** - Saat aralıkları
4. **Rezervasyon** - Rezervasyon bilgileri
5. **sohbet** - Sohbet odaları
6. **mesaj** - Mesajlar

## Teknolojiler

- **Node.js** - JavaScript runtime
- **Express** - Web framework
- **PostgreSQL** - Veritabanı
- **pg** - PostgreSQL client
- **dotenv** - Çevre değişkenleri
- **CORS** - Cross-Origin Resource Sharing

## Not

`.env` dosyasını `.gitignore` dosyasına ekle!
