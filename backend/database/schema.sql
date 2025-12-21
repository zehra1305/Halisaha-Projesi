-- Halisaha Projesi - Veritabanı Tabloları

CREATE TABLE kullanici (
    kullanici_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    sifre_hash TEXT NOT NULL,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    telefon VARCHAR(20) UNIQUE
);

CREATE TABLE oyuncu_ilan_bilgisi (
    ilan_id SERIAL PRIMARY KEY,
    kullanici_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE CASCADE,
    pozisyon VARCHAR(100) NOT NULL,
    puan_ortalamasi NUMERIC(2, 1) DEFAULT 0.0
);

CREATE TABLE Sabit_Saat_Araliklari (
    saat_araligi_id SERIAL PRIMARY KEY,
    baslangic_saati TIME UNIQUE NOT NULL,
    bitis_saati TIME NOT NULL
);

CREATE TABLE Rezervasyon (
    rezervasyon_id SERIAL PRIMARY KEY,
    kullanici_id INT NOT NULL,
    tarih DATE NOT NULL,
    saat_araligi_id INT NOT NULL,
    durum VARCHAR(30) DEFAULT 'Onay Bekliyor' NOT NULL,
    
    FOREIGN KEY (kullanici_id) REFERENCES Kullanici(kullanici_id) ON DELETE RESTRICT,
    FOREIGN KEY (saat_araligi_id) REFERENCES Sabit_Saat_Araliklari(saat_araligi_id) ON DELETE RESTRICT
);

CREATE TABLE sohbet (
    sohbet_id SERIAL PRIMARY KEY,
    ilan_id INT NOT NULL REFERENCES oyuncu_ilan_bilgisi(ilan_id) ON DELETE CASCADE,
    baslatan_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    ilan_sahibi_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    olusturma_zamani TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE (baslatan_id, ilan_sahibi_id)
);

CREATE TABLE mesaj (
    mesaj_id SERIAL PRIMARY KEY,
    sohbet_id INT NOT NULL REFERENCES sohbet(sohbet_id) ON DELETE CASCADE,
    gonderen_id INT NOT NULL REFERENCES kullanici(kullanici_id) ON DELETE RESTRICT,
    icerik TEXT NOT NULL,
    gonderme_zamani TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
