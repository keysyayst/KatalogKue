# Perbandingan Visual Storage Implementation

## 1. Arsitektur Data Flow

### Hive (Local Storage)

```
┌──────────────┐
│     UI       │
│  (Widget)    │
└──────┬───────┘
       │ Get.find<FavoriteHiveService>()
       ↓
┌──────────────────────────┐
│  FavoriteHiveService     │
│  ┌────────────────────┐  │
│  │  Hive Box          │  │
│  │  [favorites]       │  │
│  │  - id1             │  │
│  │  - id2             │  │
│  │  - id3             │  │
│  └────────────────────┘  │
└──────────────────────────┘
       ↓
┌──────────────────────────┐
│  Local Storage           │
│  /data/user/0/com.../    │
│  favorites.hive          │
└──────────────────────────┘

⏱️ Response Time: < 10ms
📡 Network: Not required
💾 Storage: Device only
🔄 Sync: No
```

### Supabase (Cloud Storage)

```
┌──────────────┐
│     UI       │
│  (Widget)    │
└──────┬───────┘
       │ Get.find<ProductService>()
       ↓
┌──────────────────────────┐
│  ProductService          │
│  ┌────────────────────┐  │
│  │  ProductProvider   │  │
│  │  (API calls)       │  │
│  └────────────────────┘  │
└──────┬───────────────────┘
       │ HTTP Request
       ↓
┌──────────────────────────┐
│  Supabase Client         │
│  (REST API)              │
└──────┬───────────────────┘
       │ Internet
       ↓
┌──────────────────────────┐
│  Supabase Cloud          │
│  ┌────────────────────┐  │
│  │  PostgreSQL        │  │
│  │  products table    │  │
│  │  Row Level Security│  │
│  └────────────────────┘  │
│  ┌────────────────────┐  │
│  │  Storage Buckets   │  │
│  │  product-images/   │  │
│  └────────────────────┘  │
└──────────────────────────┘

⏱️ Response Time: 100-500ms
📡 Network: Required
💾 Storage: Cloud (PostgreSQL)
🔄 Sync: Real-time
```

### Hybrid Approach (Recommended)

```
┌──────────────────────────────────────────┐
│              UI LAYER                    │
└──────────┬───────────────────────────────┘
           │
    ┌──────┴──────┐
    ↓             ↓
┌─────────┐   ┌──────────┐
│ LOCAL   │   │  CLOUD   │
│ (Hive)  │   │(Supabase)│
└────┬────┘   └────┬─────┘
     │             │
     ↓             ↓
┌─────────┐   ┌──────────┐
│Cache    │   │ Source   │
│Fast     │   │ of Truth │
│Offline  │   │ Sync     │
└─────────┘   └──────────┘

STRATEGY:
1. Load from cache (instant)
2. Fetch from cloud (background)
3. Update cache
4. Update UI
```

## 2. Perbandingan Kode

### A. Menyimpan Data Favorit

#### Hive Implementation (Simple)

```dart
// Total: ~15 baris kode
Future<void> toggleFavorite(String productId) async {
  final favorites = _box.get('favorites') ?? [];

  if (favorites.contains(productId)) {
    favorites.remove(productId);
  } else {
    favorites.add(productId);
  }

  await _box.put('favorites', favorites);
}
```

#### Supabase Implementation (Complex)

