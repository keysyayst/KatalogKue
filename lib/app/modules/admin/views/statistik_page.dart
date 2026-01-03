import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/statistik_controller.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  // Definisikan warna lokal
  final Color primaryColor = const Color(0xFFFE8C00);

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(StatistikController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Toko (Admin)'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // POLA 1: DASHBOARD & OVERVIEW
            // ============================================================
            const Text(
              "Ringkasan Performa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryCard(
                  title: "Total Produk",
                  value: "${controller.totalProduk}",
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  title: "Rata-rata Harga",
                  value: controller.formatCurrency(controller.rataRataHarga),
                  icon: Icons.monetization_on,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ============================================================
            // POLA 2: INTEGRATED LEGEND
            // ============================================================
            const Text(
              "Distribusi Harga Produk",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: PieChart(
                        PieChartData(
                          sections: controller.getPieChartData(),
                          centerSpaceRadius: 30,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          color: Colors.green,
                          label: "< 50rb (Ekonomis)",
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          color: Colors.orange,
                          label: "50-100rb (Standar)",
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          color: Colors.red,
                          label: "> 100rb (Premium)",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ============================================================
            // POLA 3 & 4: CHART WITH FILTERS & DATA POINT DETAILS
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Analisis Kalori Produk",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => DropdownButton<String>(
                    value: controller.filterMode.value,
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text("Semua")),
                      DropdownMenuItem(
                        value: 'Mahal',
                        child: Text("Harga > 100rb"),
                      ),
                      DropdownMenuItem(
                        value: 'Murah',
                        child: Text("Harga < 50rb"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.filterMode.value = val;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: Obx(
                () => BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 600,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.round()} kCal',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                controller.getProductName(value.toInt()),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: controller.getBarChartData(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ============================================================
            // POLA 5: OVERVIEW PLUS DATA
            // ============================================================
            const Text(
              "Data Detail Produk",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.adminController.products.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = controller.adminController.products[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(product.price),
                    trailing: Text(
                      "${product.nutrition?['calories'] ?? '-'} kCal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // PERBAIKAN: Menggunakan .withValues(alpha: ...)
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                // PERBAIKAN: Menggunakan .withValues(alpha: ...)
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
