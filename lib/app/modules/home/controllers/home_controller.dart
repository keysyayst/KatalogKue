import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../data/models/product.dart';
import '../../../app.dart';
import '../../delivery_checker/controllers/delivery_checker_controller.dart';
import '../../produk/controllers/produk_controller.dart';
import 'package:cake_by_mommy/app/data/services/product_supabase_service.dart';
import 'package:cake_by_mommy/app/modules/favorite/controllers/favorite_controller.dart';
import 'package:cake_by_mommy/app/modules/profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final ProductSupabaseService _productService =
      Get.find<ProductSupabaseService>();
  final isLoadingProducts = true.obs;
  final currentBannerIndex = 0.obs;
  final PageController bannerController = PageController();
  final favoriteCount = 0.obs;
  final pendingOrderCount = 0.obs;

  List<Product> get rekomendasiProducts {
    return _productService.products.take(8).toList();
  }

  final promoBanners = <Map<String, String>>[
    {
      'image': 'https://smartpluspro.com/.../nastar-gluten-free.jpg',
      'title': 'Nastar Spesial',
      'subtitle': 'Kue kering favorit keluarga!',
    },
    {
      'image':
          'https://img.freepik.com/.../delicious-dessert-table_23-2151901934.jpg',
      'title': 'Brownies Cup Lezat ',
      'subtitle': 'Mulai dari Rp 50K per box',
    },
    {
      'image': 'https://lh6.googleusercontent.com/.../thumbprint_cookies.jpg',
      'title': 'Thumbprint Premium',
      'subtitle': 'Renyah dengan selai pilihan!',
    },
  ].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _startBannerAutoSlide();
    _loadFavoriteCount();
    _loadProducts();
    _initConnectivityListener();
    _productService.loadProducts();
    Connectivity().checkConnectivity().then((result) {
      final hasConnection = result != ConnectivityResult.none;
      isOnline.value = hasConnection;
      if (hasConnection) {
        reloadAllData();
      }
    });
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
        reloadAllData();
      }
    });
  }

  Future<void> reloadAllData() async {
    isLoadingProducts.value = true;
    try {
      if (Get.isRegistered<ProductSupabaseService>()) {
        await Get.find<ProductSupabaseService>().loadProducts();
        update();
      }
      if (Get.isRegistered<FavoriteController>()) {
        await Get.find<FavoriteController>().fetchFavorites();
      }
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().loadProfile();
      }
      if (Get.isRegistered<DeliveryCheckerController>()) {
        await Get.find<DeliveryCheckerController>().fetchStore();
      }
    } catch (e) {
      debugPrint('Error reloadAllData: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  @override
  void onClose() {
    bannerController.dispose();
    _connectivitySubscription?.cancel();
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
          currentBannerIndex.value = nextPage;
          _startBannerAutoSlide();
        } catch (e) {
          debugPrint('Banner auto-slide error: $e');
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

  void onQuickActionPressed(String action) {
    switch (action) {
      case 'favorite':
        navigateToTab(2);
        break;
      case 'order_now':
        // Langsung buka WhatsApp (pakai logic dari DeliveryCheckerController)
        if (Get.isRegistered<DeliveryCheckerController>()) {
          Get.find<DeliveryCheckerController>().openWhatsApp();
        } else {
          Get.toNamed('/delivery-checker');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<DeliveryCheckerController>()) {
              Get.find<DeliveryCheckerController>().openWhatsApp();
            }
          });
        }
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
      debugPrint('Error navigating to tab $index: $e');
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
      debugPrint('Error navigating to pickup mode: $e');
      Get.toNamed('/delivery-checker');
    }
  }

  void navigateToProductsPage() {
    navigateToTab(1);
  }

  void navigateToSearch() {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.changeTabIndex(1);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (Get.isRegistered<ProdukController>()) {
          final produkController = Get.find<ProdukController>();
          produkController.focusSearch();
        }
      });
    } catch (e) {
      debugPrint('Error navigating to search: $e');
      Get.toNamed('/produk');
    }
  }
}
