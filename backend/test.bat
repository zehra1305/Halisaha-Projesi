@echo off
REM Login Test Scripti

echo Giriş Test Yapılıyor...
echo.

REM Giriş Testi - Doğru Şifre
echo 1. Dogru sifresi ile giris:
curl -X POST http://localhost:3001/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@test.com\",\"password\":\"test123\"}"

echo.
echo.

REM Giriş Testi - Yanlış Şifre
echo 2. Yanlis sifresi ile giris:
curl -X POST http://localhost:3001/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@test.com\",\"password\":\"wrongpassword\"}"

echo.
echo.

REM Kayıt Test
echo 3. Yeni Kullanici Kaydı:
curl -X POST http://localhost:3001/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"yeni@test.com\",\"password\":\"password123\",\"passwordConfirm\":\"password123\",\"ad\":\"Yeni\",\"soyad\":\"Kullanıcı\",\"telefon\":\"05559876543\"}"

pause
