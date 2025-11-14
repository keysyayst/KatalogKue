import 'package:hive_flutter/hive_flutter.dart';
import '../models/favorite_model.dart';

class FavoriteHiveService {
  static const String _boxName = 'favorites';
  Box<FavoriteModel>? _box;

  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapter jika belum terdaftar
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FavoriteModelAdapter());
    }
    
    _box = await Hive.openBox<FavoriteModel>(_boxName);
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId) async {
    if (_box == null) return;

    if (_box!.containsKey(productId)) {
      // Hapus dari favorit
      await _box!.delete(productId);
    } else {
      // Tambah ke favorit
      await _box!.put(
        productId,
        FavoriteModel(
          productId: productId,
          favoritedAt: DateTime.now(),
        ),
      );
    }
  }

  // Cek apakah produk adalah favorit
  bool isFavorite(String productId) {
    if (_box == null) return false;
    return _box!.containsKey(productId);
  }

  // Get semua ID produk favorit
  List<String> getFavoriteIds() {
    if (_box == null) return [];
    return _box!.keys.cast<String>().toList();
  }

  // Get semua favorit yang diurutkan berdasarkan waktu
  List<FavoriteModel> getAllFavorites() {
    if (_box == null) return [];
    
    final favorites = _box!.values.toList();
    favorites.sort((a, b) => b.favoritedAt.compareTo(a.favoritedAt));
    return favorites;
  }

  // Clear semua favorit
  Future<void> clearAll() async {
    if (_box == null) return;
    await _box!.clear();
  }

  // Get jumlah favorit
  int get favoriteCount {
    return _box?.length ?? 0;
  }

  // Listen untuk perubahan favorit (untuk reactive UI)
  Stream<BoxEvent>? watchFavorites() {
    return _box?.watch();
  }

  // Close box
  Future<void> close() async {
    await _box?.close();
  }
}