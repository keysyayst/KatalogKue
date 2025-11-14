import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../../data/models/meal_model.dart';
import '../../contact/views/hasil_tes_page.dart';

class EksperimenController extends GetxController {
  // --- API ENDPOINTS ---
  final String apiEndpointPerf =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert';
  final String apiEndpointIngredient =
      'https://www.themealdb.com/api/json/v1/1/filter.php?i=';
  final String badApiEndpoint = 'https://api.domain-salah.com/v1/data';

  // 🔹 tambahan untuk chained request
  final String apiEndpointCategories =
      'https://www.themealdb.com/api/json/v1/1/categories.php';
  final String apiEndpointByCategory =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=';
  final String apiEndpointDetail =
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=';

  final Dio _dio = Dio();
  final Stopwatch _stopwatch = Stopwatch();

  // --- UI STATES ---
  var httpResult = 'Tekan tombol untuk tes HTTP'.obs;
  var httpErrorResult = 'Tekan tombol untuk tes Error HTTP'.obs;
  var dioResult = 'Tekan tombol untuk tes Dio'.obs;
  var dioErrorResult = 'Tekan tombol untuk tes Error Dio'.obs;
  var isLoading = false.obs;
  var asyncResult =
      'Masukkan bahan dan tekan tombol tes Async'.obs; // pesan awal
  var chainedResult =
      'Tekan tombol untuk tes Chained Request'.obs; // 🔹 hasil chained

