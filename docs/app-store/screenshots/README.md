# App Store ekran görüntüleri

Yüklemeye hazır iki yerelleştirilmiş set vardır:

| Klasör | Dil | Boyut |
| --- | --- | --- |
| `final-tr/` | Türkçe | 1320 × 2868 (6.9 inç) |
| `final-en/` | İngilizce | 1320 × 2868 (6.9 inç) |

Dosyalar yüksek kaliteli JPEG'dir ve alpha kanalı içermez. Apple, 6.9 inç seti verildiğinde
6.5 inç ekran görüntülerini zorunlu tutmadığı için eski `6.5-inch/` setini
yüklemeyin.

## Yükleme sırası

1. `01-home.jpg` — skor kartları ve trend grafiği
2. `02-result.jpg` — analiz sonucu ve genel skor
3. `03-regions.jpg` — tıklanabilir bölgesel görünüm
4. `04-recents.jpg` — analiz geçmişi
5. `05-compare.jpg` — iki analizin karşılaştırması
6. `06-search.jpg` — ürün kataloğu

Görseller temsili, lisanslı uygulama varlıkları ve Debug-only örnek kayıtlarla
üretilmiştir. Demo veri ve doğrudan ekran yönlendirmeleri Release derlemesine
girmez.

## Yeniden üretme

Kök dizinde `./scripts/capture_app_store_screenshots.sh` çalıştırılır. Script
iPhone 17 Pro Max simülatörünü kullanır, Türkçe ve İngilizce setleri yeniden
JPEG olarak çeker; böylece alpha kanalı oluşmaz.
