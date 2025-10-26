import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:io'; // Diperlukan untuk SocketException
import 'dart:ui'; // Diperlukan untuk Color

import '../../../data/models/meal_model.dart';
import '../views/hasil_tes_page.dart';

class ContactController extends GetxController {
  // --- API ENDPOINTS ---
  final String apiEndpoint =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert';
  final String badApiEndpoint =
      'https://api.domain-salah.com/v1/data'; // URL sengaja salah

  final Dio _dio = Dio();
  final Stopwatch _stopwatch = Stopwatch();

  // --- UI STATES ---
  var httpResult = 'Tekan tombol untuk tes HTTP'.obs;
  var httpErrorResult = 'Tekan tombol untuk tes Error HTTP'.obs;
  var dioResult = 'Tekan tombol untuk tes Dio'.obs;
  var dioErrorResult = 'Tekan tombol untuk tes Error Dio'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // ====================================================================
    // TUGAS 2: MENAMBAHKAN LOGGING INTERCEPTOR DIO
    // Ini akan otomatis mencetak semua log request, response, dan error
    // ke Debug Console Anda.
    // ====================================================================
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true, // Tampilkan header request
        requestBody: true, // Tampilkan body request
        responseHeader: true, // Tampilkan header response
        responseBody: true, // Tampilkan body response (jika sukses)
        error: true, // Tampilkan detail error
        logPrint: (obj) => print(obj.toString()), // Kirim log ke Debug Console
      ),
    );
  }

  // --- FUNGSI TES PERFORMA (dari tugas 1) ---
  Future<void> runHttpTest() async {
    // ... (Fungsi ini tetap sama seperti sebelumnya)
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
            .map((m) => Meal.fromJson(m))
            .toList();
        Get.to(
          () => const HasilTesPage(),
          arguments: {'library': 'HTTP', 'duration': duration, 'meals': meals},
        );
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
    // ... (Fungsi ini tetap sama seperti sebelumnya)
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
            .map((m) => Meal.fromJson(m))
            .toList();
        Get.to(
          () => const HasilTesPage(),
          arguments: {'library': 'Dio', 'duration': duration, 'meals': meals},
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
      dioResult.value = 'Dio: Exception! ${e.toString().substring(0, 50)}...';
    } finally {
      isLoading.value = false;
    }
  }

  // ====================================================================
  // TUGAS 2: FUNGSI UNTUK TES ERROR HANDLING
  // ====================================================================

  // --- FUNGSI TES ERROR HTTP ---
  Future<void> runHttpErrorTest() async {
    isLoading.value = true;
    httpErrorResult.value = 'Loading... (Tes Error HTTP)';
    try {
      // http tidak punya opsi timeout bawaan yang mudah,
      // jadi kita tambahkan .timeout() secara manual
      await http
          .get(Uri.parse(badApiEndpoint))
          .timeout(const Duration(seconds: 3));
      httpErrorResult.value = 'HTTP Error: Harusnya gagal, tapi sukses (?)';
    } on TimeoutException {
      // Ini jika koneksi timeout (butuh implementasi manual)
      httpErrorResult.value = 'HTTP Error: TimeoutException (Manual)';
    } on SocketException {
      // Ini error DNS / koneksi tidak ada
      httpErrorResult.value = 'HTTP Error: SocketException (DNS Gagal)';
    } catch (e) {
      // Ini menangkap error lainnya
      httpErrorResult.value = 'HTTP Error: Tipe error tidak dikenal!';
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI TES ERROR DIO ---
  Future<void> runDioErrorTest() async {
    isLoading.value = true;
    dioErrorResult.value = 'Loading... (Tes Error Dio)';

    try {
      // Dio punya opsi timeout bawaan yang bersih
      await _dio.get(
        badApiEndpoint,
        options: Options(receiveTimeout: const Duration(seconds: 3)),
      );
      dioErrorResult.value = 'Dio Error: Harusnya gagal, tapi sukses (?)';
    } on DioException catch (e) {
      // Dio bisa membedakan jenis error dengan SANGAT JELAS
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
}