  @override
  void onInit() {
    super.onInit();
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  // --- FUNGSI TES PERFORMA & ERROR (Tugas 1 & 2) ---
  Future<void> runHttpTest() async {
    isLoading.value = true;
    httpResult.value = 'Loading...';
    try {
      _stopwatch.reset();
      _stopwatch.start();
      final response = await http.get(Uri.parse(apiEndpointPerf));
      _stopwatch.stop();
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Meal> meals = (data['meals'] as List)
            .map((m) => Meal.fromJson(m))
            .toList();
        Get.to(
          () => const HasilTesPage(),
          arguments: {
            'library': 'HTTP',
            'duration': _stopwatch.elapsedMilliseconds,
            'meals': meals,
          },
        );
        httpResult.value = 'Tes HTTP Selesai.';
      } else {
        httpResult.value = 'HTTP: Error! Status: ${response.statusCode}';
      }
    } catch (e) {
      _stopwatch.stop();
      httpResult.value =
          'HTTP: Exception! ${e.toString().substring(0, e.toString().length > 50 ? 50 : e.toString().length)}...';
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
      final response = await _dio.get(apiEndpointPerf);
      _stopwatch.stop();
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<Meal> meals = (data['meals'] as List)
            .map((m) => Meal.fromJson(m))
            .toList();
        Get.to(
          () => const HasilTesPage(),
          arguments: {
            'library': 'Dio',
            'duration': _stopwatch.elapsedMilliseconds,
            'meals': meals,
          },
        );
        dioResult.value = 'Tes Dio Selesai.';
      } else {
        dioResult.value = 'Dio: Error! Status: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _stopwatch.stop();
      dioResult.value = 'Dio: DioException! ${e.message}';
    } catch (e) {
      _stopwatch.stop();
      dioResult.value =
          'Dio: Exception! ${e.toString().substring(0, e.toString().length > 50 ? 50 : e.toString().length)}...';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> runHttpErrorTest() async {
    isLoading.value = true;
    httpErrorResult.value = 'Loading... (Tes Error HTTP)';
    try {
      await http
          .get(Uri.parse(badApiEndpoint))
          .timeout(const Duration(seconds: 3));
      httpErrorResult.value = 'HTTP Error: Harusnya gagal, tapi sukses (?)';
    } on TimeoutException {
      httpErrorResult.value = 'HTTP Error: TimeoutException (Manual)';
    } on SocketException {
      httpErrorResult.value = 'HTTP Error: SocketException (DNS Gagal)';
    } catch (e) {
      httpErrorResult.value = 'HTTP Error: Tipe error tidak dikenal!';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> runDioErrorTest() async {
    isLoading.value = true;
    dioErrorResult.value = 'Loading... (Tes Error Dio)';
    try {
      await _dio.get(
        badApiEndpoint,
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );
      dioErrorResult.value = 'Dio Error: Harusnya gagal, tapi sukses (?)';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        dioErrorResult.value = 'Dio Error: KONEKSI TIMEOUT (Terdeteksi!)';
      } else if (e.type == DioExceptionType.unknown &&
          e.error is SocketException) {
        dioErrorResult.value = 'Dio Error: DNS GAGAL (Terdeteksi!)';
      } else if (e.type == DioExceptionType.badResponse) {
        dioErrorResult.value =
            'Dio Error: BAD RESPONSE ${e.response?.statusCode} (Terdeteksi!)';
      } else {
        dioErrorResult.value = 'Dio Error: ${e.type.name} (Terdeteksi!)';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // BAGIAN 3: FUNGSI TES ASYNC HANDLING (Input dari User)
  Future<List<String>> getRecommendationsByIngredient(String ingredient) async {
    if (ingredient.trim().isEmpty) {
      return ['Silakan masukkan bahan terlebih dahulu.'];
    }
    asyncResult.value = 'Mencari resep via API dengan bahan: $ingredient...';
    try {
      final response = await _dio.get('$apiEndpointIngredient$ingredient');
      if (response.statusCode == 200 && response.data['meals'] != null) {
        final List<String> mealNames = (response.data['meals'] as List)
            .map<String>(
              (meal) => meal['strMeal'] as String? ?? 'Nama Tidak Diketahui',
            )
            .take(5)
            .toList();
        debugPrint('API Call: Rekomendasi ditemukan: $mealNames');
        return mealNames;
      } else {
        return ['Tidak ada rekomendasi ditemukan untuk "$ingredient"'];
      }
    } on DioException catch (e) {
      throw Exception('Gagal mengambil rekomendasi: ${e.message}');
    } catch (e) {
      throw Exception('Gagal mengambil rekomendasi: ${e.toString()}');
    }
  }

  // --- Pendekatan 1: Async-Await
  Future<void> runAsyncAwaitTest(String ingredient) async {
    isLoading.value = true;
    asyncResult.value = 'Memulai tes Async/Await...';
    _stopwatch.reset();
    _stopwatch.start();
    try {
      final List<String> recommendations = await getRecommendationsByIngredient(
        ingredient,
      );
      _stopwatch.stop();
      asyncResult.value =
          '[Async/Await] Selesai (${_stopwatch.elapsedMilliseconds} ms):\n'
          'Rekomendasi untuk "$ingredient":\n'
          '- ${recommendations.join("\n- ")}';
    } catch (e) {
      _stopwatch.stop();
      asyncResult.value =
          '[Async/Await] Gagal (${_stopwatch.elapsedMilliseconds} ms): ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Pendekatan 2: .then() Callback Chaining
  Future<void> runCallbackTest(String ingredient) async {
    isLoading.value = true;
    asyncResult.value = 'Memulai tes .then() Chaining...';
    _stopwatch.reset();
    _stopwatch.start();

    getRecommendationsByIngredient(ingredient)
        .then((recommendations) {
          _stopwatch.stop();
          asyncResult.value =
              '[.then()] Selesai (${_stopwatch.elapsedMilliseconds} ms):\n'
              'Rekomendasi untuk "$ingredient":\n'
              '- ${recommendations.join("\n- ")}';
        })
        .catchError((error) {
          _stopwatch.stop();
          asyncResult.value =
              '[.then()] Gagal (${_stopwatch.elapsedMilliseconds} ms): ${error.toString()}';
        })
        .whenComplete(() {
          isLoading.value = false;
        });
  }

  // --- 🔹 BAGIAN 4: CONTOH CHAINED REQUEST (Berurutan) ---
  Future<void> runChainedRequestTest() async {
    isLoading.value = true;
    chainedResult.value = 'Memulai chained request...';
    _stopwatch.reset();
    _stopwatch.start();

    try {
      // Step 1: Ambil daftar kategori
      final catRes = await _dio.get(apiEndpointCategories);
      final categories = catRes.data['categories'] as List;
      final firstCategory = categories.first['strCategory'];
      debugPrint('Kategori pertama: $firstCategory');

      // Step 2: Ambil daftar makanan berdasarkan kategori
      final mealRes = await _dio.get('$apiEndpointByCategory$firstCategory');
      final meals = mealRes.data['meals'] as List;
      final firstMealId = meals.first['idMeal'];
      final firstMealName = meals.first['strMeal'];
      debugPrint('Makanan pertama: $firstMealName ($firstMealId)');

      // Step 3: Ambil detail dari makanan pertama
      final detailRes = await _dio.get('$apiEndpointDetail$firstMealId');
      final detail = detailRes.data['meals'][0];
      _stopwatch.stop();

      chainedResult.value =
          '[Chained Request] Selesai (${_stopwatch.elapsedMilliseconds} ms):\n'
          '- Kategori: $firstCategory\n'
          '- Makanan: $firstMealName\n'
          '- Area: ${detail['strArea']}\n'
          '- Instruksi: ${detail['strInstructions'].toString().substring(0, 80)}...';
    } catch (e) {
      _stopwatch.stop();
      chainedResult.value =
          '[Chained Request] Gagal (${_stopwatch.elapsedMilliseconds} ms): ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
