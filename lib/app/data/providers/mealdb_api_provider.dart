import 'package:flutter/foundation.dart'; // Import ini buat debugPrint
import 'package:dio/dio.dart';
import '../models/meal_model.dart';

class MealDBApiProvider {
  final Dio _dio = Dio();
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> getDesserts() async {
    try {
      debugPrint('🍰 Fetching desserts from TheMealDB...');

      final response = await _dio.get(
        '$baseUrl/filter.php',
        queryParameters: {'c': 'Dessert'},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        final meals = (response.data['meals'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();

        debugPrint('✅ Found ${meals.length} desserts');
        return meals;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ Dio Error fetching desserts: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error fetching desserts: $e');
      rethrow;
    }
  }

  Future<Meal?> getMealDetail(String mealId) async {
    try {
      debugPrint('🔍 Fetching meal detail for ID: $mealId');

      final response = await _dio.get(
        '$baseUrl/lookup.php',
        queryParameters: {'i': mealId},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        final meals = response.data['meals'] as List;
        if (meals.isNotEmpty) {
          final meal = Meal.fromJson(meals[0]);
          debugPrint('✅ Meal detail fetched: ${meal.strMeal}');
          return meal;
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ Dio Error fetching meal detail: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error fetching meal detail: $e');
      rethrow;
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    try {
      debugPrint('🔍 Searching meals: $query');

      final response = await _dio.get(
        '$baseUrl/search.php',
        queryParameters: {'s': query},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        final meals = (response.data['meals'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();

        debugPrint('✅ Found ${meals.length} meals');
        return meals;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ Dio Error searching meals: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Error searching meals: $e');
      return [];
    }
  }
}
