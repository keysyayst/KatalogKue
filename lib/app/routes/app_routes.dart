part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const dashboard = _Paths.dashboard;
  static const auth = _Paths.auth;
  static const profile = _Paths.profile;
  static const produkKami = _Paths.produkKami;
  static const produk = _Paths.produk;
  static const adminProducts = _Paths.adminProducts;
  static const productDetail = '/product/:id';
  static const DELIVERY_CHECKER = _Paths.DELIVERY_CHECKER;
  static const adminDeliveryStores = _Paths.adminDeliveryStores;
  // locationExperiment DIHAPUS
  static const NOTIFICATION = _Paths.NOTIFICATION;
}

abstract class _Paths {
  _Paths._();

  static const dashboard = '/dashboard';
  static const auth = '/auth';
  static const profile = '/profile';
  static const produkKami = '/produk-kami';
  static const produk = '/produk';
  static const adminProducts = '/admin/products';
  static const adminDeliveryStores = '/admin/delivery-stores';
  static const DELIVERY_CHECKER = '/delivery-checker';

  static const NOTIFICATION = '/notification';
}
