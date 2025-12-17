-- Halisaha Projesi - Supabase Setup
-- Tüm tabloları sırayla oluşturur

-- 1. Kullanıcı Tablosu
CREATE TABLE IF NOT EXISTS kullanici (
    kullanici_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    sifre_hash TEXT NOT NULL,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    telefon VARCHAR(20) UNIQUE,
    olusturma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    profil_fotografi TEXT
);

-- 2. Şifre Sıfırlama Tablosu
ALTER TABLE kullanici 
ADD COLUMN IF NOT EXISTS reset_code VARCHAR(6),
ADD COLUMN IF NOT EXISTS reset_code_expires TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS reset_verified BOOLEAN DEFAULT FALSE;

-- 3. Randevular Tablosu
CREATE TABLE IF NOT EXISTS randevular (
    randevu_id SERIAL PRIMARY KEY,
    kullanici_id INTEGER NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    tarih DATE NOT NULL,
    saat_baslangic TIME NOT NULL,
    saat_bitis TIME NOT NULL,
    telefon VARCHAR(11) NOT NULL,
    aciklama TEXT,
    durum VARCHAR(20) DEFAULT 'beklemede' CHECK (durum IN ('beklemede', 'onaylandi', 'reddedildi', 'iptal')),
    olusturma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. İlanlar Tablosu
CREATE TABLE IF NOT EXISTS ilanlar (
    ilan_id SERIAL PRIMARY KEY,
    kullanici_id INTEGER NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    baslik VARCHAR(100) NOT NULL,
    aciklama TEXT,
    tarih DATE NOT NULL,
    saat VARCHAR(20) NOT NULL,
    konum VARCHAR(100) NOT NULL,
    kisi_sayisi INTEGER,
    mevki VARCHAR(100),
    seviye VARCHAR(50),
    ucret VARCHAR(50),
    olusturma_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. İndeksler (Performans için)
CREATE INDEX IF NOT EXISTS idx_randevular_kullanici ON randevular(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_randevular_tarih ON randevular(tarih);
CREATE INDEX IF NOT EXISTS idx_randevular_durum ON randevular(durum);
CREATE INDEX IF NOT EXISTS idx_ilanlar_kullanici ON ilanlar(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_ilanlar_tarih ON ilanlar(tarih);

-- 6. Örnek Veriler (Test için - opsiyonel)
-- INSERT INTO kullanici (email, sifre_hash, ad, soyad, telefon) VALUES
-- ('test@test.com', '$2b$10$...', 'Test', 'User', '05551234567');
