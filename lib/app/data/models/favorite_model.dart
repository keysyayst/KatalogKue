import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 0)
class FavoriteModel extends HiveObject {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final DateTime favoritedAt;

  FavoriteModel({
    required this.productId,
    required this.favoritedAt,
  });
}