```dart
// Total: ~40 baris kode
Future<void> toggleFavorite(String productId) async {
  try {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) throw Exception('Not logged in');

    // Check if exists
    final existing = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Delete
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } else {
      // Insert
      await _supabase
          .from('favorites')
          .insert({
            'user_id': userId,
            'product_id': productId,
          });
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

**Perbandingan:**

- Hive: 15 baris, tidak perlu error handling kompleks
- Supabase: 40 baris, perlu auth check, network error handling

### B. Membaca Data Produk

#### Hive (Cache)

```dart
// Total: ~10 baris
Future<List<Product>> getCachedProducts() async {
  final data = _box.get('products');
  if (data == null) return [];

  return data.map((json) => Product.fromJson(json)).toList();
}
```

#### Supabase (API)

```dart
// Total: ~25 baris
Future<List<Product>> getAllProducts() async {
  try {
    final response = await _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return response
        .map((json) => Product.fromJson(json))
        .toList();
  } on PostgrestException catch (e) {
    print('Database error: ${e.message}');
    throw Exception('Failed to load products');
  } catch (e) {
    print('Error: $e');
    throw Exception('Network error');
  }
}
```

**Perbandingan:**

- Hive: 10 baris, synchronous bisa, tidak ada network error
- Supabase: 25 baris, async required, multiple error types

## 3. Setup Complexity

### Hive Setup

```dart
// main.dart (~10 baris)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters jika perlu
  // Hive.registerAdapter(ProductAdapter());

  // Initialize services
  Get.put(await FavoriteHiveService().init());

  runApp(MyApp());
}
```

### Supabase Setup

```dart
// .env file
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1...

// main.dart (~15 baris)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize services
  Get.put(AuthService());
  Get.put(ProductService());

  runApp(MyApp());
}

// Database setup (SQL - ~80 baris)
CREATE TABLE products (...);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY ...;
-- etc
```

## 4. Error Handling Comparison

### Hive Error Handling (Minimal)

```dart
Future<void> saveFavorite(String id) async {
  try {
    await _box.put('fav_$id', true);
  } catch (e) {
    // Jarang terjadi error
    print('Error saving: $e');
  }
}
```

### Supabase Error Handling (Extensive)

```dart
Future<void> saveFavorite(String id) async {
  try {
    await _supabase.from('favorites').insert({...});
  } on PostgrestException catch (e) {
    // Database error
    if (e.code == '23505') {
      throw Exception('Already favorited');
    }
    throw Exception('Database error: ${e.message}');
  } on SocketException {
    // Network error
    throw Exception('No internet connection');
  } on TimeoutException {
    // Timeout
    throw Exception('Request timeout');
  } catch (e) {
    // Unknown error
    throw Exception('Unknown error: $e');
  }
}
```

## 5. Performance Metrics (Real App)

### Read Performance

```
┌─────────────────────────────────────────────────┐
│ Operation: Load 100 Products                    │
├─────────────────────────────────────────────────┤
│ Hive (Cache):     5-10ms    ████                │
│ Supabase (API):   200-500ms ████████████████████│
└─────────────────────────────────────────────────┘

Hive is 20-50x FASTER for cached data
```

### Write Performance

```
┌─────────────────────────────────────────────────┐
│ Operation: Toggle Favorite                      │
├─────────────────────────────────────────────────┤
│ Hive:       1-5ms      ██                       │
│ Supabase:   100-300ms  ████████████             │
└─────────────────────────────────────────────────┘

Hive is 20-100x FASTER for writes
```

### Storage Size

```
┌─────────────────────────────────────────────────┐
│ Storage: 100 Favorite IDs                       │
├─────────────────────────────────────────────────┤
│ Hive:       ~1-2 KB                             │
│ Supabase:   ~5-10 KB (with metadata)            │
└─────────────────────────────────────────────────┘

Hive is MORE EFFICIENT for simple data
```

## 6. Development Time Estimation

### Feature: Add Favorites

#### Hive Implementation

```
Planning:          30 min
Coding:            1 hour
Testing:           30 min
Debugging:         15 min
─────────────────────────
Total:             ~2.25 hours
```

#### Supabase Implementation

```
Planning:          45 min
Database Schema:   1 hour
RLS Policies:      45 min
Coding:            2 hours
Testing:           1 hour
Debugging:         1 hour
─────────────────────────
Total:             ~6.5 hours
```

**Supabase takes 3x longer to implement**
But provides sync, backup, and multi-device support

## 7. Maintenance Complexity

### Hive

```
✅ Pros:
- No backend to maintain
- No API versioning
- No database migrations
- Offline-first by default

