```markdown
# 🍪 Katalog Kue Lebaran

Aplikasi **Katalog Kue Lebaran** adalah aplikasi mobile berbasis **Flutter** untuk bisnis katering kue dengan fitur lengkap mulai dari katalog produk, autentikasi pengguna, manajemen favorit, hingga pengecekan jarak pengiriman menggunakan geolokasi.

Aplikasi ini dikembangkan menggunakan **GetX** sebagai state management, **Supabase** untuk backend & cloud storage, dan **Hive** untuk local storage yang efisien.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Role Management
- Login dan registrasi pengguna menggunakan **Supabase Auth**
- Sistem role-based access (Admin & User)
- Middleware untuk proteksi route berdasarkan role
- Session management dengan shared preferences

### 🏠 Home Page
- Hero section dengan background dan branding bisnis kue
- Section **Rekomendasi Produk** dengan produk unggulan
- Grid responsif menggunakan **MediaQuery** dan **GridView**
- Navigasi cepat ke halaman katalog lengkap

### 🍰 Katalog Produk
- Daftar lengkap produk kue kering (9+ variasi)
- Detail produk dengan gambar, deskripsi, dan harga
- Informasi nutrisi terintegrasi dengan **TheMealDB API**
- Search dan filter produk
- Upload gambar produk menggunakan **image_picker**

### ❤️ Sistem Favorit
- Toggle favorit dengan animasi smooth menggunakan `AnimatedContainer`
- Sinkronisasi real-time data favorit
- Penyimpanan lokal menggunakan **Hive** untuk performa optimal
- Halaman khusus menampilkan semua produk favorit

### 👤 Profile & Settings
- Tampilan profil pengguna
- Edit informasi personal
- Manajemen akun dan preferensi

### 🚚 Delivery Checker
- Pengecekan jarak pengiriman berbasis lokasi real-time
- Integrasi **Geolocator** dan **Location** services
- Peta interaktif menggunakan **flutter_map** dan **latlong2**
- Perhitungan estimasi ongkir berdasarkan jarak
- Request permission handling untuk akses lokasi

### 👑 Admin Dashboard
- Panel khusus untuk admin
- Manajemen produk (CRUD operations)
- Upload dan manage gambar produk ke Supabase Storage
- Monitor orders dan customer data

### 🧪 Experimental Features
- Testing ground untuk fitur-fitur baru
- Prototype UI/UX improvements

---

## 🛠️ Teknologi & Dependencies

### Framework & State Management
- **Flutter SDK** ^3.9.2
- **GetX** ^4.6.5 - State management, routing, dan dependency injection

### Backend & Database
- **Supabase Flutter** ^2.3.4 - Backend as a Service
- **Hive** ^2.2.3 - Local NoSQL database
- **Shared Preferences** ^2.2.2 - Key-value storage

### Networking & API
- **Dio** ^5.2.1 - HTTP client
- **HTTP** ^1.1.0 - HTTP requests

### Location & Maps
- **Geolocator** ^11.1.0 - GPS location
- **Location** ^6.0.0 - Location services
- **Flutter Map** ^7.0.0 - Interactive maps
- **Latlong2** ^0.9.0 - Latitude/longitude utilities
- **Permission Handler** ^11.3.1 - Runtime permissions

### Media & Assets
- **Image Picker** ^1.0.7 - Upload gambar produk
- **URL Launcher** ^6.1.10 - Launch external URLs

### Utils
- **Flutter Dotenv** ^6.0.0 - Environment variables management

---

---

## 🎨 Desain & Tema

| Elemen | Warna/Nilai | Deskripsi |
|--------|-------------|-----------|
| **Primary Color** | `#FE8C00` | Oranye khas kue nastar |
| **Background Hero** | `assets/images/bg.png` | Hero image halaman utama |
| **Logo** | `assets/images/logo.png` | Branding aplikasi |
| **Font Style** | `fontWeight: bold` | Modern & clean |

### Produk Tersedia
- Brownies Cup
- Kastengel
- Lidah Kucing
- Nastar
- Palm Cheese
- Putri Salju
- Sagu Keju
- Thumbprint

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Installation Steps

1. **Clone repository**
```
git clone https://github.com/keysyayst/KatalogKue.git
cd KatalogKue
```

2. **Install dependencies**
```
flutter pub get
```

3. **Setup environment variables**
- Copy `.env.example` to `.env`
- Isi dengan Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

4. **Generate Hive adapters**
```
flutter packages pub run build_runner build
```

5. **Run application**
```
flutter run
```

---

## 📚 Dokumentasi Tambahan

- [Setup Storage](SETUP_STORAGE.md) - Konfigurasi Supabase Storage
- [Analisis Kompleksitas](ANALISIS_KOMPLEKSITAS_STORAGE.md) - Big O Analysis
- [Fitur Nutrition](FITUR_MEALDB_NUTRITION.md) - Integrasi TheMealDB API
- [Fix Nutrition](FIX_NUTRITION_MIRIP.md) - Troubleshooting nutrition data

---

## 🎯 Use Case

Aplikasi ini dikembangkan untuk membantu bisnis katering kue dalam:
- Menampilkan katalog produk secara digital
- Mempermudah customer melihat detail dan harga produk
- Sistem favorit untuk customer track produk favorit
- Cek jarak pengiriman otomatis untuk estimasi ongkir
- Manajemen produk melalui admin panel

---

## 🔒 Security Features

- Environment variables untuk sensitive data
- Role-based access control
- Route middleware protection
- Secure authentication dengan Supabase

---

---

## 📄 License

This project is for educational and business purposes.


## 🙏 Acknowledgments

- Flutter & Dart team
- GetX framework
- Supabase
- TheMealDB API
- OpenStreetMap (flutter_map)
