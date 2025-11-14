import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';

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
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final localProduct = controller.product.value;
        final apiProduct = controller.apiProductDetail.value;

        if (localProduct == null && apiProduct == null) {
          return const Center(child: Text('Produk tidak ditemukan.'));
        }

        final bool isLocal = localProduct != null;

        // Ekstrak informasi dari sumber data
        final String imageUrl;
        final String title;
        final String price;
        final String description;

        if (isLocal) {
          imageUrl = localProduct.image;
          title = localProduct.title;
          price = 'Rp. ${localProduct.price}';
          description =
              'Kue kering khas lebaran dengan cita rasa gurih, renyah, dan manis yang seimbang. Dibuat dengan bahan pilihan terbaik tanpa pengawet.';
        } else {
          imageUrl = apiProduct!['strMealThumb'] ?? '';
          title = apiProduct['strMeal'] ?? 'Nama Tidak Tersedia';
          price = 'Harga Spesial';
          description =
              apiProduct['strInstructions'] ?? 'Deskripsi tidak tersedia.';
        }

        return Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: _buildImage(imageUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFE8C00),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isLocal) _buildLocalProductInfo(),
                      if (!isLocal) _buildApiProductInfo(apiProduct!),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(description, textAlign: TextAlign.justify),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final localProduct = controller.product.value;
        if (localProduct == null) {
          // Sembunyikan tombol favorit untuk produk API untuk saat ini
          return const SizedBox.shrink();
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => localProduct.isFavorite.toggle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE8C00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: Icon(
                localProduct.isFavorite.value
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              label: Text(
                localProduct.isFavorite.value
                    ? 'Hapus dari Favorit'
                    : 'Tambahkan ke Favorit',
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImage(String imageUrl) {
    bool isUrl = imageUrl.startsWith('http');
    return isUrl
        ? Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/placeholder.png', // Gambar placeholder jika URL error
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          );
  }

  Widget _buildLocalProductInfo() {
    return Row(
      children: const [
        Icon(Icons.delivery_dining, size: 18),
        SizedBox(width: 6),
        Text('Free Delivery'),
        SizedBox(width: 16),
        Icon(Icons.timer, size: 18),
        SizedBox(width: 6),
        Text('20 - 30 min'),
      ],
    );
  }

  Widget _buildApiProductInfo(Map<String, dynamic> data) {
    return Row(
      children: [
        const Icon(Icons.public, size: 18, color: Colors.blue),
        const SizedBox(width: 6),
        Text('Asal: ${data['strArea'] ?? 'N/A'}'),
        const SizedBox(width: 16),
        const Icon(Icons.category, size: 18, color: Colors.green),
        const SizedBox(width: 6),
        Text('Kategori: ${data['strCategory'] ?? 'N/A'}'),
      ],
    );
  }
}
