import 'package:dio/dio.dart';
import '../models/meal_model.dart';

class MealDBApiProvider {
  final Dio _dio = Dio();
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Ambil semua desserts
  Future<List<Meal>> getDesserts() async {
    try {
      print('🍰 Fetching desserts from TheMealDB...');

      final response = await _dio.get(
        '$baseUrl/filter.php',
        queryParameters: {'c': 'Dessert'},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        final meals = (response.data['meals'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();

        print('✅ Found ${meals.length} desserts');
        return meals;
      }

      return [];
    } on DioException catch (e) {
      print('❌ Dio Error fetching desserts: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error fetching desserts: $e');
      rethrow;
    }
  }

  /// Ambil detail meal berdasarkan ID (untuk ingredients & instructions)
  Future<Meal?> getMealDetail(String mealId) async {
    try {
      print('🔍 Fetching meal detail for ID: $mealId');

      final response = await _dio.get(
        '$baseUrl/lookup.php',
        queryParameters: {'i': mealId},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        final meals = response.data['meals'] as List;
        if (meals.isNotEmpty) {
          final meal = Meal.fromJson(meals[0]);
          print('✅ Meal detail fetched: ${meal.strMeal}');
          return meal;
        }
      }

      return null;
    } on DioException catch (e) {
      print('❌ Dio Error fetching meal detail: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error fetching meal detail: $e');
      rethrow;
    }
  }

  /// Search meals by name
  Future<List<Meal>> searchMeals(String query) async {
    try {
      print('🔍 Searching meals: $query');

      final response = await _dio.get(
        '$baseUrl/search.php',
        queryParameters: {'s': query},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        final meals = (response.data['meals'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();

        print('✅ Found ${meals.length} meals');
        return meals;
      }

      return [];
    } on DioException catch (e) {
      print('❌ Dio Error searching meals: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Error searching meals: $e');
      return [];
    }
  }
}
