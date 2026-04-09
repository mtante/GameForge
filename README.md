# ⚡ GameForge — Task Command Center

Oyun geliştirme ekipleri için profesyonel görev yönetim uygulaması.

---

## 📱 Özellikler

- **Mission Control Dashboard** — Projenin tüm durumu tek ekranda
- **6 Departman** — Dev, Art, Design, Audio, QA, Production
- **Görev Filtreleme** — Departmana, statüye ve arama sorgusuna göre
- **Öncelik Sistemi** — LOW / MEDIUM / HIGH / CRITICAL
- **Progress Takibi** — Her görev için %0-100 ilerleme
- **Görev Detay Ekranı** — Durum güncelleme, progress slider, meta bilgiler
- **Yeni Görev Ekleme** — Tam form: başlık, açıklama, departman, öncelik, tarih, tag
- **Overdue / Urgent Uyarıları** — Kırmızı ve sarı uyarılar
- **Animasyonlu Splash Screen** — Profesyonel açılış ekranı
- **Neon Cyberpunk Tasarım** — Orbitron + Rajdhani fontları, glow efektleri

---

## 🚀 Kurulum ve APK Oluşturma

### 1. Flutter kurulu değilse
```
https://flutter.dev/docs/get-started/install
```

### 2. Fontları indir
Google Fonts'tan **Orbitron** ve **Rajdhani** fontlarını indir,
`assets/fonts/` klasörüne koy:

```
assets/fonts/
  Orbitron-Regular.ttf
  Orbitron-Bold.ttf
  Orbitron-ExtraBold.ttf
  Orbitron-Black.ttf
  Rajdhani-Regular.ttf
  Rajdhani-Medium.ttf
  Rajdhani-SemiBold.ttf
  Rajdhani-Bold.ttf
```

> Hızlı yol: `pubspec.yaml`'daki font tanımlamalarını sil ve
> `google_fonts` paketini kullan: `GoogleFonts.orbitron()`

### 3. Bağımlılıkları yükle
```bash
flutter pub get
```

### 4. Debug modda çalıştır
```bash
flutter run
```

### 5. Release APK oluştur
```bash
flutter build apk --release
```
APK çıktısı: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Bölünmüş APK (küçük boyut)
```bash
flutter build apk --split-per-abi
```

---

## 📁 Proje Yapısı

```
lib/
├── main.dart                   # Uygulama giriş noktası
├── theme/
│   └── app_theme.dart          # Renk paleti ve tema
├── models/
│   └── task_model.dart         # Veri modelleri + örnek veri
├── providers/
│   └── task_provider.dart      # State management (Provider)
├── screens/
│   ├── splash_screen.dart      # Animasyonlu açılış ekranı
│   ├── home_screen.dart        # Ana navigasyon
│   ├── dashboard_screen.dart   # Mission Control
│   ├── departments_screen.dart # Departman görünümü
│   ├── tasks_screen.dart       # Tüm görevler + filtre
│   ├── task_detail_screen.dart # Görev detay + düzenleme
│   └── add_task_screen.dart    # Yeni görev oluşturma
└── widgets/
    ├── task_card.dart          # Görev kartı bileşeni
    └── glowing_card.dart       # Neon glow kart bileşeni
```

---

## 🎮 Departmanlar

| Emoji | Departman | Sorumluluk |
|-------|-----------|------------|
| ⚙️ | Development | Engine, gameplay, sistemler |
| 🎨 | Art & Visual | Concept, 3D, VFX, UI art |
| 🎮 | Game Design | Mekanikler, level tasarımı |
| 🎵 | Audio | SFX, müzik, voice, mix |
| 🛡️ | QA & Testing | Bug hunting, performans |
| 📋 | Production | Milestone, roadmap, riskler |

---

## 🔧 İleri Adımlar (Geliştirme Önerileri)

- [ ] Firebase Firestore entegrasyonu (gerçek zamanlı senkronizasyon)
- [ ] Bildirimler (due date yaklaşınca uyarı)
- [ ] Kanban board görünümü (sürükle-bırak)
- [ ] Ekip üyeleri yönetimi
- [ ] Dosya ve screenshot ekleme
- [ ] Sprint/Milestone takibi
- [ ] Grafikler ve istatistik ekranı

---

Made with ⚡ by GameForge
