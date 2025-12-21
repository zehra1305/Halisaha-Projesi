-- Mevcut veritabanındaki sohbet tablosu constraint'ini düzeltmek için
-- Bu script ilan_id'ye bağlı UNIQUE constraint'i kaldırıp
-- sadece iki kullanıcı arasında bir sohbet kalmayı sağlar

-- Eski constraint'i kaldır
ALTER TABLE sohbet DROP CONSTRAINT sohbet_ilan_id_baslatan_id_ilan_sahibi_id_key;

-- Yeni constraint ekle (iki kullanıcı arasında sadece bir sohbet)
ALTER TABLE sohbet ADD CONSTRAINT sohbet_baslatan_id_ilan_sahibi_id_key UNIQUE (baslatan_id, ilan_sahibi_id);

-- Eğer aynı iki kişi arasında birden fazla sohbet varsa, en yenisini tut ve diğerlerini sil
-- (Bu adım opsiyonel ama veritabanını temizlemek için önerilir)
DELETE FROM sohbet s1
WHERE EXISTS (
    SELECT 1 FROM sohbet s2
    WHERE s2.baslatan_id = s1.baslatan_id
    AND s2.ilan_sahibi_id = s1.ilan_sahibi_id
    AND s2.sohbet_id > s1.sohbet_id
);
