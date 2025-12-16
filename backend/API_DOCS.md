# Halisaha Backend API - Kimlik Doğrulama Endpoints

## 📝 Kayıt Olma (Register)

### Request
```
POST http://localhost:3001/api/auth/register
Content-Type: application/json

{
    "email": "user@example.com",
    "password": "password123",
    "passwordConfirm": "password123",
    "ad": "Ahmet",
    "soyad": "Yılmaz",
    "telefon": "05551234567"
}
```

### Success Response (201)
```json
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

### Error Responses
- 400: Eksik alanlar, şifre uyuşmazlığı, zayıf şifre, geçersiz email, Email/Telefon zaten kayıtlı
- 500: Sunucu hatası

---

## 🔐 Giriş Yapma (Login)

### Request
```
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
    "email": "user@example.com",
    "password": "password123"
}
```

### Success Response (200)
```json
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

### Error Responses
- 400: Email veya şifre eksik, geçersiz email formatı
- 401: Email veya şifre hatalı
- 500: Sunucu hatası

---

## 🧪 Test Komutu (Curl)

### Kayıt Olma
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123",
    "passwordConfirm": "password123",
    "ad": "Test",
    "soyad": "Kullanıcı",
    "telefon": "05551234567"
  }'
```

### Giriş Yapma
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123"
  }'
```

---

## ✅ Özellikler

- ✅ Email ve telefon benzersizlik kontrolü
- ✅ Şifre hash'leme (SHA256)
- ✅ Email format validasyonu
- ✅ Şifre güç kontrolü (minimum 8 karakter)
- ✅ Şifre eşleştirme kontrolü
- ✅ Detaylı hata mesajları
