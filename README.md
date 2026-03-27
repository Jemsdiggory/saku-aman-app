# 💰 Saku Aman App

> Aplikasi pencatatan pengeluaran pribadi yang simpel, cerdas, dan personal — dibuat karena frustrasi sama aplikasi keuangan yang terlalu ribet.

---

## 🧠 Latar Belakang

Sebelumnya aku nyatat pengeluaran manual di **Notes HP** — simpel, tapi gak ada visualisasi, gak ada insight, dan gak ada yang ngingetin kalau udah mulai boros.

Aplikasi keuangan yang ada di pasaran kebanyakan **terlalu kompleks** dan fiturnya overwhelming buat kebutuhan sehari-hari. Yang aku butuhin cuma satu hal: **tau kemana uangku pergi**, dengan tampilan yang bersih dan mudah dimengerti.

Jadi aku bikin sendiri.

---

## 🎯 Tujuan Aplikasi

- Mencatat pengeluaran harian dengan cepat (under 10 detik)
- Memvisualisasikan pola pengeluaran per kategori
- Mendeteksi kebiasaan boros secara otomatis — termasuk pengeluaran game yang berlebihan 🎮
- Memberikan insight yang actionable, bukan sekadar angka

---

## ✨ Fitur Utama

### 📥 Input Pengeluaran
Tambah transaksi dengan nominal, kategori, dan catatan opsional. Desain form yang clean dan cepat diisi.

### 🏠 Home Screen
Tampilan total pengeluaran hari ini, minggu ini, dan bulan ini. List transaksi terakhir dengan swipe-to-delete.

### 📊 Statistik
- Pie chart pengeluaran per kategori
- Breakdown dengan progress bar visual
- Filter by hari ini / minggu ini / bulan ini

### 🧠 Insight System *(Core Feature)*
Sistem deteksi otomatis yang menganalisis pola pengeluaran dan memberikan peringatan, antara lain:

| Insight | Kondisi |
|---|---|
| ⚠️ Transaksi Sering Banget | Lebih dari 5x transaksi dalam sehari |
| 📈 Pengeluaran Naik | Minggu ini lebih boros >20% dari minggu lalu |
| 📉 Pengeluaran Turun | Minggu ini lebih hemat >20% dari minggu lalu |
| 🏷️ Kategori Terboros | Satu kategori >50% dari total pengeluaran |
| 🎮 Game Addict Detected | Pengeluaran game >30% dari total, atau >3x transaksi game |
| 📅 Hari Paling Boros | Deteksi hari dengan pengeluaran tertinggi |
| ✅ Keuangan Aman | Semua kondisi terkontrol |

### 🔔 Notifikasi
Insight warning dikirim langsung ke notifikasi HP secara otomatis.

### 🌙 Dark / Light Mode
Mendukung auto-detect mode dari sistem device, plus bisa switch manual dari dalam app.

---

## 🧱 Tech Stack

| Teknologi | Kegunaan |
|---|---|
| **Flutter** | Framework utama cross-platform (Android & iOS) |
| **Dart** | Bahasa pemrograman |
| **SQLite** (`sqflite`) | Database lokal offline — semua data tersimpan di device |
| **fl_chart** | Visualisasi data: pie chart & progress bar |
| **flutter_local_notifications** | Push notification insight ke HP |
| **path** | Helper untuk lokasi penyimpanan database |

---

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / Xcode (untuk emulator)

### Steps

```bash
# Clone repo
git clone https://github.com/Jemsdiggory/saku-aman-app.git
cd saku-aman-app

# Install dependencies
flutter pub get

# Jalankan app
flutter run
```

### Build APK (Android)

```bash
flutter build apk --debug
```

File APK tersedia di: `build/app/outputs/flutter-apk/app-debug.apk`

### Build iOS (Mac only)

```bash
cd ios
pod install
cd ..
flutter build ios
```

---


## 👤 Developer

**Jems** — dibuat sebagai project portfolio sekaligus solusi masalah pribadi.

> *"Daripada nunggu aplikasi yang sempurna, mending bikin sendiri yang pas buat kebutuhan sendiri."*

---

## 📄 License

This project is for personal and portfolio use.
