-- Halisaha Projesi - Veritabanı Kurulum Scripti
-- PostgreSQL için

-- Mevcut tabloları sil (temiz başlangıç için)
DROP TABLE IF EXISTS mesaj CASCADE;
DROP TABLE IF EXISTS sohbet CASCADE;
DROP TABLE IF EXISTS rezervasyon CASCADE;
DROP TABLE IF EXISTS sabit_saat_araliklari CASCADE;
DROP TABLE IF EXISTS oyuncu_ilan_bilgisi CASCADE;
DROP TABLE IF EXISTS kullanici CASCADE;

-- Kullanıcı tablosu
CREATE TABLE kullanici (
    kullanici_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    sifre_hash TEXT NOT NULL,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    telefon VARCHAR(20) UNIQUE,
    kayit_tarihi TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Oyuncu ilan bilgisi tablosu
CREATE TABLE oyuncu_ilan_bilgisi (
    ilan_id SERIAL PRIMARY KEY,
    kullanici_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    pozisyon VARCHAR(100) NOT NULL,
    puan_ortalamasi NUMERIC(2, 1) DEFAULT 0.0
);

-- Sabit saat aralıkları tablosu
CREATE TABLE sabit_saat_araliklari (
    saat_araligi_id SERIAL PRIMARY KEY,
    baslangic_saati TIME UNIQUE NOT NULL,
    bitis_saati TIME NOT NULL
);

-- Rezervasyon tablosu
CREATE TABLE rezervasyon (
    rezervasyon_id SERIAL PRIMARY KEY,
    kullanici_id INT NOT NULL,
    tarih DATE NOT NULL,
    saat_araligi_id INT NOT NULL,
    durum VARCHAR(30) DEFAULT 'Onay Bekliyor' NOT NULL,
    
    FOREIGN KEY (kullanici_id) REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    FOREIGN KEY (saat_araligi_id) REFERENCES sabit_saat_araliklari(saat_araligi_id) ON DELETE RESTRICT
);

-- Sohbet tablosu
CREATE TABLE sohbet (
    sohbet_id SERIAL PRIMARY KEY,
    ilan_id INT NOT NULL REFERENCES oyuncu_ilan_bilgisi(ilan_id) ON DELETE CASCADE,
    baslatan_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    ilan_sahibi_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    olusturma_zamani TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE (ilan_id, baslatan_id, ilan_sahibi_id)
);

-- Mesaj tablosu
CREATE TABLE mesaj (
    mesaj_id SERIAL PRIMARY KEY,
    sohbet_id INT NOT NULL REFERENCES sohbet(sohbet_id) ON DELETE CASCADE,
    gonderen_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    icerik TEXT NOT NULL,
    gonderme_zamani TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- İndeksler
CREATE INDEX idx_kullanici_email ON kullanici(email);
CREATE INDEX idx_rezervasyon_tarih ON rezervasyon(tarih);
CREATE INDEX idx_rezervasyon_kullanici ON rezervasyon(kullanici_id);
CREATE INDEX idx_mesaj_sohbet ON mesaj(sohbet_id);
CREATE INDEX idx_sohbet_ilan ON sohbet(ilan_id);

-- Test kullanıcısı ekle (şifre: Test123!)
-- Şifre hash'i: crypto.createHash('sha256').update('Test123!').digest('hex')
INSERT INTO kullanici (email, sifre_hash, ad, soyad, telefon)
VALUES (
    'test@test.com',
    '8c87b489ce35cf2e2f39f80e282cb2e804932a56a213983eeeb428407d43b52d',
    'Test',
    'Kullanıcı',
    '05551234567'
);

-- Örnek saat aralıkları ekle
INSERT INTO sabit_saat_araliklari (baslangic_saati, bitis_saati)
VALUES 
    ('09:00', '10:00'),
    ('10:00', '11:00'),
    ('11:00', '12:00'),
    ('12:00', '13:00'),
    ('13:00', '14:00'),
    ('14:00', '15:00'),
    ('15:00', '16:00'),
    ('16:00', '17:00'),
    ('17:00', '18:00'),
    ('18:00', '19:00'),
    ('19:00', '20:00'),
    ('20:00', '21:00'),
    ('21:00', '22:00'),
    ('22:00', '23:00');

SELECT 'Veritabanı başarıyla oluşturuldu! ✅' AS sonuc;
