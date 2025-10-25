import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/product_card.dart'; // <-- Path Relatif
import '../controllers/produk_kami_controller.dart'; // <-- Path Relatif

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => GridView.builder(
            itemCount: controller.allProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: controller.allProducts[index]);
            },
          ),
        ),
      ),
    );
  }
}
