import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/product.dart';
import 'admin_controller.dart'; // Import AdminController

class StatistikController extends GetxController {
  // === PERBAIKAN DI SINI ===
  // Logika: Cek dulu apakah AdminController sudah ada?
  // Jika SUDAH (misal habis buka menu Kelola Produk), pakai Get.find().
  // Jika BELUM (langsung buka Statistik dari Profil), pakai Get.put() untuk membuatnya.
  final AdminController adminController = Get.isRegistered<AdminController>()
      ? Get.find<AdminController>()
      : Get.put(AdminController());

  // Filter State (Untuk Pola: Chart with Filters)
  var filterMode = 'Semua'.obs; // Opsi: Semua, Mahal, Murah
  var touchedIndex = (-1).obs; // Untuk interaksi sentuh grafik

  // --- LOGIC 1: Data Ringkasan (Overview) ---
  int get totalProduk => adminController.products.length;

  double get rataRataHarga {
    if (adminController.products.isEmpty) return 0;
    double total = 0;
    for (var p in adminController.products) {
      total += _parsePrice(p.price);
    }
    return total / adminController.products.length;
  }

  // --- LOGIC 2: Data Pie Chart (Distribusi Harga) ---
  // Mengelompokkan produk berdasarkan range harga
  List<PieChartSectionData> getPieChartData() {
    int murah = 0; // < 50rb
    int sedang = 0; // 50rb - 100rb
    int mahal = 0; // > 100rb

    for (var p in adminController.products) {
      double price = _parsePrice(p.price);
      if (price < 50000) {
        murah++;
      } else if (price <= 100000) {
        sedang++;
      } else {
        mahal++;
      }
    }

    int total = adminController.products.length;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: murah.toDouble(),
        title: '${((murah / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: sedang.toDouble(),
        title: '${((sedang / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: mahal.toDouble(),
        title: '${((mahal / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  // --- LOGIC 3: Data Bar Chart (Kalori per Produk) ---
  List<BarChartGroupData> getBarChartData() {
    List<Product> source = List.from(adminController.products);

    // Filter Logic
    if (filterMode.value == 'Mahal') {
      source = source.where((p) => _parsePrice(p.price) > 100000).toList();
    } else if (filterMode.value == 'Murah') {
      source = source.where((p) => _parsePrice(p.price) < 50000).toList();
    }

    // Ambil 7 produk pertama saja biar grafik tidak penuh sesak
    source = source.take(7).toList();

    return List.generate(source.length, (index) {
      final p = source[index];
      double calories = 0;
      if (p.nutrition != null && p.nutrition!['calories'] != null) {
        calories = double.tryParse(p.nutrition!['calories'].toString()) ?? 0;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: calories,
            color: const Color(0xFFFE8C00),
            width: 16,
            borderRadius: BorderRadius.circular(4),
            // Pattern: Data Point Details (Saat disentuh warnanya beda)
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 600, // Max kalori asumsi
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    });
  }

  // Helper: Ambil nama produk untuk label bawah grafik batang
  String getProductName(int index) {
    List<Product> source = List.from(adminController.products);
    if (filterMode.value == 'Mahal') {
      source = source.where((p) => _parsePrice(p.price) > 100000).toList();
    } else if (filterMode.value == 'Murah') {
      source = source.where((p) => _parsePrice(p.price) < 50000).toList();
    }
    source = source.take(7).toList();

    if (index >= source.length) return '';
    // Ambil 3 huruf pertama nama produk biar muat
    return source[index].title.substring(0, 3).toUpperCase();
  }

  // Helper parsing harga string "Rp 100.000" jadi double
  double _parsePrice(String priceString) {
    return double.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  String formatCurrency(double value) {
    return "Rp ${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
