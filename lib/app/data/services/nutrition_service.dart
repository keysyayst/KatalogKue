import 'package:get/get.dart';
import '../providers/nutrition_api_provider.dart';
import '../models/nutrition_model.dart';

class NutritionService extends GetxService {
  final NutritionApiProvider _provider = NutritionApiProvider();

  Future<NutritionData?> getNutritionData(String productName) async {
    // Langsung teruskan nama produk ke provider; mapping dilakukan di layer pemanggil bila perlu.
    return _provider.searchNutrition(productName);
  }
}
