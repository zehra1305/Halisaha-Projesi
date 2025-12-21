-- Geri bildirimler tablosu
CREATE TABLE IF NOT EXISTS geri_bildirimler (
    id SERIAL PRIMARY KEY,
    kullanici_id INTEGER NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    baslik VARCHAR(200),
    mesaj TEXT NOT NULL,
    kategori VARCHAR(50) DEFAULT 'Genel',
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index ekle
CREATE INDEX IF NOT EXISTS idx_geri_bildirimler_kullanici ON geri_bildirimler(kullanici_id);
