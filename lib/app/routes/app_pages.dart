import 'package:get/get.dart';

import '../app.dart'; // <-- Path Relatif
import '../modules/produk_kami/bindings/produk_kami_binding.dart'; // <-- Path Relatif
import '../modules/produk_kami/views/product_detail_page.dart'; // <-- Path Relatif
import '../modules/produk_kami/views/produk_kami_page.dart'; // <-- Path Relatif

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboard; // <-- Diperbaiki

  static final routes = [
    GetPage(
      name: _Paths.dashboard, // <-- Diperbaiki
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.produkKami, // <-- Diperbaiki
      page: () => const ProdukKamiPage(),
      binding: ProdukKamiBinding(),
    ),
    GetPage(
      name: Routes.productDetail, // <-- Diperbaiki
      page: () => const ProductDetailPage(),
      binding: ProdukKamiBinding(),
    ),
  ];
}