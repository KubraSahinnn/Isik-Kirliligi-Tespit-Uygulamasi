# 🌌 Işık Kirliliği Tespit Uygulaması

Gece gökyüzü fotoğraflarından **ışık kirliliği seviyesini** tahmin eden, makine öğrenmesi destekli bir mobil uygulama. Kullanıcı bir gece gökyüzü fotoğrafı yükler; backend'deki model NSB (Night Sky Brightness) skorunu hesaplar ve uygulama sonucu görsel olarak sunar.

## ✨ Özellikler

- 📸 Galeriden veya kameradan fotoğraf seçme
- 🤖 Fotoğrafı backend API'sine göndererek NSB skoru tahmini alma
- 🎯 Sonucu **İyi / Orta / Kötü** kategorilerine göre renkli ve ikonlu şekilde gösterme
- 📊 Teknik detaylar: NSB skoru, parlaklık (luminance), ham tahmin değeri
- 💡 Kategoriye özel öneriler (astrofotoğraf, teleskop gözlemi, karanlık alan arayışı vb.)
- 📏 Işık kirliliği kategorileri için referans skala

## 🖼️ Nasıl Çalışır?

1. Gece gökyüzü fotoğrafınızı yükleyin
2. AI sistemi fotoğrafı analiz eder
3. Işık kirliliği seviyenizi ve detaylı sonucu görün

## 🛠️ Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| Mobil | Flutter (Dart) |
| Görsel Seçim | `image_picker` |
| API İletişimi | `http` (multipart/form-data) |
| Grafik/Görselleştirme | `fl_chart` |
| Yükleniyor Animasyonu | `flutter_spinkit` |
| Backend | REST API (`POST /analyze`, `image` alanı ile) |

## 📁 Proje Yapısı
mobile/
  lib/
    main.dart              -> Uygulama giris noktasi ve tema
    screens/
      home_screen.dart     -> Karsilama ekrani
      upload_screen.dart   -> Fotograf yukleme ekrani
      result_screen.dart   -> Analiz sonuc ekrani
      api_service.dart     -> Backend API iletisimi
  pubspec.yaml

## 🚀 Kurulum

```bash
git clone https://github.com/KubraSahinnn/Isik-Kirliligi-Tespit-Uygulamasi.git
cd Isik-Kirliligi-Tespit-Uygulamasi/mobile
flutter pub get
flutter run
```

> **Not:** Uygulama şu an bir backend API'sine (ngrok üzerinden) bağlanacak şekilde yapılandırılmıştır. Kendi backend'inizi kullanmak isterseniz `lib/screens/api_service.dart` dosyasındaki `baseUrl` değerini güncelleyin.

## 📡 API Sözleşmesi

- **Endpoint:** `POST /analyze`
- **Body:** `multipart/form-data`, `image` alanı ile fotoğraf
- **Yanıt:**
```json
{
  "success": true,
  "prediction": 18.7,
  "message": "🌑 KARANLIK / TEMİZ GÖKYÜZÜ",
  "details": {
    "luminance": 0.12,
    "raw_prediction": 18.7
  }
}
```

## 👥 Geliştiriciler

Hülya & Kübra

## 📄 Lisans

Bu proje eğitim/proje yönetimi dersi kapsamında geliştirilmiştir.
