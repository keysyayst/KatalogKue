import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import semua yang dibutuhkan
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'modules/home/views/home_page.dart';
import 'modules/favorite/views/favorite_page.dart';
import 'modules/produk/views/produk_page.dart';
import 'modules/profile/views/profile_page.dart';
import 'modules/home/controllers/home_controller.dart';
import 'modules/favorite/controllers/favorite_controller.dart';
import 'modules/produk/controllers/produk_controller.dart';
import 'modules/profile/controllers/profile_controller.dart';
import 'data/services/nutrition_service.dart';
import 'data/services/auth_service.dart';
import 'modules/delivery_checker/views/delivery_checker_view.dart';
import 'modules/delivery_checker/controllers/delivery_checker_controller.dart';
import 'data/services/location_service.dart';

// ========================================================
// APP WIDGET (MODIFIED)
// ========================================================

class App extends StatelessWidget {
  final String initialRoute; // Menerima parameter rute awal

  const App({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());

    return GetMaterialApp(
      title: 'Katalog Kue',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute, // <-- Gunakan variabel ini
      getPages: AppPages.routes,
    );
  }
}

// =======================================================
// DASHBOARD (FULL CODE)
// =======================================================

class DashboardController extends GetxController {
  var tabIndex = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: tabIndex.value);
    pageController.addListener(() {
      final page = pageController.page?.round() ?? tabIndex.value;
      if (page != tabIndex.value) tabIndex.value = page;
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) async {
    try {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      tabIndex.value = index;
    } catch (_) {
      tabIndex.value = index;
    }
  }
}

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const ProdukPage(),
      const FavoritePage(),
      const DeliveryCheckerView(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Obx(
        () => PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          selectedItemColor: const Color(0xFFFE8C00),
          unselectedItemColor: Colors.grey,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'Delivery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => NutritionService());

    // Location Service Check
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService());
    }

    // Controllers
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FavoriteController());
    Get.lazyPut(() => ProdukController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => DeliveryCheckerController());
  }
}
