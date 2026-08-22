# SkinCare App Store Release Checklist

Bu dosya App Store'a cikis icin teknik, hesap, gizlilik ve icerik hazirliklarini takip etmek icindir.

## Kritik Bloklar

- [ ] Apple Developer Program uyeligi aktif.
- [ ] App Store Connect'te yeni app kaydi acildi.
- [ ] Bundle ID: `com.keremoztopuz.SkinCare`.
- [ ] App adi kesinlesti: `SkinCare`.
- [ ] Support URL yayinda.
- [ ] Privacy Policy URL yayinda.
- [ ] RevenueCat production API key hazir.
- [ ] App Store Connect subscription urunu hazir.
- [ ] RevenueCat entitlement adi `pro` olarak App Store urunune baglandi.
- [ ] Uygulama icindeki fiyat/deneme metinleri App Store Connect ile birebir ayni.
- [ ] TestFlight build yuklendi ve gercek cihazda test edildi.

## Teknik Kontroller

- [x] `IPHONEOS_DEPLOYMENT_TARGET` 18.0.
- [ ] Release archive Xcode'da basarili.
- [x] Kamera izni aciklamasi net.
- [x] Kamera reddedilince kullaniciya anlasilir ekran gosteriliyor.
- [x] Gelismis analiz icin yuz kirpimi Google Gemini'ye gonderiliyor; bu durum uygulama ici aciklamada ve gizlilik politikasinda belirtiliyor. Kalici depolama yapilmiyor.
- [x] Core Data kayitlari lokal tutuluyor.
- [x] Supabase sadece urun, makale ve rutin icerigi okumak icin kullaniliyor.
- [ ] Offline durumda temel analiz akisi calisiyor.
- [ ] Supabase baglantisi yokken uygulama crash olmuyor.
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
- [ ] Abonelik varsa Terms of Use/EULA linki hazir.
- [ ] App aciklamasinda "medical diagnosis", "treatment", "cure" gibi iddialar yok.
- [x] App aciklamasi analizlerin bilgilendirme amacli oldugunu soyluyor.

## Release Oncesi Test Senaryolari

- [ ] Temiz kurulum: splash -> onboarding -> disclaimer -> profile -> subscription -> main app.
- [ ] Kamera izni verildi.
- [ ] Kamera izni reddedildi.
- [ ] Yuz bulunamayan fotograf.
- [ ] Analiz kaydi olusturma.
- [ ] Recents ekrani analiz gecmisini gosteriyor.
- [ ] Search/Home Supabase verilerini gosteriyor.
- [ ] Internet kapaliyken uygulama aciliyor.
- [ ] Satin alma iptal edildi.
- [ ] Satin alma basarili.
- [ ] Restore purchases basarili.
- [ ] Uygulama sil-yukle sonrasi UserDefaults/Core Data davranisi kontrol edildi.
