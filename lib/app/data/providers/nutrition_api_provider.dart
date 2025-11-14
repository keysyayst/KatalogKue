import 'package:dio/dio.dart';
import '../models/nutrition_model.dart';

class NutritionApiProvider {
  final Dio _dio = Dio();
  
  // GANTI dengan API key Anda dari https://fdc.nal.usda.gov/api-key-signup.html
  final String apiKey = 'https://api.nal.usda.gov/fdc/v1/foods/search?query=cookie&api_key=IDPV7tHrlLTREq2QxlfXNBZMEdUWhy5wdW8kM68i'; // Gunakan DEMO_KEY untuk testing
  final String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  Future<NutritionData?> searchNutrition(String foodName) async {
    try {
      print('🔍 Searching nutrition for: $foodName');
      
      final response = await _dio.get(
        '$baseUrl/foods/search',
        queryParameters: {
          'query': foodName,
          'api_key': apiKey,
          'pageSize': 1,
          'dataType': ['Foundation', 'SR Legacy'], // Tipe data yang paling akurat
        },
      );

      print('📊 API Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['foods'] != null) {
        final foods = response.data['foods'] as List;
        
        if (foods.isNotEmpty) {
          print('✅ Found nutrition data');
          return NutritionData.fromJson(foods[0]);
        } else {
          print('⚠ No nutrition data found');
          return NutritionData.dummy(); // Fallback ke data dummy
        }
      }
      
      return NutritionData.dummy();
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return NutritionData.dummy(); // Fallback
    } catch (e) {
      print('❌ Error fetching nutrition: $e');
      return NutritionData.dummy(); // Fallback
    }
  }
}