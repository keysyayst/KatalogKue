import 'package:get/get.dart';

import '../app.dart';
import '../middlewares/auth_middleware.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_products_page.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_page.dart';
// Dashboard import otomatis ada karena di file app.dart
import '../modules/delivery_checker/bindings/delivery_checker_binding.dart';
import '../modules/delivery_checker/views/delivery_checker_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/produk/bindings/produk_binding.dart';
import '../modules/produk/views/detail_produk_page.dart';
import '../modules/produk/views/produk_page.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboard;

  static final routes = [
    GetPage(
      name: _Paths.auth,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.produkKami,
      page: () => const ProdukPage(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const DetailProdukPage(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: _Paths.produk,
      page: () => const ProdukPage(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: _Paths.adminProducts,
      page: () => const AdminProductsPage(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.DELIVERY_CHECKER,
      page: () => const DeliveryCheckerView(),
      binding: DeliveryCheckerBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
  ];
}
