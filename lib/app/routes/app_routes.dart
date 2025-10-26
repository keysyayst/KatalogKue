part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const dashboard = _Paths.dashboard;
  static const produkKami = _Paths.produkKami; 
  static const productDetail =
      _Paths.produkKami + _Paths.productDetail; 
}

abstract class _Paths {
  static const dashboard = '/'; 
  static const produkKami = '/produk-kami'; 
  static const productDetail = '/:id'; 
}