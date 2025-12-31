import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../data/models/product.dart';
import '../../../data/models/nutrition_model.dart';
import '../../../data/services/nutrition_service.dart';
import '../../../data/services/search_history_hive_service.dart';
import '../../../data/sources/products.dart';

class ProdukController extends GetxController {
  final RxBool isSortMenuOpen = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final RxBool isOnline = true.obs;
  final ProductService productService = Get.find<ProductService>();
  final NutritionService nutritionService = Get.find<NutritionService>();
  final SearchHistoryHiveService searchHistoryService =
      Get.find<SearchHistoryHiveService>();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> searchHistory = <String>[].obs;

  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  final Rx<NutritionData?> nutritionData = Rx<NutritionData?>(null);
  final RxBool isLoadingNutrition = false.obs;
  final RxInt currentTabIndex = 0.obs;

  // --- FILTER VARIABLES ---
  final RxString selectedSort = 'default'.obs;
  final RxDouble minPriceFilter = 0.0.obs;
  final RxDouble maxPriceFilter = 1000000.0.obs;

  // Filter Kalori (Toggle)
  final RxBool isLowCalorie = false.obs;
  // -----------------------

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadSearchHistory();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    final connectivity = Connectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final wasOnline = isOnline.value;
      final hasConnection = result.any((r) => r != ConnectivityResult.none);
      isOnline.value = hasConnection;
      if (!wasOnline && isOnline.value) {
        refreshProducts();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    refreshProducts();
  }

  void loadProducts() {
    products.value = productService.getAllProducts();
    applyFilters();
  }

  Future<void> refreshProducts() async {
    try {
      // Reset filter
      searchQuery.value = '';
      searchController.clear();
      minPriceFilter.value = 0.0;
      maxPriceFilter.value = 1000000.0;
      selectedSort.value = 'default';
      isLowCalorie.value = false;

      await productService.loadProducts();
      loadProducts();
    } catch (e) {
      debugPrint('Error refreshProducts: $e');
    }
  }

  // --- LOGIKA FILTER UTAMA ---
  void applyFilters() {
    List<Product> tempProducts = List.from(products);

    // 1. Search
    if (searchQuery.value.isNotEmpty) {
      tempProducts = tempProducts.where((p) {
        return p.title.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            p.location.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // 2. Harga
    tempProducts = tempProducts.where((p) {
      String cleanPrice = p.price.replaceAll(RegExp(r'[^0-9]'), '');
      double price = double.tryParse(cleanPrice) ?? 0;
      return price >= minPriceFilter.value && price <= maxPriceFilter.value;
    }).toList();

    // 3. Kalori (< 300)
    if (isLowCalorie.value) {
      tempProducts = tempProducts.where((p) {
        double cal = 999.0;
        if (p.nutrition != null && p.nutrition!['calories'] != null) {
          cal = double.tryParse(p.nutrition!['calories'].toString()) ?? 999.0;
        }
        return cal < 300.0;
      }).toList();
    }

    // 4. Sort
    switch (selectedSort.value) {
      case 'price_low':
        tempProducts.sort((a, b) => _getPrice(a).compareTo(_getPrice(b)));
        break;
      case 'price_high':
        tempProducts.sort((a, b) => _getPrice(b).compareTo(_getPrice(a)));
        break;
      case 'a_z':
        tempProducts.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'z_a':
        tempProducts.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    filteredProducts.value = tempProducts;
  }

  double _getPrice(Product p) {
    return double.tryParse(p.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // --- ACTIONS ---
  void searchProducts(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void changeSort(String value) {
    selectedSort.value = value;
    applyFilters();
  }

  void changePriceRange(double min, double max) {
    minPriceFilter.value = min;
    maxPriceFilter.value = max;
    applyFilters();
  }

  void toggleLowCalorie(bool val) {
    isLowCalorie.value = val;
    applyFilters();
  }

  // History Logic
  void clearSearch() {
    searchController.clear();
    searchProducts('');
  }

  void saveSearchToHistory(String query) {
    if (query.isNotEmpty) {
      searchHistoryService.addSearch(query);
      loadSearchHistory();
    }
  }

  void loadSearchHistory() {
    searchHistory.value = searchHistoryService.getSearchHistory();
  }

  void removeSearchHistory(String q) {
    searchHistoryService.removeSearch(q);
    loadSearchHistory();
  }

  void clearSearchHistory() {
    searchHistoryService.clearHistory();
    loadSearchHistory();
  }

  void applySearchFromHistory(String q) {
    searchController.text = q;
    searchQuery.value = q;
    applyFilters();
    saveSearchToHistory(q);
    searchFocusNode.unfocus();
  }

  void focusSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (searchFocusNode.canRequestFocus) searchFocusNode.requestFocus();
    });
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }

  // Nutrition Logic
  Future<void> loadNutritionData(String productName) async {
    try {
      isLoadingNutrition(true);
      final data = await nutritionService.getNutritionData(productName);
      nutritionData.value = data ?? NutritionData.dummy();
    } catch (e) {
      nutritionData.value = NutritionData.dummy();
    } finally {
      isLoadingNutrition(false);
    }
  }

  void selectProduct(Product product) {
    selectedProduct.value = product;
    loadNutritionData(product.title);
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 2 &&
        selectedProduct.value != null &&
        nutritionData.value == null) {
      loadNutritionData(selectedProduct.value!.title);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
