# 🍪 Katalog Kue Lebaran

Katalog Kue Lebaran adalah aplikasi mobile berbasis Flutter untuk bisnis katering kue. Aplikasi ini memudahkan penjualan dan manajemen produk — menampilkan katalog produk, detail nutrisi, manajemen favorit, serta fitur cek jarak pengiriman dan panel admin untuk CRUD produk.

Aplikasi ini dibuat dengan GetX (state management & routing), Supabase (Auth, Database, Storage), dan Hive (penyimpanan lokal).

---

## ✨ Fitur Utama

- Autentikasi pengguna menggunakan Supabase Auth dengan role-based access (Admin & User)
- Katalog produk lengkap (gambar, deskripsi, harga)
- Pencarian dan filter produk
- Halaman detail produk dengan informasi nutrisi (integrasi TheMealDB)
- Sistem favorit (sinkron + penyimpanan lokal dengan Hive)
- Pengecekan jarak pengiriman dan estimasi ongkos kirim (Geolocator / flutter_map)
- Panel Admin untuk manajemen produk dan file (Supabase Storage)
- Upload gambar produk (image_picker)

---

## 🛠 Teknologi (ringkasan)

- Flutter SDK (direkomendasikan sesuai pubspec.yaml)
- GetX — state management, routing, dependency injection
- Supabase Flutter — backend, auth, storage
- Hive — local database
- Shared Preferences — konfigurasi/pengaturan kecil
- Dio / http — networking
- Geolocator, Location, flutter_map, latlong2 — lokasi & peta
- Permission Handler — permission runtime
- Image Picker — upload gambar
- Flutter Dotenv — variabel lingkungan

---

## 🚀 Persiapan & Menjalankan Aplikasi

1. Clone repository
   ```
   git clone https://github.com/keysyayst/KatalogKue.git
   cd KatalogKue
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Konfigurasi environment
   - Salin `.env.example` menjadi `.env` lalu isi:
     ```
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_anon_key
     ```

4. Generate Hive adapters (jika ada model dengan annotations)
   ```
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. Jalankan aplikasi
   ```
   flutter run
   ```

Catatan: Pastikan menambahkan permission di AndroidManifest/Info.plist untuk fitur lokasi dan penggunaan kamera/storage jika diperlukan.

---

## 📁 Struktur & Dokumentasi Tambahan

- docs/ — dokumentasi (jika ada)
- SETUP_STORAGE.md — panduan konfigurasi Supabase Storage
- ANALISIS_KOMPLEKSITAS_STORAGE.md — analisis kompleksitas
- FITUR_MEALDB_NUTRITION.md — integrasi TheMealDB
- FIX_NUTRITION_MIRIP.md — troubleshooting nutrisi

(Periksa file-file di root dan folder docs untuk informasi lebih lengkap.)

---

## 🔒 Keamanan & Praktik Baik

- Jangan commit kredensial; gunakan `.env` dan .gitignore
- Terapkan role-based access di backend dan middleware route di client
- Batasi akses storage melalui kebijakan Supabase

---

## 📝 Lisensi

Proyek ini dibuat untuk tujuan edukasi dan kebutuhan bisnis. Jika ingin mempublikasikan atau mendistribusikan ulang, tentukan lisensi yang sesuai.

---

## 🙏 Acknowledgments

Terima kasih kepada komunitas Flutter, tim GetX, Supabase, TheMealDB, dan OpenStreetMap (flutter_map).
