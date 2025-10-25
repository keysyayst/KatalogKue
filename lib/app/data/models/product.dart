import 'package:get/get.dart';

class Product {
  final String id;
  final String title;
  final String location;
  final int price;
  final String image;
  RxBool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.image,
    bool isFavorite = false,
  }) : isFavorite = isFavorite.obs;
}
