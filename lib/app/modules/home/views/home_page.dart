import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app.dart';
import '../../../widgets/hero_section.dart';
import '../../../widgets/product_card.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const HeroSection(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Rekomendasi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Pindah ke tab Produk (index 1)
                    final dashboardController = Get.find<DashboardController>();
                    dashboardController.changeTabIndex(1);
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Color(0xFFFE8C00)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => GridView.builder(
                  itemCount: controller.rekomendasiProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: controller.rekomendasiProducts[index],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
