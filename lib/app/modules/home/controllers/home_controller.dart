// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../data/sources/products.dart';
import '../../../app.dart';
import '../../delivery_checker/controllers/delivery_checker_controller.dart';
import '../../produk/controllers/produk_controller.dart';

class HomeController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  
  final isLoadingProducts = true.obs;
  
  List<Product> get rekomendasiProducts {
    return _productService.getAllProducts().take(8).toList();
  }

  final currentBannerIndex = 0.obs;
  final PageController bannerController = PageController();
  final favoriteCount = 0.obs;
  final pendingOrderCount = 0.obs;

  final promoBanners = <Map<String, String>>[
    {
      'image': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
      'title': 'Diskon 30% Cake Ulang Tahun',
      'subtitle': 'Pesan sekarang dan hemat!',
    },
    {
      'image': 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=800',
      'title': 'Brownies Special Rp 50K',
      'subtitle': 'Promo terbatas hari ini',
    },
    {
      'image': 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=800',
      'title': 'Free Delivery Min 100K',
      'subtitle': 'Gratis ongkir ke seluruh kota',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _startBannerAutoSlide();
    _loadFavoriteCount();
    _loadProducts();
  }

  @override
  void onClose() {
    bannerController.dispose();
    super.onClose();
  }

  void _loadProducts() async {
    isLoadingProducts.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoadingProducts.value = false;
  }

  void _startBannerAutoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (bannerController.hasClients) {
        try {
          int nextPage = (currentBannerIndex.value + 1) % promoBanners.length;
          bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          _startBannerAutoSlide();
        } catch (e) {
          // Silent error
        }
      }
    });
  }

  void onBannerChanged(int index) {
    currentBannerIndex.value = index;
  }

  void _loadFavoriteCount() {
    favoriteCount.value = 3;
    pendingOrderCount.value = 1;
  }

  // ===== NAVIGATION METHODS =====
  
  void onQuickActionPressed(String action) {
    switch (action) {
      case 'favorite':
        navigateToTab(2);
        break;
        
      case 'track':
        navigateToTab(3);
        break;
        
      case 'products':
        navigateToTab(1);
        break;
        
      case 'pickup':
        navigateToPickupMode();
        break;
    }
  }
  
  void navigateToTab(int index) {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.changeTabIndex(index);
    } catch (e) {
      print('Error navigating to tab $index: $e');
      switch (index) {
        case 1:
          Get.toNamed('/produk');
          break;
        case 2:
          Get.toNamed('/produk-kami');
          break;
        case 3:
          Get.toNamed('/delivery-checker');
          break;
      }
    }
  }

  void navigateToPickupMode() {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.changeTabIndex(3);
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isRegistered<DeliveryCheckerController>()) {
          Get.toNamed('/delivery-checker');
        }
      });
    } catch (e) {
      print('Error navigating to pickup mode: $e');
      Get.toNamed('/delivery-checker');
    }
  }

  void navigateToProductsPage() {
    navigateToTab(1);
  }

  // ===== SEARCH NAVIGATION =====
  
  void navigateToSearch() {
    try {
      // 1. Pindah ke tab Produk (index 1)
      final dashboardController = Get.find<DashboardController>();
      dashboardController.changeTabIndex(1);
      
      // 2. Fokus ke search field dengan delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (Get.isRegistered<ProdukController>()) {
          final produkController = Get.find<ProdukController>();
          // Fokus ke search field untuk membuka keyboard
          produkController.focusSearch();
        }
      });
    } catch (e) {
      print('Error navigating to search: $e');
      Get.toNamed('/produk');
    }
  }
}
