import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/product_card.dart';
import '../controllers/produk_kami_controller.dart';

class ProdukKamiPage extends GetView<ProdukKamiController> {
  const ProdukKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Kami'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.combinedProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: controller.combinedProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = controller.combinedProducts[index];
              return ProductCard(product: product);
            },
          ),
        );
      }),
    );
  }
}
