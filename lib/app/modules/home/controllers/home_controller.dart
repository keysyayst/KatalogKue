import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
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
      'image':
          'https://smartpluspro.com/app/repository/upload/2025_Boleci%20Copyright/4_April/Resep/nastar-gluten-free.jpg', // Nastar cookies
      'title': 'Nastar Spesial',
      'subtitle': 'Kue kering favorit keluarga!',
    },
    {
      'image':
          'https://img.freepik.com/free-photo/delicious-dessert-table_23-2151901934.jpg?t=st=1766220929~exp=1766224529~hmac=b5294fa190446488af0971936f2e6cc126f575c2e44ced87e15a43b81b936c6f&w=1060', // Brownies
      'title': 'Brownies Cup Lezat ',
      'subtitle': 'Mulai dari Rp 50K per box',
    },
    {
      'image':
          'https://lh6.googleusercontent.com/proxy/noSGK21lOQeuOTzzOC_i6oZT9h8CZPs9SP6WF0ro-IF474UoDHZN26xXU9Ds2UMKQEu0zQfagp1sow30SSRo8YfGTDSrUWDSTPREk3XcSea7vCmXG-P_UIWQs-VormEvhVRmMGi1Sy79x8DGFIiJkgjfbvvJAgvnqrbALnDHapZ28yRhXt3Tceypa4woMgyFoA05qw', // Thumbprint cookies
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
  }

void _initConnectivityListener() {
  final connectivity = Connectivity();

  _connectivitySubscription =
      connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
    final wasOnline = isOnline.value;
    final hasConnection = result.any((r) => r != ConnectivityResult.none);

    isOnline.value = hasConnection;

    if (!wasOnline && isOnline.value) {
      // panggil method yang benar
      reloadAllData();
    }
  });
}

// public, tanpa underscore di depan
Future<void> reloadAllData() async {
  _loadProducts();
  // nanti kalau mau, tambahkan refresh lain di sini
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
