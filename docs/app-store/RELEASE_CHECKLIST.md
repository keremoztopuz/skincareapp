# Skinner App Store Release Checklist

Bu dosya App Store'a cikis icin teknik, hesap, gizlilik ve icerik hazirliklarini takip etmek icindir.

## Kritik Bloklar

- [x] Apple Developer Program uyeligi aktif.
- [x] App Store Connect'te yeni app kaydi acildi. RevenueCat app `app91511d0d30` bu kayittan canli urun durumu okuyor.
- [x] Bundle ID: `com.keremoztopuz.SkinCare`. RevenueCat app kaydi da ayni bundle id'yi tasiyor.
- [x] App adi kesinlesti: `Skinner` (Xcode target ve bundle ID hala `SkinCare`; bu kasitli).
- [x] Support URL yayinda: `https://keremoztopuz.github.io/skincare-legal/` — yayinda, 200 donuyor. Kaynak repo: `keremoztopuz/skincare-legal` (public, GitHub Pages main/root).
- [x] Privacy Policy URL yayinda: `https://keremoztopuz.github.io/skincare-legal/privacy` — yayinda. Uzantisiz adres kanonik `/privacy/` adresine 301 ile gidiyor.
- [x] RevenueCat production API key hazir. `RevenueCatConfig.apiKey`, `app91511d0d30` uygulamasinin production public key'i ile birebir ayni.
- [x] App Store Connect subscription urunu hazir. `com.keremoztopuz.skincare.pro.monthly` ve `...pro.lifetime` ikisi de `READY_TO_SUBMIT`: tum bolgelerde fiyat, en-US + tr yerellestirme, review ekran goruntusu ve notu girili. Ilk build ile birlikte incelemeye gidecekler.
- [x] RevenueCat entitlement adi **`skanner_pro`** olarak App Store urunune baglandi. (`SubscriptionManager.swift` bu id'yi okur; `pro` yazilirsa hicbir satin alma kilidi acmaz.) `default` offering current ve `$rc_weekly` / `$rc_lifetime` paketleri iki App Store urunune bagli.
- [x] Uygulama icindeki fiyat/deneme metinleri App Store Connect ile birebir ayni. `FallbackPrice.lifetime` canli tier'lere gore duzeltildi ($17.99/€19,99 yerine $12.99/€14,99); abonelik 26 Agustos'ta haftaliga cevrildi, `FallbackPrice.weekly` TR ₺99,99 / $3.99 / €3,99 ile uyuyor. Hicbir yerde deneme suresi vaadi yok — App Store Connect'te tanimli bir `trial_offer` da yok.
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

- [x] App icinde disclaimer var.
- [ ] Privacy Policy URL App Store Connect'e eklendi.
- [ ] Support URL App Store Connect'e eklendi.
- [x] Abonelik varsa Terms of Use/EULA linki hazir: `https://keremoztopuz.github.io/skincare-legal/terms` — yayinda.
- [ ] App aciklamasinda "medical diagnosis", "treatment", "cure" gibi iddialar yok.
- [x] App aciklamasi analizlerin bilgilendirme amacli oldugunu soyluyor.

## Release Oncesi Test Senaryolari

- [ ] Temiz kurulum: splash -> onboarding -> disclaimer -> profile -> subscription -> main app.
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
