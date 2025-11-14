import 'package:get/get.dart';
import '../models/product.dart';
import '../services/favorite_hive_service.dart';

class ProductService extends GetxService {
  final FavoriteHiveService _favoriteService = Get.find<FavoriteHiveService>();
  final RxList<Product> _products = <Product>[].obs;

  ProductService() {
    _initializeProducts();
  }

  void _initializeProducts() {
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
}
