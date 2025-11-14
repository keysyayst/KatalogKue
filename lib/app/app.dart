import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import file-file yang dibutuhkan (PATH RELATIF)
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'modules/home/views/home_page.dart';
import 'modules/favorite/views/favorite_page.dart';
import 'modules/contact/views/contact_page.dart';
import 'modules/eksperimen/views/eksperimen_view.dart';
import 'modules/home/controllers/home_controller.dart';
import 'modules/favorite/controllers/favorite_controller.dart';
import 'modules/contact/controllers/contact_controller.dart';
import 'modules/eksperimen/controllers/eksperimen_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Katalog Kue Lebaran',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}

// =======================================================
// LOGIKA DASHBOARD
// =======================================================

class DashboardController extends GetxController {
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const FavoritePage(),
      const ContactPage(),
      const EksperimenView(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: controller.tabIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          selectedItemColor: const Color(0xFFFE8C00),
          unselectedItemColor: Colors.grey,
          onTap: controller.changeTabIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Contact',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science_outlined),
              label: 'Eksperimen',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FavoriteController());
    Get.lazyPut(() => ContactController());
    Get.lazyPut(() => EksperimenController());
  }
}
