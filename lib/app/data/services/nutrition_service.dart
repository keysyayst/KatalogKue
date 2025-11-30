import 'package:get/get.dart';
import '../providers/nutrition_api_provider.dart';
import '../models/nutrition_model.dart';

class NutritionService extends GetxService {
  final NutritionApiProvider _provider = NutritionApiProvider();

  Future<NutritionData?> getNutritionData(String productName) async {
    return _provider.searchNutrition(productName);
  }
}
