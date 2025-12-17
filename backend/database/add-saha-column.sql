-- Randevular tablosuna saha kolonu ekle
ALTER TABLE randevular 
ADD COLUMN IF NOT EXISTS saha VARCHAR(100) DEFAULT 'Ana Saha';

-- Mevcut kayıtlar için varsayılan değer ata
UPDATE randevular 
SET saha = 'Ana Saha' 
WHERE saha IS NULL;
