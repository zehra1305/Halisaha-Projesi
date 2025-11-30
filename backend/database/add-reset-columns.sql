-- Şifre sıfırlama için kullanici tablosuna kolonlar ekleniyor

ALTER TABLE kullanici 
ADD COLUMN IF NOT EXISTS reset_code VARCHAR(6),
ADD COLUMN IF NOT EXISTS reset_code_expiry TIMESTAMP;

-- İndeks ekle (performans için)
CREATE INDEX IF NOT EXISTS idx_reset_code ON kullanici(reset_code);
CREATE INDEX IF NOT EXISTS idx_reset_code_expiry ON kullanici(reset_code_expiry);

-- Kontrol
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'kullanici' AND column_name IN ('reset_code', 'reset_code_expiry');
