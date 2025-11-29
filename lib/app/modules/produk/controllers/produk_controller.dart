import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product.dart';
import '../../../data/models/nutrition_model.dart';
import '../../../data/services/nutrition_service.dart';
import '../../../data/services/search_history_hive_service.dart';
import '../../../data/sources/products.dart';

class ProdukController extends GetxController {
  final ProductService productService = Get.find<ProductService>();
  final NutritionService nutritionService = Get.find<NutritionService>();
  final SearchHistoryHiveService searchHistoryService =
      Get.find<SearchHistoryHiveService>();

  // Controller untuk text field pencarian
  final TextEditingController searchController = TextEditingController();

  // List produk
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;

  // State pencarian
  final RxString searchQuery = ''.obs;
  final RxList<String> searchHistory = <String>[].obs;

  // Untuk detail produk
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  final Rx<NutritionData?> nutritionData = Rx<NutritionData?>(null);
  final RxBool isLoadingNutrition = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadSearchHistory();
  }

  @override
  void onReady() {
    super.onReady();
    // Reload products saat controller ready
    refreshProducts();
  }

  // ================== PRODUK ==================

  void loadProducts() {
    products.value = productService.getAllProducts();
    filteredProducts.value = products;
  }

  Future<void> refreshProducts() async {
    // Clear search saat refresh
    clearSearch();
    await productService.loadProducts();
    loadProducts();
  }

  // ================== PENCARIAN ==================

  void searchProducts(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products.where((Product product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
    searchProducts('');
  }

  void saveSearchToHistory(String query) {
    if (query.trim().isNotEmpty) {
      searchHistoryService.addSearch(query);
      loadSearchHistory();
    }
  }

  void loadSearchHistory() {
    searchHistory.value = searchHistoryService.getSearchHistory();
  }

  void removeSearchHistory(String query) {
    searchHistoryService.removeSearch(query);
    loadSearchHistory();
  }

  void clearSearchHistory() {
    searchHistoryService.clearHistory();
    loadSearchHistory();
  }

  void applySearchFromHistory(String query) {
    searchController.text = query;
    searchQuery.value = query;
    searchProducts(query);
    // Pindahkan query yang diklik ke paling atas history
    saveSearchToHistory(query);
  }

  // ================== NUTRISI & DETAIL ==================

  Future<void> loadNutritionData(String productName) async {
    try {
      isLoadingNutrition(true);

      final data = await nutritionService.getNutritionData(productName);

      // data bertipe NutritionData? → handle null
      if (data != null) {
        nutritionData.value = data;
      } else {
        nutritionData.value = NutritionData.dummy();
      }
    } catch (e) {
      nutritionData.value = NutritionData.dummy();
    } finally {
      isLoadingNutrition(false);
    }
  }

  /// Dipanggil ketika user memilih sebuah produk (dari grid atau dari tempat lain)
  void selectProduct(Product product) {
    selectedProduct.value = product;
    loadNutritionData(product.title);
  }

  /// Mengatur tab pada DetailProdukPage (Deskripsi / Komposisi / Nutrisi)
  void changeTab(int index) {
    currentTabIndex.value = index;

    // Load nutrition data saat tab nutrisi dibuka pertama kali
    if (index == 2 &&
        selectedProduct.value != null &&
        nutritionData.value == null) {
      loadNutritionData(selectedProduct.value!.title);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
