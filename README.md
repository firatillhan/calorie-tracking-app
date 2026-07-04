# Kalori Takip Uygulaması

Fikrinden önce yediklerime zaten dikkat ediyordum ama kendime net bir limit
koymuyordum. "Kalori açığı oluşturmalısın" gibi cümleleri duyunca, bunu
somut bir şekilde takip edebileceğim bir uygulama yapmak istedim. Piyasadaki
hazır kalori takip uygulamalarının çoğu reklam ve abonelik dolu, gereksiz
özelliklerle karmaşıklaşmış durumda; benim ihtiyaç duyduğum bazı basit
özellikler (örneğin Apple Health'ten yakılan kaloriyi otomatik günlük
hedefe yansıtmak gibi) ise ya hiç yoktu ya da ücretli sürümde kilitliydi.
Bu yüzden kendi verim tamamen kendi kontrolümde kalacak şekilde, sadece
ihtiyacım olan özelliklerle, sade bir versiyonu kendim geliştirmeyi tercih
ettim. Kullanmak isteyen olursa diye projeyi GitHub'a açık şekilde paylaşmayı
tercih ettim.

## Özellikler

- **Kayıt ekleme**: Yediğin yiyeceği manuel olarak (adet × birim kalori) veya
  önceden oluşturduğun bir yiyecek kütüphanesinden seçerek ekleyebilirsin.
  Fotoğraf, içerik notu, tarih ve saat otomatik ekleniyor.
- **Takvim görünümü**: Ay bazlı takvimde her gün için kayıt olup olmadığı ve
  hedefin aşılıp aşılmadığı (yeşil/kırmızı nokta) görünüyor. Geçmiş günlere
  dönüp o günün detaylarını inceleyebilirsin.
- **Kişiye özel kalori hedefi**: Boy, kilo, yaş, cinsiyet, hareket düzeyi ve
  hedefine (kilo verme/koruma/alma) göre Mifflin-St Jeor formülüyle günlük
  kalori ihtiyacını hesaplıyor.
- **Tarihe bağlı hedef geçmişi**: Hedefini değiştirdiğinde bu değişiklik sadece
  değiştirdiğin tarihten itibaren geçerli oluyor; geçmiş günlerin hedefi
  olduğu gibi kalıyor.
- **Apple Health entegrasyonu**: Telefon/Apple Watch üzerinden o gün yakılan
  aktif kaloriyi çekip günlük hedefe otomatik ekliyor.

## Kullanılan Teknolojiler

- **SwiftUI** — arayüz
- **SwiftData** — yerel veri saklama (yiyecek kayıtları, kütüphane, hedef geçmişi)
- **HealthKit** — Apple Health'ten aktif kalori verisi
- **PhotosUI** — fotoğraf seçimi

## Kurulum

1. Projeyi Xcode ile aç (iOS 17+ gerekiyor, SwiftData bunu şart koşuyor).
2. Signing & Capabilities sekmesinden **HealthKit** capability'sinin ekli
   olduğundan emin ol.
3. Info sekmesinde **Privacy - Health Share Usage Description** izninin
   girildiğinden emin ol.
4. Gerçek bir cihazda çalıştır (HealthKit simulator'da düzgün çalışmaz).

## Geliştirme Notu

Bu proje, Claude (Anthropic) ile birlikte "vibe coding" yaklaşımıyla
geliştirilmiştir — mimari kararlar ve kod yazımı büyük ölçüde yapay zeka
desteğiyle yapılmış, geliştirici test ederek ve davranışı doğrulayarak süreci
yönlendirmiştir. SwiftData daha önce UIKit projelerinde kullanılmış olsa da,
SwiftUI bu proje kapsamında ilk kez kullanılan framework'tür.
