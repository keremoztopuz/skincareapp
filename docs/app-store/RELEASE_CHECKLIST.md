# Skinner App Store Release Checklist

Bu dosya App Store'a cikis icin teknik, hesap, gizlilik ve icerik hazirliklarini takip etmek icindir.

## 7 Eylül 2026 — Yerel düzeltmeler ve kalan yayın kapıları

- AI paylaşımı ilk analiz öncesinde açık izin ister; servis de izni kontrol eder. Ayarlar'dan geri çekilebilir.
- Tek yüz bulunup kırpılamazsa fotoğraf gönderilmez; kayıt ve kota tüketimi yapılmaz.
- Paywall yalnızca StoreKit fiyatlarını gösterir ve gösterdiği paketi satın alır. Ürün yoksa satın alma kapalıdır; deneme yalnızca uygun kullanıcıya gösterilir.
- Depo açma hatasında geçmiş otomatik silinmez. Tüm verileri silme başarısızsa işlem geri alınır ve hata gösterilir.
- Yerel gizlilik kaynağı ve EN/TR kamera/açılış metinleri, fotoğraf + yaş + cilt tipi paylaşımı ve cihazdaki saklamayla eşleştirildi.
- [x] iPhone 17 / iOS 26.2 simülatöründe 40 test geçti: onaysız gönderimin engellenmesi, yüzsüz görüntü kırpımı, deneme uygunluğu, bozuk deponun korunması ve silme hatasının geri alınması dahil.
- [ ] Güncellenmiş `legal/` içeriğini canlı hukuk sitesine yayımla ve bağlantıları doğrula.
- [ ] Son archive'ın privacy raporu, Google saklama ayarları, RevenueCat veri bağları ve App Store Connect App Privacy cevaplarını uzlaştır.
- [ ] TestFlight'ta gerçek kamera, izin reddi/geri çekme, yüz bulunamaması, satın alma/iptal/restore ve denemeyi önceden kullanmış hesapla test et.
- [ ] Hydration/Inflammation dahil skorların yöntem ve doğruluk iddialarını doğrula; açıklama eklenmesi klinik doğrulama yerine geçmez.

Aşağıdaki tarihsel işaretler canlı hesabın bugün tekrar doğrulandığı anlamına gelmez.

## Kritik Bloklar

