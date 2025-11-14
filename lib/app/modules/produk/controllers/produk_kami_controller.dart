import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/product.dart';
import '../../../data/sources/products.dart';

class ProdukKamiController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final Dio _dio = Dio();
  final String _apiEndpoint =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert';
  final String _apiDetailEndpoint =
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=';

  var isLoading = true.obs;
  var apiMeals = <Meal>[].obs;
  var selectedApiMealDetail = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchApiMeals();
  }

  Future<void> fetchApiMeals() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(_apiEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> mealsJson = response.data['meals'];
        apiMeals.value = mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        // Handle error
        if (kDebugMode) {
          print('Error fetching API: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle exception
      if (kDebugMode) {
        print('Exception fetching API: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchApiMealDetail(String id) async {
    try {
      final response = await _dio.get('$_apiDetailEndpoint$id');
      if (response.statusCode == 200 && response.data['meals'] != null) {
        return response.data['meals'][0];
      } else {
        if (kDebugMode) {
          print('Error fetching detail: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception fetching detail: $e');
      }
      return null;
    }
  }

  Product? getProductById(String id) {
    try {
      return _productService.allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> get allProducts {
    return _productService.allProducts;
  }

  List<dynamic> get combinedProducts {
    final localProducts = _productService.allProducts;
    final networkProducts = apiMeals.map((meal) {
      return Product(
        id: meal.id,
        title: meal.name,
        location: 'Online',
        price: 25000, // Harga default
        image: meal.thumbnail,
        isFavorite: false,
      );
    }).toList();
    return [...localProducts, ...networkProducts];
  }
}
