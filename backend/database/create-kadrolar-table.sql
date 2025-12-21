-- Kadrolar tablosu
CREATE TABLE IF NOT EXISTS kadrolar (
    id SERIAL PRIMARY KEY,
    kullanici_id INTEGER REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    kadro_adi VARCHAR(100) NOT NULL,
    format VARCHAR(20) NOT NULL, -- 'yediyeYedi' veya 'sekizeSekiz'
    takim_a_adi VARCHAR(50) NOT NULL,
    takim_b_adi VARCHAR(50) NOT NULL,
    takim_a_renk VARCHAR(20) NOT NULL, -- Hex color value (örn: '#FF0000')
    takim_b_renk VARCHAR(20) NOT NULL,
    takim_a_oyunculari JSONB NOT NULL, -- [{id, isim, numarasi, formaRengi, pozisyon}]
    takim_b_oyunculari JSONB NOT NULL,
    olusturulma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    guncelleme_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index'ler
CREATE INDEX IF NOT EXISTS idx_kadrolar_kullanici ON kadrolar(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_kadrolar_tarih ON kadrolar(olusturulma_tarihi DESC);

-- Güncelleme trigger'ı
CREATE OR REPLACE FUNCTION update_guncelleme_tarihi()
RETURNS TRIGGER AS $$
BEGIN
    NEW.guncelleme_tarihi = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER kadrolar_guncelleme_tarihi
    BEFORE UPDATE ON kadrolar
    FOR EACH ROW
    EXECUTE FUNCTION update_guncelleme_tarihi();
