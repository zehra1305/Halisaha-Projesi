-- Profil fotoğrafı kolonu ekle
ALTER TABLE kullanici 
ADD COLUMN IF NOT EXISTS profil_fotografi VARCHAR(255);

-- İndeks ekle (performans için)
CREATE INDEX IF NOT EXISTS idx_profil_fotografi ON kullanici(profil_fotografi);

-- Kontrol
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'kullanici' AND column_name = 'profil_fotografi';
