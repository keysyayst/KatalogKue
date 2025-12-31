import 'package:hive_flutter/hive_flutter.dart';
import '../models/favorite_model.dart';

class FavoriteHiveService {
  static const String _boxName = 'favorites';
  Box<FavoriteModel>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FavoriteModelAdapter());
    }
    
    _box = await Hive.openBox<FavoriteModel>(_boxName);
  }
  Future<void> toggleFavorite(String productId) async {
    if (_box == null) return;

    if (_box!.containsKey(productId)) {
      await _box!.delete(productId);
    } else {
      await _box!.put(
        productId,
        FavoriteModel(
          productId: productId,
          favoritedAt: DateTime.now(),
        ),
      );
    }
  }
  bool isFavorite(String productId) {
    if (_box == null) return false;
    return _box!.containsKey(productId);
  }

  List<String> getFavoriteIds() {
    if (_box == null) return [];
    return _box!.keys.cast<String>().toList();
  }
  List<FavoriteModel> getAllFavorites() {
    if (_box == null) return [];
    
    final favorites = _box!.values.toList();
    favorites.sort((a, b) => b.favoritedAt.compareTo(a.favoritedAt));
    return favorites;
  }

  Future<void> clearAll() async {
    if (_box == null) return;
    await _box!.clear();
  }

  int get favoriteCount {
    return _box?.length ?? 0;
  }

  Stream<BoxEvent>? watchFavorites() {
    return _box?.watch();
  }

  Future<void> close() async {
    await _box?.close();
  }
}