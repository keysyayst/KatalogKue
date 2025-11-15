# Fitur Tambah Produk dari TheMealDB API + Nutrition

## 📋 Overview

Fitur baru yang memungkinkan Admin untuk menambah produk dengan 2 cara:

1. **Manual** - Input data produk secara manual (seperti sebelumnya)
2. **Dari TheMealDB API** - Browse dessert dari TheMealDB, otomatis dapat komposisi + nutrisi dari USDA API

---

## 🚀 Flow Kerja

### A. Tambah Manual (Seperti Biasa)

```
Klik "Tambah Produk"
→ Dialog Pilihan
→ Pilih "Tambah Manual"
→ Form input manual
→ Upload gambar (optional)
→ Save ke database
```

### B. Tambah dari TheMealDB (BARU! ✨)

```
Klik "Tambah Produk"
→ Dialog Pilihan
→ Pilih "Dari TheMealDB"
→ Loading... (fetch desserts)
→ Browse list dessert
→ Klik dessert yang dipilih
→ Loading... (fetch detail + nutrition)
→ Form konfirmasi dengan data pre-filled:
   * Title: Nama dessert
   * Price: Default 100.000/kg (bisa diedit)
   * Location: Area/negara asal dessert
   * Description: Instructions dari TheMealDB
   * Composition: Ingredients otomatis (format: "measure ingredient")
   * Image: URL gambar dari TheMealDB
   * Nutrition: OTOMATIS dari USDA API (jika tersedia)
→ Edit jika perlu
→ Save ke database
```

---

## 🔧 Komponen Teknis

### 1. **Meal Model** (`lib/app/data/models/meal_model.dart`)

- Parsing data dari TheMealDB API
- Extract ingredients (strIngredient1-20) + measurements (strMeasure1-20)
- Helper `compositionText`: Format ingredients → composition string untuk database

### 2. **MealDB API Provider** (`lib/app/data/providers/mealdb_api_provider.dart`)

**Methods:**

- `getDesserts()` - Ambil semua dessert (category filter)
- `getMealDetail(id)` - Ambil detail meal untuk ingredients & instructions
- `searchMeals(query)` - Search meal by name

**Endpoint TheMealDB:**

- Base URL: `https://www.themealdb.com/api/json/v1/1`
- Get Desserts: `/filter.php?c=Dessert`
- Get Detail: `/lookup.php?i={mealId}`
- Search: `/search.php?s={query}`

### 3. **Nutrition API Provider** (`lib/app/data/providers/nutrition_api_provider.dart`)

**Sudah Ada - Diintegrasikan:**

- Call USDA FoodData Central API
- Return `NutritionData` dengan: calories, protein, fat, carbs, sugar, fiber
- Convert ke format JSON untuk disimpan ke database

### 4. **Admin Controller** (Updated)

**Method Baru:**

- `showAddProductOptionsDialog()` - Dialog pilihan manual/API
- `showMealDBBrowser()` - Browse desserts dari API
- `selectMealFromDB(meal)` - Proses meal yang dipilih + fetch nutrition
- `showMealConfirmationForm(meal, nutrition)` - Form konfirmasi sebelum save
- `saveMealProduct(nutrition)` - Save produk dengan nutrition data

**Flow Nutrition:**

```dart
selectMealFromDB(meal)
→ getMealDetail(meal.idMeal)  // Get ingredients
→ searchNutrition(meal.strMeal)  // Get nutrition dari USDA
→ Convert nutrition → Map<String, dynamic>
→ showMealConfirmationForm dengan nutrition
→ saveMealProduct → Save ke database dengan field nutrition
```

### 5. **Admin Products Page** (Updated)

- FAB berubah dari icon `+` → `FloatingActionButton.extended` dengan label "Tambah Produk"
- Klik FAB → `showAddProductOptionsDialog()`

### 6. **Database Schema** (Updated)

```sql
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS nutrition jsonb;
```

**Format Nutrition (JSONB):**

```json
{
  "calories": "450.0",
  "protein": "5.5",
  "fat": "22.0",
  "carbs": "58.0",
  "sugar": "28.0",
  "fiber": "1.5"
}
```

---

## 📊 Data Flow

### Tambah Produk dari TheMealDB + Nutrition:

```
TheMealDB API                    USDA API                  Supabase Database
     ↓                               ↓                            ↓
1. GET desserts          2. GET nutrition data         4. INSERT product
   (list)                   (by meal name)                - title
                                                          - price (editable)
                                                          - location
                                                          - description
3. GET meal detail                                       - composition
   (ingredients)                                         - product_url (image)
                                                          - nutrition (JSONB) ✨
```

---

## 🎨 UI/UX

### Dialog 1: Pilihan Tambah Produk

```
┌─────────────────────────┐
│   Tambah Produk         │
├─────────────────────────┤
│ ✏️  Tambah Manual       │
│    Isi data produk      │
│    secara manual        │
├─────────────────────────┤
│ 🍰 Dari TheMealDB       │
│    Pilih dari database  │
│    dessert              │
└─────────────────────────┘
```

### Dialog 2: Browse Desserts

```
┌─────────────────────────────────┐
│ 🍰 Pilih Dessert dari TheMealDB │
├─────────────────────────────────┤
│ [Image] Chocolate Cake      →   │
│ [Image] Apple Pie           →   │
│ [Image] Cheesecake          →   │
│ [Image] Tiramisu            →   │
│ ...                             │
└─────────────────────────────────┘
```

