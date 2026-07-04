# Kalori Takip Uygulaması

Günlük kalori alımını takip etmek, kişiye özel kalori hedefini hesaplamak ve
Apple Health üzerinden yakılan kaloriyi hedefe yansıtmak için geliştirilmiş
basit bir iOS uygulaması.

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
# calorie-tracking-app
