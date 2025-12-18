-- Randevular tablosu oluşturma
CREATE TABLE IF NOT EXISTS randevular (
    randevu_id SERIAL PRIMARY KEY,
    kullanici_id INTEGER REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    tarih DATE NOT NULL,
    saat_baslangic TIME NOT NULL,
    saat_bitis TIME NOT NULL,
    durum VARCHAR(20) DEFAULT 'beklemede' CHECK (durum IN ('beklemede', 'onaylandi', 'reddedildi', 'iptal')),
    saha VARCHAR(100) DEFAULT 'Ana Saha',
    telefon VARCHAR(20),
    aciklama TEXT,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    guncelleme_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tarih, saat_baslangic, saat_bitis) -- Aynı saat diliminde çift rezervasyon olmasın
);

-- Indexler
CREATE INDEX idx_randevular_kullanici ON randevular(kullanici_id);
CREATE INDEX idx_randevular_tarih ON randevular(tarih);
CREATE INDEX idx_randevular_durum ON randevular(durum);
CREATE INDEX idx_randevular_tarih_saat ON randevular(tarih, saat_baslangic);

-- Güncelleme trigger'ı
CREATE OR REPLACE FUNCTION update_randevu_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.guncelleme_tarihi = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_randevu_timestamp
BEFORE UPDATE ON randevular
FOR EACH ROW
EXECUTE FUNCTION update_randevu_timestamp();
