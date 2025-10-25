import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/product_card.dart'; // <-- Path Relatif
import '../controllers/favorite_controller.dart'; // <-- Path Relatif

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        backgroundColor: const Color(0xFFFE8C00),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final favs = controller.favoriteProducts;

        return favs.isEmpty
            ? const Center(child: Text('Belum ada produk favorit.'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: favs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(product: favs[index]);
                  },
                ),
              );
      }),
    );
  }
}