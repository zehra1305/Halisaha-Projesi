# Sohbet / Mesaj API

## Sohbetleri listele (kullanıcıya göre)
GET /api/sohbet?userId={userId}

Success (200):
[
  {
    "sohbet_id": 1,
    "ilan_id": 5,
    "baslatan_id": 10,
    "ilan_sahibi_id": 2,
    "olusturma_zamani": "...",
    "son_mesaj": "Son gönderilen mesaj içeriği",
    "son_mesaj_zamani": "..."
  }
]

## Sohbet oluştur
POST /api/sohbet
Content-Type: application/json
{
  "ilan_id": 5,
  "baslatan_id": 10,
  "ilan_sahibi_id": 2
}

Success: 201 -> created sohbet object (veya var olan sohbet 200 ile döner)

## Sohbete ait mesajları getir
GET /api/mesaj/sohbet/{sohbetId}

Success (200):
[
  {
    "mesaj_id": 1,
    "sohbet_id": 1,
    "gonderen_id": 10,
    "icerik": "Merhaba",
    "gonderme_zamani": "...",
    "gonderen_adi": "Ahmet Yılmaz",
    "profil_fotografi": "/uploads/.."
  }
]

## Mesaj gönder
POST /api/mesaj
Content-Type: application/json
{
  "sohbet_id": 1,
  "gonderen_id": 10,
  "icerik": "Merhaba"
}

Success: 201 -> created mesaj object

