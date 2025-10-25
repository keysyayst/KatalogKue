part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const dashboard = _Paths.dashboard; // <-- Diperbaiki
  static const produkKami = _Paths.produkKami; // <-- Diperbaiki
  static const productDetail =
      _Paths.produkKami + _Paths.productDetail; // <-- Diperbaiki
}

abstract class _Paths {
  static const dashboard = '/'; // <-- Diperbaiki
  static const produkKami = '/produk-kami'; // <-- Diperbaiki
  static const productDetail = '/:id'; // <-- Diperbaiki
}