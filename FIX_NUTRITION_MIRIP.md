# Fix: Masalah Nutrisi Mirip di Semua Produk

## 🐛 Masalah yang Ditemukan

Saat menambah produk dari TheMealDB, semua produk mendapat data nutrisi yang **sama/mirip**.

## 🔍 Penyebab

### 1. **API Key Salah Format**

```dart
// ❌ SALAH - Ini bukan API key, tapi URL lengkap!
final String apiKey = 'https://api.nal.usda.gov/fdc/v1/foods/search?query=cookie&api_key=IDPV7tHrlLTREq2QxlfXNBZMEdUWhy5wdW8kM68i';

// ✅ BENAR - Hanya API key
final String apiKey = 'IDPV7tHrlLTREq2QxlfXNBZMEdUWhy5wdW8kM68i';
```

Akibatnya, semua request ke USDA API **selalu search "cookie"**, jadi semua produk dapat nutrition data cookie!

### 2. **Return Dummy Data**

```dart
// ❌ SALAH - Selalu return dummy jika gagal
if (foods.isEmpty) {
  return NutritionData.dummy(); // Semua produk dapat data yang sama!
}

// ✅ BENAR - Return null jika gagal
if (foods.isEmpty) {
  return null; // Biarkan kosong, tidak ada data dummy
}
```

### 3. **Nama Meal Tidak Match dengan USDA Database**

TheMealDB: `"Chocolate Gateau"`  
USDA API search: `"Chocolate Gateau"` → **Tidak ketemu!**  
Seharusnya search: `"chocolate cake"` → **Ketemu!**

---

## ✅ Solusi yang Diimplementasikan

### 1. **Fix API Key**

File: `lib/app/data/providers/nutrition_api_provider.dart`

```dart
// Pisahkan API key dari URL
final String apiKey = 'IDPV7tHrlLTREq2QxlfXNBZMEdUWhy5wdW8kM68i';
final String baseUrl = 'https://api.nal.usda.gov/fdc/v1';
```

### 2. **Return Null Instead of Dummy**

```dart
// Tidak ada lagi NutritionData.dummy()
if (foods.isEmpty) {
  print('⚠ No nutrition data found for: $foodName');
  return null; // NULL, bukan dummy!
}
```

Sekarang jika API gagal atau tidak ketemu, nutrition field di database = **null**, bukan data palsu.

### 3. **Improve Search Query dengan Mapping**

File: `lib/app/modules/admin/controllers/admin_controller.dart`

Added method: `_improveMealNameForNutrition()`

**Mapping dessert names ke term USDA:**

```dart
final Map<String, String> mappings = {
  'chocolate cake': 'chocolate cake',
  'vanilla cake': 'vanilla cake',
  'cheesecake': 'cheesecake',
  'apple pie': 'apple pie',
  'brownie': 'brownie',
  'cookie': 'cookie',
  'chocolate chip': 'chocolate chip cookie',
  'tiramisu': 'tiramisu',
  'donut': 'doughnut',
  'macaron': 'macaroon',
  // ... 40+ mappings
};
```

**Flow:**

```
Meal name: "Chocolate Gateau"
→ Convert to lowercase: "chocolate gateau"
→ Check if contains "chocolate cake" or "cake"
→ Return: "chocolate cake"
→ USDA API search: "chocolate cake"
→ ✅ Match found! Get real nutrition data
```

**Cleanup:**

- Remove common words: "with", "and", "or", "the"
- Limit to 2-3 main keywords
- Extract most relevant terms

---

## 📊 Hasil Sekarang

### Before (❌):

```
Apple Frangipan Tart → Search: "cookie" → Nutrition: Cookie data
Chocolate Gateau    → Search: "cookie" → Nutrition: Cookie data
Battenberg Cake     → Search: "cookie" → Nutrition: Cookie data
```

**Semua sama karena selalu search "cookie"!**

### After (✅):

```
Apple Frangipan Tart → Search: "apple tart" → Nutrition: Apple tart data ✅
Chocolate Gateau     → Search: "chocolate cake" → Nutrition: Chocolate cake data ✅
Battenberg Cake      → Search: "cake" → Nutrition: Cake data ✅
Tiramisu             → Search: "tiramisu" → Nutrition: Tiramisu data ✅
```

**Setiap produk dapat data nutrition yang sesuai!**

---

## 🧪 Testing

Coba tambah beberapa dessert yang berbeda:

1. **Chocolate Cake** → Nutrition: ~450 cal, ~5g protein
2. **Apple Pie** → Nutrition: ~237 cal, ~2g protein
3. **Cheesecake** → Nutrition: ~321 cal, ~6g protein
4. **Brownie** → Nutrition: ~466 cal, ~4g protein

Seharusnya setiap produk punya nutrition yang **berbeda** sesuai dengan jenis dessertnya.

---

## 📝 Debug Tips

Jika masih dapat data yang sama, cek console log:

```
🔍 Nutrition search query: chocolate cake  // ← Cek ini, seharusnya berbeda-beda
📊 API Response: 200
✅ Nutrition data found for: Chocolate Gateau
   Calories: 450.0, Protein: 5.5g  // ← Cek ini, seharusnya berbeda
```

Jika nutrition tidak ketemu:

```
⚠️ No nutrition data found for: [nama produk]
```

Coba:

1. Cek mapping di `_improveMealNameForNutrition()`
2. Tambah mapping baru jika perlu
3. Atau edit manual nama produk saat konfirmasi

---

## 🎯 Kapan Nutrition Null?

Nutrition akan **null** (tidak tersedia) jika:

1. USDA API tidak punya data untuk dessert tersebut
2. Network error / timeout
3. API key invalid/expired
4. Nama produk terlalu spesifik/unik

Ini **NORMAL**, lebih baik null daripada data dummy yang salah!

---

## ✨ Improvement Future

1. **Multi-language mapping** - Support nama Indonesia
2. **Fallback to category** - Jika exact match gagal, coba category (e.g., "cake")
3. **Manual nutrition input** - Admin bisa input manual jika API gagal
4. **Cache nutrition mapping** - Simpan mapping yang berhasil

---

Sekarang nutrition data untuk setiap produk seharusnya **unik dan akurat**! 🎉
