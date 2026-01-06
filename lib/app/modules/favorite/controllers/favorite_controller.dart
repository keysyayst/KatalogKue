import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_supabase_service.dart';
import '../../../data/services/favorite_supabase_service.dart';
import '../../../data/services/favorite_hive_service.dart';
import '../../../data/services/auth_service.dart';

class FavoriteController extends GetxController {
  final ProductSupabaseService _productService =
      Get.find<ProductSupabaseService>();
  final FavoriteSupabaseService _favoriteService =
      Get.find<FavoriteSupabaseService>();
  final FavoriteHiveService _favoriteHiveService =
      Get.find<FavoriteHiveService>();
  final AuthService _authService = Get.find<AuthService>();

  RxList<Product> favoriteProducts = <Product>[].obs;
  late final Worker _productWatcher;

  @override
  void onInit() {
    super.onInit();
    // Sinkronkan favorit setiap kali daftar produk berubah (mis. setelah delete)
    _productWatcher = ever<List<Product>>(
      _productService.products,
      (_) => fetchFavorites(),
    );
    fetchFavorites();
  }

  @override
  void onClose() {
    _productWatcher.dispose();
    super.onClose();
  }

  Future<void> fetchFavorites() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    final supabaseFavIds = await _favoriteService.getFavoriteIds(userId);

    final localFavIds = _favoriteHiveService.getFavoriteIds();

    for (final id in supabaseFavIds) {
      if (!localFavIds.contains(id)) {
        await _favoriteHiveService.toggleFavorite(id);
      }
    }

    for (final id in localFavIds) {
      if (!supabaseFavIds.contains(id)) {
        await _favoriteHiveService.toggleFavorite(id);
      }
    }

    final allProducts = _productService.products;
    favoriteProducts.value = allProducts
        .where((p) => supabaseFavIds.contains(p.id))
        .toList();
  }

  Future<void> toggleFavorite(String productId) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;
    await _favoriteHiveService.toggleFavorite(productId);
    final isNowFavorite = _favoriteHiveService.isFavorite(productId);
    if (isNowFavorite) {
      await _favoriteService.addFavorite(userId, productId);
    } else {
      await _favoriteService.removeFavorite(userId, productId);
    }
    await fetchFavorites();
  }

  Future<bool> isFavorite(String productId) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return false;
    return await _favoriteService.isFavorite(userId, productId);
  }

  void refreshFavorites() {
    fetchFavorites();
  }
}
