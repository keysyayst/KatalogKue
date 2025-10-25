import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart'; // <-- Path Relatif

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.product.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final p = controller.product.value!;

        return Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Image.asset(
                p.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp. ${p.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFE8C00),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(Icons.delivery_dining, size: 18),
                          SizedBox(width: 6),
                          Text('Free Delivery'),
                          SizedBox(width: 16),
                          Icon(Icons.timer, size: 18),
                          SizedBox(width: 6),
                          Text('20 - 30 min'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kue kering khas lebaran dengan cita rasa gurih, renyah, dan manis yang seimbang. Dibuat dengan bahan pilihan terbaik tanpa pengawet.',
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.product.value == null) {
          return const SizedBox.shrink();
        }

        final p = controller.product.value!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => p.isFavorite.toggle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE8C00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: Icon(
                p.isFavorite.value ? Icons.favorite : Icons.favorite_border,
              ),
              label: Text(
                p.isFavorite.value
                    ? 'Hapus dari Favorit'
                    : 'Tambahkan ke Favorit',
              ),
            ),
          ),
        );
      }),
    );
  }
}
