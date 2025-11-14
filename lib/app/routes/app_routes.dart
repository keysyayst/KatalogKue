part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const dashboard = _Paths.dashboard;
  static const auth = _Paths.auth;
  static const profile = _Paths.profile;
  static const produkKami = _Paths.produkKami;
  static const produk = _Paths.produk;
  static const adminProducts = _Paths.adminProducts; // ← TAMBAHAN
  static const productDetail = '/product/:id';
}

abstract class _Paths {
  _Paths._();

  static const dashboard = '/dashboard';
  static const auth = '/auth';
  static const profile = '/profile';
  static const produkKami = '/produk-kami';
  static const produk = '/produk';
  static const adminProducts = '/admin/products'; // ← TAMBAHAN
}
