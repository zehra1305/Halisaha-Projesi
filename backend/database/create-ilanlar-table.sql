-- İlanlar tablosu oluşturma
CREATE TABLE IF NOT EXISTS ilanlar (
    ilan_id SERIAL PRIMARY KEY,
    ad_soyad VARCHAR(100) NOT NULL,
    baslik VARCHAR(200) NOT NULL,
    konum VARCHAR(200) NOT NULL,
    tarih VARCHAR(20) NOT NULL,
    saat VARCHAR(10) NOT NULL,
    kisi_sayisi VARCHAR(20) NOT NULL,
    mevki VARCHAR(100) NOT NULL,
    seviye VARCHAR(50),
    ucret VARCHAR(50),
    aciklama TEXT,
    yas VARCHAR(10),
    kullanici_id INTEGER,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kullanici_id) REFERENCES kullanici(kullanici_id) ON DELETE SET NULL
);

-- İndeks oluşturma (performans için)
CREATE INDEX IF NOT EXISTS idx_ilanlar_kullanici_id ON ilanlar(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_ilanlar_tarih ON ilanlar(tarih);
CREATE INDEX IF NOT EXISTS idx_ilanlar_olusturma_tarihi ON ilanlar(olusturma_tarihi);

-- Örnek veri ekleme (opsiyonel)
-- INSERT INTO ilanlar (
--     ad_soyad, 
--     baslik, 
--     konum, 
--     tarih, 
--     saat, 
--     kisi_sayisi, 
--     mevki, 
--     seviye, 
--     ucret, 
--     aciklama, 
--     yas
-- ) VALUES 
-- (
--     'Ahmet Yılmaz', 
--     'Pazartesi Akşam Maçı', 
--     'Rüya Halı Saha - Kayseri', 
--     '20/12/2025', 
--     '19:00', 
--     '5', 
--     'Defans, Orta Saha', 
--     'Orta', 
--     '50 TL', 
--     'Hafta içi maç için oyuncu arıyoruz', 
--     '25'
-- );
