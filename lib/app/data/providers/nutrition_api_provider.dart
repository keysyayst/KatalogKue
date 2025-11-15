import 'package:dio/dio.dart';
import '../models/nutrition_model.dart';

class NutritionApiProvider {
  final Dio _dio = Dio();

  // API key dari https://fdc.nal.usda.gov/api-key-signup.html
  final String apiKey = 'IDPV7tHrlLTREq2QxlfXNBZMEdUWhy5wdW8kM68i';
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
          'dataType': [
            'Foundation',
            'SR Legacy',
          ], // Tipe data yang paling akurat
        },
      );

      print('📊 API Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['foods'] != null) {
        final foods = response.data['foods'] as List;

        if (foods.isNotEmpty) {
          final nutritionData = NutritionData.fromJson(foods[0]);
          print('✅ Found nutrition data for: ${nutritionData.name}');
          print(
            '   Calories: ${nutritionData.calories}, Protein: ${nutritionData.protein}g',
          );
          return nutritionData;
        } else {
          print('⚠ No nutrition data found for: $foodName');
          return null; // Return null instead of dummy
        }
      }

      print('⚠ Invalid response from API');
      return null;
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      return null; // Return null instead of dummy
    } catch (e) {
      print('❌ Error fetching nutrition: $e');
      return null; // Return null instead of dummy
    }
  }
}