- [x] Apple Developer Program uyeligi aktif.
- [x] App Store Connect'te yeni app kaydi acildi. RevenueCat app `app91511d0d30` bu kayittan canli urun durumu okuyor.
- [x] Bundle ID: `com.keremoztopuz.SkinCare`. RevenueCat app kaydi da ayni bundle id'yi tasiyor.
- [x] App adi kesinlesti: `Skinner` (Xcode target ve bundle ID hala `SkinCare`; bu kasitli).
- [x] Support URL yayinda: `https://keremoztopuz.github.io/skincare-legal/` — yayinda, 200 donuyor. Kaynak repo: `keremoztopuz/skincare-legal` (public, GitHub Pages main/root).
- [x] Privacy Policy URL yayinda: `https://keremoztopuz.github.io/skincare-legal/privacy` — yayinda. Uzantisiz adres kanonik `/privacy/` adresine 301 ile gidiyor.
- [x] RevenueCat production API key hazir. `RevenueCatConfig.apiKey`, `app91511d0d30` uygulamasinin production public key'i ile birebir ayni.
- [x] App Store Connect subscription urunu hazir. `com.keremoztopuz.skincare.pro.weekly` (ONE_WEEK, 175 bolgede fiyatli, TR ₺99,99, 3 gunluk deneme) ve `...pro.lifetime` `READY_TO_SUBMIT`. Ikisi de `skanner_pro` entitlement'ina bagli — dogrulandi. `...pro.monthly` emekli: hicbir pakete bagli degil ve StoreKit test dosyasindan da cikarildi. Ilk build ile birlikte incelemeye gidecekler.
- [x] RevenueCat entitlement adi **`skanner_pro`** olarak App Store urunune baglandi. (`SubscriptionManager.swift` bu id'yi okur; `pro` yazilirsa hicbir satin alma kilidi acmaz.) `default` offering current ve `$rc_weekly` / `$rc_lifetime` paketleri iki App Store urunune bagli.
- [x] **Paid Applications Agreement — Active (28 Agu 2026).** Gecmis kayit: App Store Connect > Business icinde "Paid Apps" satiri **New** durumunda; yalnizca "Free Apps" Active. Bu sozlesme Active olmadan StoreKit hicbir urun dondurmez: RevenueCat `OfferingsManager.Error 1` verir, paywall bos kalir, sandbox dahil hicbir odeme alinamaz. Sirasiyla: sozlesmeyi kabul et (yalnizca Account Holder yapabilir), Contact Info (Financial / Senior Management / Technical), Bank Account (tuzel kisiyle eslesen IBAN), Tax Forms (ABD icin W-8BEN veya W-8BEN-E, arti yerel vergi bilgisi). Durum New > Pending User Info > Active seklinde ilerler; banka dogrulamasi birkac gun surebilir.
- [x] Sabit fallback fiyatlar kaldırıldı. Fiyat ve deneme süresi StoreKit'ten, deneme uygunluğu RevenueCat'ten alınır; belirsiz uygunlukta deneme vaadi gösterilmez.
- [ ] TestFlight build yuklendi ve gercek cihazda test edildi.

## Teknik Kontroller

- [x] `IPHONEOS_DEPLOYMENT_TARGET` 18.0.
- [x] Release archive Xcode'da basarili (`CODE_SIGNING_ALLOWED=NO` ile dogrulandi, sifir hata).
- [x] Uygulama yalnizca iPhone: `TARGETED_DEVICE_FAMILY = 1`, iPad yonlendirme anahtari kaldirildi. App Store Connect'te de iPad screenshot seti istenmeyecek.
- [x] Kamera izni aciklamasi net.
- [x] Kamera reddedilince kullaniciya anlasilir ekran gosteriliyor.
- [x] Gelismis analiz icin yuz kirpimi Google Gemini'ye gonderiliyor; bu durum uygulama ici aciklamada ve gizlilik politikasinda belirtiliyor. Kalici depolama yapilmiyor.
- [x] Core Data kayitlari lokal tutuluyor.
- [x] Icerik servisi (urun, makale, rutin icerigi) yalnizca okuma amacli kullaniliyor; kullanici verisi gonderilmiyor.
- [ ] Internet yokken analiz denemesi kayit olusturmadan ve tarama hakki yakmadan hata veriyor.
- [x] Icerik servisine ulasilamadiginda uygulama crash olmuyor; Home ve Search yeniden deneme secenegi gosteriyor. Ag hatasi ile sunucu hatasi ayri mesaj veriyor (`AppStrings.loadFailureMessage(for:)`).
- [ ] Abonelik satin alma akisi gercek sandbox hesapla test edildi.
- [ ] Restore purchases calisiyor.
- [ ] Free plan secimi kullaniciyi ana uygulamaya goturuyor.
- [x] Premium olmayan kullanici icin aylik tarama limiti calisiyor.
- [x] Premium kullanici icin limit kalkiyor.

## App Store Connect Bilgileri

- [ ] Primary category: Health & Fitness veya Lifestyle.
- [ ] Age rating sorulari cevaplandi.
- [ ] App Privacy cevaplari girildi.
- [ ] Export compliance cevaplandi.
- [ ] Content rights cevaplandi.
- [ ] Review contact bilgisi girildi.
- [ ] Review notes eklendi.
- [ ] Demo/test hesabi gerekiyorsa eklendi.

## Gorsel Hazirlik

- [x] App icon 1024x1024 hazir.
- [ ] iPhone 6.9 inch screenshot seti hazir.
- [ ] iPhone 6.5 inch screenshot seti hazir.
- [ ] Ekran goruntulerinde tibbi teshis iddiasi yok.
- [ ] Ekran goruntulerinde gercek kullanici yuzu yok veya izinli/temsili gorsel kullanildi.

## Yasal ve Metin Kontrolleri

- [x] App icinde disclaimer var: More > Onemli Uyari (akis adimi degil, her an ulasilabilir sayfa) + her sonuc ekraninda tibbi olmayan ibare.
- [ ] Privacy Policy URL App Store Connect'e eklendi.
- [ ] Support URL App Store Connect'e eklendi.
- [x] Abonelik varsa Terms of Use/EULA linki hazir: `https://keremoztopuz.github.io/skincare-legal/terms` — yayinda.
- [ ] App aciklamasinda "medical diagnosis", "treatment", "cure" gibi iddialar yok.
- [x] App aciklamasi analizlerin bilgilendirme amacli oldugunu soyluyor.

## Release Oncesi Test Senaryolari

- [ ] Temiz kurulum: splash -> onboarding -> profile -> subscription -> main app.
- [ ] Kamera izni verildi.
- [ ] Kamera izni reddedildi.
- [ ] Yuz bulunamayan fotograf.
- [ ] Analiz kaydi olusturma.
- [ ] Recents ekrani analiz gecmisini gosteriyor.
- [x] Search/Home icerik servisi verilerini gosteriyor. Katalog Neon'a tasindi: `neon/seed/` canli projede calistirildi (107 urun, 111 urun-kondisyon bagi, 40 makale). Uygulama artik proxy'nin `/v1/catalogue/*` uclarindan okuyor ve hicbir veritabani kimlik bilgisi tasimiyor.
- [x] Proxy'nin Cloud Run dagitimina `DATABASE_URL` secret'i eklendi ve yeniden deploy edildi (revision `skincare-proxy-00003-f7z`). Canlida dogrulandi: `/v1/catalogue/articles`, `/products` ve `/recommendations` gercek veri donuyor, `/v1/analyze` 200 ve `gemini-2.5-flash` cevabi veriyor. `skinner_reader` rolunun yazma denemesi veritabani tarafindan reddediliyor.
- [x] Katalog kaynaklarina atif verildi. Profil > Ayarlar > Kaynaklar ve Lisanslar ekrani Open Beauty Facts (fotograflar CC BY-SA 3.0, veri ODbL), Pexels ve kullanilan acik kaynak SDK'lari kredilendiriyor. Fotograflarin lisansi atfi sart kosuyor, bu ekran olmadan yayina cikilamaz.
- [ ] Internet kapaliyken uygulama aciliyor.
- [ ] Satin alma iptal edildi.
- [ ] Satin alma basarili.
- [ ] Restore purchases basarili.
- [ ] Uygulama sil-yukle sonrasi UserDefaults/Core Data davranisi kontrol edildi.
