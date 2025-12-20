import 'package:flutter/foundation.dart'; // Import ini wajib untuk debugPrint
import 'package:get/get.dart';
import '../models/product.dart';
import '../providers/product_api_provider.dart';
import '../services/favorite_hive_service.dart';

class ProductService extends GetxService {
  final FavoriteHiveService _favoriteService = Get.find<FavoriteHiveService>();
  final ProductApiProvider _apiProvider = ProductApiProvider();
  final RxList<Product> _products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  ProductService() {
    loadProducts();
  }

  // Load products from database
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final products = await _apiProvider.getAllProducts();
      _products.value = products;
      debugPrint('✅ Loaded ${products.length} products from database');
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      // Fallback ke produk lokal jika gagal
      _initializeLocalProducts();
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeLocalProducts() {
    _products.value = [
      Product(
        id: '1',
        title: 'Nastar',
        price: '50.000/toples',
        location: 'Malang',
        image: 'assets/images/nastar.png',
      ),
      Product(
        id: '2',
        title: 'Kastengel',
        price: '55.000/toples',
        location: 'Malang',
        image: 'assets/images/kastengel.png',
      ),
      Product(
        id: '3',
        title: 'Putri Salju',
        price: '50.000/toples',
        location: 'Malang',
        image: 'assets/images/putrisalju.png',
      ),
      Product(
        id: '4',
        title: 'Lidah Kucing',
        price: '45.000/toples',
        location: 'Malang',
        image: 'assets/images/lidahkucing.png',
      ),
      Product(
        id: '5',
        title: 'Sagu Keju',
        price: '48.000/toples',
        location: 'Malang',
        image: 'assets/images/sagukeju.png',
      ),
      Product(
        id: '6',
        title: 'Palm Cheese',
        price: '52.000/toples',
        location: 'Malang',
        image: 'assets/images/palmcheese.png',
      ),
      Product(
        id: '7',
        title: 'Thumbprint',
        price: '50.000/toples',
        location: 'Malang',
        image: 'assets/images/thumbrin.png',
      ),
      Product(
        id: '8',
        title: 'Brownies Cup',
        price: '60.000/box',
        location: 'Malang',
        image: 'assets/images/browniescup.png',
      ),
    ];
  }

  // Get all products
  List<Product> getAllProducts() {
    return _products.toList();
  }

  // Get favorite products (dari Hive)
  List<Product> getFavoriteProducts() {
    final favoriteIds = _favoriteService.getFavoriteIds();
    return _products
        .where((product) => favoriteIds.contains(product.id))
        .toList();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId) async {
    await _favoriteService.toggleFavorite(productId);
    _products.refresh(); // Trigger UI update
  }

  // Check if favorite
  bool isFavorite(String productId) {
    return _favoriteService.isFavorite(productId);
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create product
  Future<Product?> createProduct(Product product, String userId) async {
    try {
      final newProduct = await _apiProvider.createProduct(product, userId);
      await loadProducts(); // Reload list
      return newProduct;
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      return null;
    }
  }

  // Update product
  Future<Product?> updateProduct(String id, Product product) async {
    try {
      final updatedProduct = await _apiProvider.updateProduct(id, product);
      await loadProducts(); // Reload list
      return updatedProduct;
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      return null;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      await _apiProvider.deleteProduct(id);
      await loadProducts(); // Reload list
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      return false;
    }
  }
}
