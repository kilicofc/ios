# Tane Tane (iOS, SwiftUI)

Seviye seviye ilerleyen Türkçe diksiyon çalışma uygulaması. iOS 16 ve üstü.

İçinde: 6 seviye, 29 çalışma, nefes küresi, hız ayarlı okuma, ses kaydı ve dinleme, günlük plan, seri ve ilerleme takibi.

> Bu proje yazıldı ama derlenip denenmedi. İlk derlemede küçük bir hata çıkarsa Actions günlüğündeki ilk kırmızı satırı bana gönder.

## Yol 1: Mac'in yok (GitHub ile .ipa üret)

1. github.com'da ücretsiz hesap aç, yeni ve **boş** bir depo oluştur (Private olabilir).
2. Bu zip'in içindekileri depoya yükle: **Add file → Upload files**. `.github` klasörü gizli olduğu için görünmeyebilir. Görünmüyorsa **Add file → Create new file** de, dosya adına `.github/workflows/build-ipa.yml` yaz ve zip'teki aynı adlı dosyanın içeriğini yapıştır.
3. Depoda **Actions** sekmesine gir, **Build unsigned IPA** akışını seç, **Run workflow**'a bas.
4. 5-10 dakika sonra akış yeşil olunca çalışmanın sayfasının altındaki **Artifacts** bölümünden `TaneTane-ipa`'yı indir. Zip'in içinden `TaneTane.ipa` çıkar.
5. Bilgisayarına Sideloadly'yi aç, `TaneTane.ipa`'yı sürükle, Apple ID'ni gir, **Start**'a bas. Sideloadly imzayı kendisi atar.
6. iPhone'da **Ayarlar → Genel → VPN ve Aygıt Yönetimi** bölümünden geliştirici profiline güven ver. iOS 16 ve üstünde ayrıca **Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu**'nu açman gerekir.

Ücretsiz Apple ID ile imzalanan uygulama 7 gün sonra süresi dolar. Sideloadly ile aynı yöntemle yeniden yüklersin, ilerlemen silinmez.

## Yol 2: Mac'in var

```
brew install xcodegen
xcodegen generate
open TaneTane.xcodeproj
```

Xcode'da hedefi iPhone'una seç, **Signing & Capabilities** bölümünde kendi Apple ID takımını seç, çalıştır.

## Bilmen gerekenler

- Bu sürümde yapay zekâ koçu yok. O özellik web sürümünde var; yerel uygulamaya koymak için bir API anahtarı gerekir.
- Ses kaydı iPhone'da geçici tutulur ve uygulama kapanınca silinir.
- İlerleme telefonda saklanır, buluta gönderilmez.
