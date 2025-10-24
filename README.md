# 🍪 Katalog Kue Lebaran Flutter App

Aplikasi **Katalog Kue Lebaran** adalah proyek latihan pemrograman mobile berbasis **Flutter**, yang dikembangkan sebagai bagian dari pembelajaran **Modul 1–2 Pemrograman Mobile** (StatelessWidget, StatefulWidget, Navigasi, dan Responsivitas UI & Animasi).

Aplikasi ini menampilkan katalog kue kering dengan desain responsif, halaman detail produk, daftar favorit, serta halaman kontak. Semua gambar diambil dari **assets lokal**, dan warna tema utama menggunakan **#FE8C00** (oranye lembut bertema hangat Lebaran).

---

## 🌟 Fitur Utama

### 🏠 Home Page
- Menampilkan **hero section** dengan background dan teks *“Rayakan Lebaran dengan cita rasa istimewa”*.
- Section **Rekomendasi Produk** berisi 4 kue pilihan.
- Tombol **See All** mengarahkan ke halaman *Produk Kami* dengan daftar 9 kue kering.

### 🧁 Produk Kami Page
- Menampilkan semua produk dalam grid responsif.
- Gambar diambil dari folder `assets/images/`.
- Tiap produk bisa dibuka untuk melihat **detail**.

### ❤️ Favorit Page
- Menampilkan produk yang diberi tanda hati.
- Data tersinkron otomatis ketika pengguna menandai/unmark favorit di halaman lain.

### 📞 Contact Page
- Menampilkan informasi kontak pembuat kue beserta foto profil dan ikon interaktif.

### 📱 Responsivitas
- Menggunakan **MediaQuery** dan **GridView** agar layout menyesuaikan di berbagai ukuran layar.

### ✨ Animasi Implisit
- Efek halus ketika toggle favorit menggunakan `AnimatedContainer`.
- Transisi gambar antar halaman menggunakan `Hero` animation.

---

## 🎨 Tampilan Warna dan Desain

| Elemen               | Warna / Nilai        | Deskripsi                           |
|----------------------|----------------------|-------------------------------------|
| **Primary Color**    | `#FE8C00`            | Warna oranye khas Lebaran           |
| **Background Hero**  | `assets/images/bg.png` | Gambar latar atas halaman Home     |
| **Font Style**       | `fontWeight: bold`   | Nuansa modern & bersih              |
| **Icon Aktif**       | Warna oranye         | Konsisten dengan tema utama         |

---
