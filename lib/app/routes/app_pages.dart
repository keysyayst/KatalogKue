import 'package:get/get.dart';

import '../app.dart';
import '../modules/produk_kami/bindings/produk_kami_binding.dart';
import '../modules/produk_kami/views/product_detail_page.dart'; 
import '../modules/produk_kami/views/produk_kami_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboard;

  static final routes = [
    GetPage(
      name: _Paths.dashboard, 
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.produkKami,
      page: () => const ProdukKamiPage(),
      binding: ProdukKamiBinding(),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProdukKamiBinding(),
    ),
  ];
}