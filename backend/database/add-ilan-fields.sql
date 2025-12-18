-- İlanlar tablosuna eksik kolonları ekle
ALTER TABLE ilanlar 
ADD COLUMN IF NOT EXISTS kisi_sayisi INTEGER,
ADD COLUMN IF NOT EXISTS mevki VARCHAR(100),
ADD COLUMN IF NOT EXISTS seviye VARCHAR(50),
ADD COLUMN IF NOT EXISTS ucret VARCHAR(50);

-- Aciklama kolonunu opsiyonel yap
ALTER TABLE ilanlar ALTER COLUMN aciklama DROP NOT NULL;
