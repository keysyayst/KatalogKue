import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; // <-- Path Relatif
import '../../../widgets/hero_section.dart'; // <-- Path Relatif
import '../../../widgets/product_card.dart'; // <-- Path Relatif
import '../controllers/home_controller.dart'; // <-- Path Relatif

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
                    // ===========================================
                    // PERBAIKAN DI SINI:
                    // Mengubah Routes.PRODUK_KAMI menjadi Routes.produkKami
                    // ===========================================
                    Get.toNamed(Routes.produkKami);
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