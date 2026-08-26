# App Store screenshot'ları

İki boyut hazır. Aynı kareler, aynı isimler:

| Klasör | Boyut | Yuva |
| --- | --- | --- |
| `6.9-inch/` | 1320 × 2868 | 6.9" |
| `6.5-inch/` | 1284 × 2778 | 6.5" |

iPhone 17 Pro Max simülatöründe, 26 Ağustos 2026'da Türkçe arayüzle çekildi.
Alpha kanalı kaldırıldı (App Store Connect alpha içeren PNG kabul etmez).

6.5" seti 6.9" karelerinden üretildi: 1284 genişliğe küçültülüp yüksekliği
2778'e ortadan kırpıldı. İki oran %0,4 farklı olduğu için ölçekleme tek başına
kareyi eziyordu; kırpma üstten ve alttan toplam 12 piksel alıyor, o da durum
çubuğunun boşluğuna denk geliyor. Küçültme olduğu için netlik kaybı yok.

## Bilinen hata

`02-home.png` ana ekranı değil **splash ekranını** gösteriyor. Aşağıdaki
sırada 1 numara olarak duruyor; mağazaya yüklemeden önce ana ekran karesiyle
değiştirilmeli.

## App Store Connect'e yüklenecek sıra

| # | Dosya | Ekran |
| --- | --- | --- |
| 1 | `02-home.png` | Ana ekran — skor kartları ve trend grafiği |
| 2 | `04-result.png` | Analiz sonucu — koşul kartları, ürün önerileri |
| 3 | `03-camera-guide.png` | Kamera rehberi — doğru/yanlış çekim |
| 4 | `05-recents.png` | Son analizler — skor ve trend listesi |
| 5 | `06-search.png` | Ürün kataloğu |
| 6 | `01-onboarding.png` | Karşılama ekranı |

`07-paywall.png`, `08-profile.png` ve `09-camera.png` yedek; Apple paywall
ağırlıklı görselleri sevmediği için 7 numarayı ancak abonelik akışını
göstermek istersen ekle.

## Gerçek cihazda yenilenmesi gerekenler

- **Analiz fotoğrafı yok.** Ekranlar simülatörde çekildiği için kayıtlarda yüz
  görüntüsü yok; `04-result.png` üstündeki "Taranan Görüntü" alanı ve
  `05-recents.png` küçük resimleri boş görünüyor. Kendi yüzünle gerçek bir
  analiz yapıp bu ikisini cihazdan yeniden çekmek görseli belirgin
  iyileştirir.
- **`09-camera.png`** simülatörde kamera olmadığı için gri bir dikdörtgen
  gösteriyor. Mağazaya koyacaksan gerçek cihazda çek.
- Skorlar (69 ortalama, 78 son analiz) simülatöre elle yazılmış beş kayıttan
  geliyor; gerçek analizlerle üretilen değerler değil. Mağaza görselinde
  sorun değil ama gerçek cihaz çekimi tercih edilir.
