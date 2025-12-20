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
    filteredProducts.value = products;
  }

  Future<void> refreshProducts() async {
    clearSearch();
    await productService.loadProducts();
    loadProducts();
  }

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
    saveSearchToHistory(query);
    searchFocusNode.unfocus();
  }

  void focusSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (searchFocusNode.canRequestFocus) {
        searchFocusNode.requestFocus();
      }
    });
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }

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
