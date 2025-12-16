# PostgreSQL Kurulum ve Çalıştırma Rehberi

## 📥 1. PostgreSQL Kurulumu

### Windows için:
1. **İndirin:** https://www.postgresql.org/download/windows/
2. **Kurulum sırasında:**
   - Şifre belirleyin: `z1234` (veya .env'deki DB_PASSWORD)
   - Port: `5432`
   - pgAdmin 4'ü işaretli bırakın

## 🗄️ 2. Veritabanını Oluştur

### Seçenek A: pgAdmin Kullanarak

1. pgAdmin 4'ü açın
2. PostgreSQL 16 > Veritabanları'na sağ tıklayın
3. "Create" > "Database"
4. Database name: `halisaha_proje_db`
5. Save

### Seçenek B: PowerShell/CMD ile

```powershell
# PostgreSQL dizinine gidin (varsayılan yol)
cd "C:\Program Files\PostgreSQL\16\bin"

# Veritabanını oluşturun
.\psql.exe -U postgres -c "CREATE DATABASE halisaha_proje_db;"
```

## 📊 3. Tabloları Oluştur

### pgAdmin'de SQL Query ile:

1. pgAdmin'de `halisaha_proje_db` veritabanını seçin
2. Tools > Query Tool
3. `backend/setup-database.sql` dosyasının içeriğini yapıştırın
4. ▶️ Execute tuşuna basın

### VEYA PowerShell ile:

```powershell
cd C:\Users\mesat\Desktop\Halisaha_Project\Halisaha-Projesi\backend

# SQL dosyasını çalıştır
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d halisaha_proje_db -f setup-database.sql
```

Şifre istendiğinde: `z1234` (veya kurulumda belirlediğiniz)

## ✅ 4. Veritabanı Bağlantısını Test Et

```powershell
cd backend
npm start
```

Tarayıcıda aç: http://localhost:3001/api/health-db

Görmeli: `"Veritabanı bağlantısı başarılı ✅"`

## 🎯 5. Test Kullanıcısı

Veritabanı kurulduğunda otomatik oluşturulur:

- **Email:** test@test.com
- **Şifre:** Test123!

## 🚀 6. Projeyi Çalıştır

### Terminal 1 - Backend:
```powershell
cd backend
npm start
```

### Terminal 2 - Flutter:
```powershell
cd mobile
flutter run
```

## 🔍 Sorun Giderme

### Bağlantı Hatası Alıyorsanız:

1. PostgreSQL servisinin çalıştığından emin olun:
   ```powershell
   Get-Service postgresql*
   ```

2. Çalışmıyorsa başlatın:
   ```powershell
   Start-Service postgresql-x64-16
   ```

3. .env dosyasını kontrol edin:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=z1234
   DB_NAME=halisaha_proje_db
   ```

4. pgAdmin'de bağlantıyı test edin

### Şifre Hatası:

Eğer şifreniz farklıysa, `.env` dosyasındaki `DB_PASSWORD` değerini değiştirin.

### Port Zaten Kullanılıyor:

Eğer 5432 portu kullanılıyorsa, PostgreSQL config dosyasında port'u değiştirin:
`C:\Program Files\PostgreSQL\16\data\postgresql.conf`

## 📱 Kullanıcıları Görüntüleme

### pgAdmin'de:
```sql
SELECT * FROM kullanici;
```

### SQL Query:
```sql
SELECT kullanici_id, email, ad, soyad, telefon, kayit_tarihi 
FROM kullanici 
ORDER BY kayit_tarihi DESC;
```

## 🎉 Başarı!

Artık projeniz gerçek PostgreSQL veritabanı ile çalışıyor!

Yeni kullanıcı kaydettiğinizde pgAdmin'de görebilirsiniz.
