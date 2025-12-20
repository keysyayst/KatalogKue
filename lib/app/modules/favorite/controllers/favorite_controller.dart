import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/sources/products.dart';
import '../../../data/services/favorite_supabase_service.dart';
import '../../../data/services/favorite_hive_service.dart';
import '../../../data/services/auth_service.dart';

class FavoriteController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final FavoriteSupabaseService _favoriteService =
      Get.find<FavoriteSupabaseService>();
  final FavoriteHiveService _favoriteHiveService =
      Get.find<FavoriteHiveService>();
  final AuthService _authService = Get.find<AuthService>();

  RxList<Product> favoriteProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;
    // Ambil ID favorite dari lokal
    final localFavIds = _favoriteHiveService.getFavoriteIds();
    // Ambil data favorite dari Supabase, filter hanya yang ada di lokal
    final supabaseFavIds = await _favoriteService.getFavoriteIds(userId);
    final filteredIds = supabaseFavIds
        .where((id) => localFavIds.contains(id))
        .toList();
    final allProducts = _productService.getAllProducts();
    favoriteProducts.value = allProducts
        .where((p) => filteredIds.contains(p.id))
        .toList();
  }

  Future<void> toggleFavorite(String productId) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;
    // Toggle lokal dulu
    await _favoriteHiveService.toggleFavorite(productId);
    // Sinkron ke Supabase: jika sekarang jadi favorite, tambahkan ke Supabase
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
