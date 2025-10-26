import 'dart:async'; 
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../../../data/models/meal_model.dart';
import '../views/hasil_tes_page.dart'; 

class ContactController extends GetxController {
  final String apiEndpoint = 'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert';
  
  final Dio _dio = Dio();
  final Stopwatch _stopwatch = Stopwatch();
  var httpResult = 'Tekan tombol untuk tes HTTP'.obs;
  var dioResult = 'Tekan tombol untuk tes Dio'.obs;
  var isLoading = false.obs;

  Future<void> runHttpTest() async {
    isLoading.value = true;
    httpResult.value = 'Loading...';

    try {
      _stopwatch.reset();
      _stopwatch.start();

      final response = await http.get(Uri.parse(apiEndpoint));
      
      _stopwatch.stop();
      final duration = _stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        final List<Meal> meals = (data['meals'] as List)
            .map((mealJson) => Meal.fromJson(mealJson))
            .toList();

        Get.to(() => const HasilTesPage(), arguments: {
          'library': 'HTTP',
          'duration': duration,
          'meals': meals,
        });
        
        httpResult.value = 'Tes HTTP Selesai.'; 
      } else {
        httpResult.value = 'HTTP: Error! Status: ${response.statusCode}';
      }
    } catch (e) {
      _stopwatch.stop();
      httpResult.value = 'HTTP: Exception! ${e.toString().substring(0, 50)}...';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> runDioTest() async {
    isLoading.value = true;
    dioResult.value = 'Loading...';

    try {
      _stopwatch.reset();
      _stopwatch.start();

      final response = await _dio.get(apiEndpoint);
      
      _stopwatch.stop();
      final duration = _stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data; 
        final List<Meal> meals = (data['meals'] as List)
            .map((mealJson) => Meal.fromJson(mealJson))
            .toList();
        Get.to(() => const HasilTesPage(), arguments: {
          'library': 'Dio',
          'duration': duration,
          'meals': meals,
        });

        dioResult.value = 'Tes Dio Selesai.';
      } else {
        dioResult.value = 'Dio: Error! Status: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _stopwatch.stop();
      dioResult.value = 'Dio: DioException! ${e.message}';
    } catch (e) {
      _stopwatch.stop();
      dioResult.value = 'Dio: Exception! ${e.toString().substring(0, 50)}...';
    } finally {
      isLoading.value = false;
    }
  }
}