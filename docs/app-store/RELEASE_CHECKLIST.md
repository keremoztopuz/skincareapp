# Skinner App Store Release Checklist

Bu dosya App Store'a cikis icin teknik, hesap, gizlilik ve icerik hazirliklarini takip etmek icindir.

## Kritik Bloklar

- [ ] Apple Developer Program uyeligi aktif.
- [ ] App Store Connect'te yeni app kaydi acildi.
- [ ] Bundle ID: `com.keremoztopuz.SkinCare`.
- [x] App adi kesinlesti: `Skinner` (Xcode target ve bundle ID hala `SkinCare`; bu kasitli).
- [ ] Support URL yayinda: `https://keremoztopuz.github.io/skincare-legal/` — **BLOKE**, `legal/` klasoru hazir ama Pages sitesi henuz yayinlanmadi (bkz. `legal/README.md`).
- [ ] Privacy Policy URL yayinda: `https://keremoztopuz.github.io/skincare-legal/privacy` — **BLOKE**, ayni Pages sitesi.
- [ ] RevenueCat production API key hazir.
- [ ] App Store Connect subscription urunu hazir.
- [ ] RevenueCat entitlement adi **`skanner_pro`** olarak App Store urunune baglandi. (`SubscriptionManager.swift` bu id'yi okur; `pro` yazilirsa hicbir satin alma kilidi acmaz.)
- [ ] Uygulama icindeki fiyat/deneme metinleri App Store Connect ile birebir ayni. (Lifetime tier'i henuz TR bazindan esitlenmedi — `APP_STORE_METADATA_DRAFT.md` fiyat tablosuna bakin.)
- [ ] TestFlight build yuklendi ve gercek cihazda test edildi.

## Teknik Kontroller

- [x] `IPHONEOS_DEPLOYMENT_TARGET` 18.0.
- [x] Release archive Xcode'da basarili (`CODE_SIGNING_ALLOWED=NO` ile dogrulandi, sifir hata).
- [ ] **Karar bekliyor — iPad:** target `TARGETED_DEVICE_FAMILY = "1,2"` (iPhone + iPad) ama iPad'de sadece portrait destekleniyor ve `UIRequiresFullScreen` yok. Archive bunu uyari olarak veriyor ve App Review iPad'de calismayan bir iPad build'ini reddedebilir. Uygulama iPhone icin tasarlandi (metadata'da yalnizca iPhone screenshot seti var). Ya device family `1`'e cekilmeli ya da iPad duzeni gercekten test edilmeli.
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

- [x] App icinde disclaimer var.
- [ ] Privacy Policy URL App Store Connect'e eklendi.
- [ ] Support URL App Store Connect'e eklendi.
- [ ] Abonelik varsa Terms of Use/EULA linki hazir: `https://keremoztopuz.github.io/skincare-legal/terms` — sayfa yazildi, yayinlanmayi bekliyor.
- [ ] App aciklamasinda "medical diagnosis", "treatment", "cure" gibi iddialar yok.
- [x] App aciklamasi analizlerin bilgilendirme amacli oldugunu soyluyor.

## Release Oncesi Test Senaryolari

- [ ] Temiz kurulum: splash -> onboarding -> disclaimer -> profile -> subscription -> main app.
- [ ] Kamera izni verildi.
- [ ] Kamera izni reddedildi.
- [ ] Yuz bulunamayan fotograf.
- [ ] Analiz kaydi olusturma.
- [ ] Recents ekrani analiz gecmisini gosteriyor.
- [ ] Search/Home icerik servisi verilerini gosteriyor. — **BLOKE**: `supabase/seed/00_schema.sql` canli projede hic calistirilmadi, tum liste sorgulari HTTP 400 donuyor. Backend Vertex'e tasinana kadar katalog bos kalacak (bilinen ve kabul edilmis durum).
- [ ] Internet kapaliyken uygulama aciliyor.
- [ ] Satin alma iptal edildi.
- [ ] Satin alma basarili.
- [ ] Restore purchases basarili.
- [ ] Uygulama sil-yukle sonrasi UserDefaults/Core Data davranisi kontrol edildi.