### Dialog 3: Konfirmasi Produk

```
┌────────────────────────────────┐
│ ✅ Konfirmasi Produk           │
├────────────────────────────────┤
│ [Image Preview]                │
│                                │
│ ✅ Data nutrisi berhasil       │
│    diambil dari USDA           │
│                                │
│ Judul: [Chocolate Cake]        │
│ Harga: [100.000/kg]            │
│ Lokasi: [American]             │
│ Deskripsi: [Instructions...]   │
│ Komposisi:                     │
│ [2 cups flour                  │
│  1 cup sugar                   │
│  ...]                          │
├────────────────────────────────┤
│         [Batal] [Simpan Produk]│
└────────────────────────────────┘
```

---

## ⚠️ Error Handling

1. **TheMealDB API Gagal:**

   - Tampilkan snackbar error
   - User bisa retry atau pilih tambah manual

2. **Nutrition API Gagal:**

   - Produk tetap bisa disimpan
   - Nutrition field = null
   - Tampilkan banner warning: "Data nutrisi tidak tersedia"
   - Tidak ada dummy data

3. **Network Error:**
   - Tampilkan pesan error yang jelas
   - Loading dialog otomatis tertutup

---

## ✅ Keuntungan Fitur Ini

1. **Efisiensi Admin:**

   - Tidak perlu input manual semua field
   - Copy data dari database internasional (TheMealDB)
   - Komposisi otomatis terisi

2. **Data Nutrisi Akurat:**

   - Ambil dari USDA FoodData Central (database resmi)
   - Otomatis tersimpan di database
   - Ditampilkan di tab Nutrisi (detail produk)

3. **Flexibilitas:**

   - Bisa edit sebelum save
   - Bisa pilih manual jika produk lokal
   - Image otomatis dari TheMealDB (URL)

4. **User Experience:**
   - Progress indicator yang jelas
   - Konfirmasi sebelum save
   - Feedback sukses/error yang informatif

---

## 🔄 Cara Penggunaan (Admin)

### Skenario 1: Tambah dari TheMealDB

1. Buka halaman **Kelola Produk**
2. Klik tombol **"Tambah Produk"** (FAB kanan bawah)
3. Pilih **"Dari TheMealDB"**
4. Tunggu loading (fetch desserts)
5. Scroll dan cari dessert yang diinginkan
6. Klik dessert → loading (fetch detail + nutrition)
7. **Review data di form konfirmasi:**
   - Title, price, location, description, composition sudah terisi
   - Cek apakah ada banner hijau "Data nutrisi berhasil diambil"
8. **Edit jika perlu** (terutama harga dan lokasi)
9. Klik **"Simpan Produk"**
10. Done! Produk tersimpan dengan komposisi + nutrisi lengkap ✨

### Skenario 2: Tambah Manual (Tetap Bisa)

1. Klik tombol **"Tambah Produk"**
2. Pilih **"Tambah Manual"**
3. Isi form seperti biasa
4. Upload gambar dari galeri/kamera
5. Save

---

## 🗂️ Files Modified/Created

### Created:

- `lib/app/data/providers/mealdb_api_provider.dart`
- `database/add_nutrition_column.sql`

### Modified:

- `lib/app/data/models/meal_model.dart` - Extended with ingredients & composition
- `lib/app/data/models/product.dart` - Added nutrition field
- `lib/app/modules/admin/controllers/admin_controller.dart` - Added MealDB methods
- `lib/app/modules/admin/views/admin_products_page.dart` - Updated FAB
- `lib/app/modules/produk/views/detail_produk_page.dart` - Show nutrition from DB
- `database/products_table.sql` - Added nutrition column

---

## 📝 Catatan Penting

1. **API Key USDA:**

   - Saat ini menggunakan API key yang ada di `nutrition_api_provider.dart`
   - Bisa ganti dengan API key sendiri (free dari USDA)

2. **TheMealDB:**

   - Free API, tidak perlu API key
   - Hanya dessert category yang diambil
   - Image URL langsung dari API (tidak perlu upload)

3. **Nutrition Data:**

   - Tidak selalu 100% match (tergantung nama produk)
   - Jika gagal fetch, produk tetap tersimpan tanpa nutrition
   - Bisa diupdate manual via database jika perlu

4. **Image from TheMealDB:**
   - Langsung pakai URL dari API (tidak upload ke Supabase Storage)
   - Gambar bisa rusak jika URL dari TheMealDB berubah
   - Untuk produk penting, disarankan download & re-upload ke Supabase

---

## 🎯 Testing Checklist

- [ ] Klik "Tambah Produk" → muncul dialog pilihan
- [ ] Pilih "Dari TheMealDB" → muncul loading → muncul list dessert
- [ ] Klik dessert → muncul loading → muncul form konfirmasi
- [ ] Cek data pre-filled (title, composition, image)
- [ ] Cek banner nutrition (hijau jika berhasil, orange jika gagal)
- [ ] Edit harga & lokasi → Save
- [ ] Produk muncul di list dengan gambar dari TheMealDB
- [ ] Buka detail produk → cek tab Nutrisi (ada data atau pesan "tidak tersedia")
- [ ] Cek tab Komposisi → ingredients dari TheMealDB
- [ ] Test tambah manual masih berfungsi normal

---

Fitur sudah lengkap dan siap digunakan! 🎉