❌ Cons:
- Need to handle data migration on app updates
- No centralized backup
- Each device has own copy
```

### Supabase

```
✅ Pros:
- Centralized data management
- Automatic backups
- Easy to update for all users
- Real-time updates

❌ Cons:
- Database migrations needed
- API versioning required
- Need to handle downtime
- Dependency on third-party
```

## 8. Cost Analysis

### Hive (Free)

```
Setup:      FREE
Storage:    FREE (device storage)
Bandwidth:  FREE
Scaling:    FREE (per device)
Maintenance: FREE

Total: $0/month
```

### Supabase (Tiered)

```
Free Tier:
- 500 MB database
- 1 GB file storage
- 2 GB bandwidth
- 50,000 monthly active users

Paid (Pro):
- $25/month base
- Additional storage: $0.125/GB
- Additional bandwidth: $0.09/GB

Estimated for 1000 users:
- Database: 2 GB    → $0.25
- Storage: 10 GB    → $1.25
- Bandwidth: 50 GB  → $4.50
─────────────────────────────
Total: ~$31/month
```

## 9. Real-World Scenarios

### Scenario 1: User Opens App

```
HIVE APPROACH:
1. App starts        → 0ms
2. Load favorites    → 5ms
3. Display UI        → immediate
───────────────────────────
Total: ~5ms ✅ FAST

SUPABASE APPROACH:
1. App starts        → 0ms
2. Auth check        → 100ms
3. Load profile      → 200ms
4. Load favorites    → 200ms
5. Display UI        → after all loads
───────────────────────────
Total: ~500ms ⚠️ SLOWER
```

### Scenario 2: User Toggles Favorite

```
HIVE APPROACH:
1. User taps         → 0ms
2. Update local      → 2ms
3. UI updates        → immediate
───────────────────────────
Total: ~2ms ✅ INSTANT

SUPABASE APPROACH (Optimistic):
1. User taps         → 0ms
2. Update UI         → immediate (optimistic)
3. API call          → 200ms (background)
4. Handle error      → if failed, revert UI
───────────────────────────
Total: ~200ms ✅ FEELS INSTANT
```

### Scenario 3: User is Offline

```
HIVE APPROACH:
1. User opens app    → 0ms
2. Load from cache   → 5ms
3. Everything works  → ✅
───────────────────────────
Result: FULL FUNCTIONALITY

SUPABASE APPROACH:
1. User opens app    → 0ms
2. Try API call      → timeout after 10s
3. Show error        → ❌
4. Fallback to cache → if implemented
───────────────────────────
Result: LIMITED OR NO FUNCTIONALITY
```

## 10. Recommendation Matrix

```
┌───────────────────────────────────────────────────────┐
│                  RECOMMENDATION                       │
├───────────────┬───────────────────────────────────────┤
│ Data Type     │ Recommended Storage                   │
├───────────────┼───────────────────────────────────────┤
│ User Prefs    │ LOCAL (Hive/SharedPrefs)              │
│ Theme/Lang    │ LOCAL (Hive/SharedPrefs)              │
│ Cache         │ LOCAL (Hive)                          │
│ Search Hist   │ LOCAL (Hive)                          │
│ Favorites     │ HYBRID (Local + Optional Sync)        │
│ User Profile  │ CLOUD (Supabase)                      │
│ Products      │ CLOUD + Cache (Supabase + Hive)       │
│ Auth          │ CLOUD (Supabase)                      │
│ Images        │ CLOUD Storage (Supabase Storage)      │
│ Chat          │ CLOUD Real-time (Supabase Realtime)   │
└───────────────┴───────────────────────────────────────┘
```

## Summary

**Use Hive when:**

- ✅ Personal data
- ✅ Need offline support
- ✅ Performance critical
- ✅ Simple implementation preferred

**Use Supabase when:**

- ✅ Shared data
- ✅ Multi-device sync
- ✅ Collaboration needed
- ✅ Centralized management

**Use Both (Hybrid) when:**

- ✅ Building production app
- ✅ Need offline + sync
- ✅ Best user experience
- ✅ Can handle complexity
